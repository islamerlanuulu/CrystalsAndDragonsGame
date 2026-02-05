//
//  Labyrinth.swift
//  CrystalsAndDragons
//
//  Created by Islam Erlan uulu  on 5/2/26.
//

import Foundation

final class Labyrinth {
    
    let rows: Int
    let cols: Int

    private var roomMap: [Position: Room] = [:]

    init(rows: Int, cols: Int) {
        self.rows = rows
        self.cols = cols
    }

    func room(at position: Position) -> Room? {
        roomMap[position]
    }

    func setRoom(_ room: Room, at position: Position) {
        roomMap[position] = room
    }

    var allPositions: [Position] {
        (0..<rows).flatMap { r in
            (0..<cols).map { c in Position(row: r, col: c) }
        }
    }

    func isValid(_ position: Position) -> Bool {
        position.row >= 0 && position.row < rows &&
        position.col >= 0 && position.col < cols
    }

    func neighbor(of position: Position, direction: Direction) -> Room? {
        guard let currentRoom = room(at: position),
              currentRoom.hasExit(direction) else { return nil }
        let nextPos = position.moved(to: direction)
        return room(at: nextPos)
    }
}
