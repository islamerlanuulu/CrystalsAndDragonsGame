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

    static func generate(rows: Int, cols: Int, moveLimit: Int) -> Result {
        let labyrinth = Labyrinth(rows: rows, cols: cols)

        for pos in labyrinth.allPositions {
            labyrinth.setRoom(Room(position: pos), at: pos)
        }

        carveMaze(labyrinth: labyrinth)

        addExtraConnections(labyrinth: labyrinth, ratio: 0.15)

        let startPosition = placeItems(labyrinth: labyrinth, moveLimit: moveLimit)

        return Result(labyrinth: labyrinth, startPosition: startPosition)
    }

    private static func carveMaze(labyrinth: Labyrinth) {
        var visited: Set<Position> = []
        let start = Position(row: 0, col: 0)
        var stack: [Position] = [start]
        visited.insert(start)

        while !stack.isEmpty {
            let current = stack.last!
            let neighbors = Direction.allCases.compactMap { dir -> (Direction, Position)? in
                let next = current.moved(to: dir)
                guard labyrinth.isValid(next), !visited.contains(next) else { return nil }
                return (dir, next)
            }.shuffled()

            if let (dir, next) = neighbors.first {
                labyrinth.room(at: current)?.addExit(dir)
                labyrinth.room(at: next)?.addExit(dir.opposite)
                visited.insert(next)
                stack.append(next)
            } else {
                stack.removeLast()
            }
        }
    }

    private static func addExtraConnections(labyrinth: Labyrinth, ratio: Double) {
        let total = labyrinth.rows * labyrinth.cols
        let extraCount = max(1, Int(Double(total) * ratio))

        for _ in 0..<extraCount {
            let pos = Position(
                row: Int.random(in: 0..<labyrinth.rows),
                col: Int.random(in: 0..<labyrinth.cols)
            )
            guard let room = labyrinth.room(at: pos) else { continue }
            let directions = Direction.allCases.shuffled()
            for dir in directions {
                let neighbor = pos.moved(to: dir)
                guard labyrinth.isValid(neighbor),
                      !room.hasExit(dir),
                      let neighborRoom = labyrinth.room(at: neighbor) else { continue }
                room.addExit(dir)
                neighborRoom.addExit(dir.opposite)
                break
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

    private static func placeItems(labyrinth: Labyrinth, moveLimit: Int) -> Position {
        let allPositions = labyrinth.allPositions.shuffled()
        let maxRetries = 100

        let totalRooms = labyrinth.rows * labyrinth.cols
        let foodCount  = max(1, totalRooms / 8)

        for _ in 0..<maxRetries {
            let shuffled = allPositions.shuffled()
            guard shuffled.count >= 3 else { break }

            let start    = shuffled[0]
            let keyPos   = shuffled[1]
            let chestPos = shuffled[2]

            let distToKey    = bfsDistance(in: labyrinth, from: start, to: keyPos)
            let distToChest  = bfsDistance(in: labyrinth, from: keyPos, to: chestPos)

            guard distToKey != Int.max,
                  distToChest != Int.max,
                  distToKey + distToChest <= moveLimit else { continue }

            labyrinth.room(at: keyPos)?.placeItem(Item(type: .key))

            labyrinth.room(at: chestPos)?.placeItem(Item(type: .chest))

            let remaining = Array(shuffled.dropFirst(3))
            var nextIndex = 0

            for _ in 0..<foodCount {
                let pos = nextIndex < remaining.count
                    ? remaining[nextIndex]
                    : allPositions.randomElement()!
                labyrinth.room(at: pos)?.placeItem(Item(type: .food))
                nextIndex += 1
            }

            let decorativeTypes: [ItemType] = [.stone, .mushroom, .bone]
            for type in decorativeTypes {
                let pos = nextIndex < remaining.count
                    ? remaining[nextIndex]
                    : allPositions.randomElement()!
                labyrinth.room(at: pos)?.placeItem(Item(type: type))
                nextIndex += 1
            }

            return start
        }

        let start = allPositions[0]
        let keyPos = allPositions.count > 1 ? allPositions[1] : allPositions[0]
        let chestPos = allPositions.count > 2 ? allPositions[2] : allPositions[0]

        labyrinth.room(at: keyPos)?.placeItem(Item(type: .key))
        labyrinth.room(at: chestPos)?.placeItem(Item(type: .chest))

        let extraTypes: [ItemType] = [.food, .stone, .mushroom, .bone]
        for (i, type) in extraTypes.enumerated() {
            let pos = allPositions.count > 3 + i ? allPositions[3 + i] : allPositions[0]
            labyrinth.room(at: pos)?.placeItem(Item(type: type))
        }

        return start
    }
}
