//
//  LabyrinthGenerator.swift
//  CrystalsAndDragons
//
//  Created by Islam Erlan uulu  on 5/2/26.
//

import Foundation

struct LabyrinthGenerator {

    struct Result {
        let labyrinth: Labyrinth
        let startPosition: Position
    }

    static func generate(rows: Int, cols: Int, roomCount: Int, moveLimit: Int) -> Result {
        let labyrinth = Labyrinth(rows: rows, cols: cols)

        let selectedPositions = selectConnectedPositions(rows: rows, cols: cols, count: roomCount)

        for pos in selectedPositions {
            labyrinth.setRoom(Room(position: pos), at: pos)
        }

        connectAllNeighbors(labyrinth: labyrinth, positions: selectedPositions)

        let startPosition = placeItems(labyrinth: labyrinth, positions: selectedPositions, moveLimit: moveLimit)

        return Result(labyrinth: labyrinth, startPosition: startPosition)
    }

    private static func selectConnectedPositions(rows: Int, cols: Int, count: Int) -> [Position] {
        return (0..<rows).flatMap { r in
            (0..<cols).map { c in Position(row: r, col: c) }
        }
    }

    private static func connectAllNeighbors(labyrinth: Labyrinth, positions: [Position]) {
        let positionSet = Set(positions)

        for pos in positions {
            guard let room = labyrinth.room(at: pos) else { continue }

            for dir in Direction.allCases {
                let neighbor = pos.moved(to: dir)
                if positionSet.contains(neighbor),
                   !room.hasExit(dir),
                   let neighborRoom = labyrinth.room(at: neighbor) {
                    room.addExit(dir)
                    neighborRoom.addExit(dir.opposite)
                }
            }
        }
    }

    static func bfsDistance(in labyrinth: Labyrinth, from: Position, to: Position) -> Int {
        if from == to { return 0 }
        var visited: Set<Position> = [from]
        var queue: [(position: Position, distance: Int)] = [(from, 0)]
        var head = 0

        while head < queue.count {
            let (current, dist) = queue[head]
            head += 1

            guard let room = labyrinth.room(at: current) else { continue }
            
            for exit in room.exits {
                let next = current.moved(to: exit)
                if next == to { return dist + 1 }
                if !visited.contains(next) {
                    visited.insert(next)
                    queue.append((next, dist + 1))
                }
            }
        }
        return Int.max
    }

    private static func placeItems(labyrinth: Labyrinth, positions: [Position], moveLimit: Int) -> Position {
        let maxRetries = 100
        let preferredStart = Position(row: 0, col: 0)
        let startPosition = positions.contains(preferredStart) ? preferredStart : (positions.first ?? preferredStart)
        let keyChestCandidates = positions.filter { $0 != startPosition }

        let totalRooms = positions.count
        let foodCount  = max(1, totalRooms / 8)

        for _ in 0..<maxRetries {
            let keyChestPool = keyChestCandidates.shuffled()
            guard keyChestPool.count >= 2 else { break }

            let start    = startPosition
            let keyPos   = keyChestPool[0]
            let chestPos = keyChestPool[1]

            let distToKey    = bfsDistance(in: labyrinth, from: start, to: keyPos)
            let distToChest  = bfsDistance(in: labyrinth, from: keyPos, to: chestPos)

            guard distToKey != Int.max,
                  distToChest != Int.max,
                  distToKey + distToChest <= moveLimit else { continue }

            labyrinth.room(at: keyPos)?.placeItem(Item(type: .key))

            labyrinth.room(at: chestPos)?.placeItem(Item(type: .chest))

            let remaining = positions.filter { $0 != keyPos && $0 != chestPos }.shuffled()
            let fallbackPool = remaining.isEmpty ? positions : remaining
            var nextIndex = 0

            for _ in 0..<foodCount {
                let pos = nextIndex < remaining.count
                    ? remaining[nextIndex]
                    : fallbackPool.randomElement()!
                labyrinth.room(at: pos)?.placeItem(Item(type: .food))
                nextIndex += 1
            }

            let decorativeTypes: [ItemType] = [.stone, .mushroom, .bone]
            
            for type in decorativeTypes {
                let pos = nextIndex < remaining.count
                    ? remaining[nextIndex]
                    : fallbackPool.randomElement()!
                labyrinth.room(at: pos)?.placeItem(Item(type: type))
                nextIndex += 1
            }

            return start
        }

        let start = startPosition
        let keyPos = keyChestCandidates.first ?? start
        let chestPos = keyChestCandidates.count > 1 ? keyChestCandidates[1] : keyPos

        labyrinth.room(at: keyPos)?.placeItem(Item(type: .key))
        labyrinth.room(at: chestPos)?.placeItem(Item(type: .chest))

        let extraTypes: [ItemType] = [.food, .stone, .mushroom, .bone]
        let remaining = positions.filter { $0 != keyPos && $0 != chestPos }
        let fallbackPool = remaining.isEmpty ? positions : remaining
        
        for (i, type) in extraTypes.enumerated() {
            let pos = i < remaining.count ? remaining[i] : (fallbackPool.randomElement() ?? start)
            labyrinth.room(at: pos)?.placeItem(Item(type: type))
        }

        return start
    }
}
