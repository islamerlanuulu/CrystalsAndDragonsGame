//
//  Position.swift
//  CrystalsAndDragons
//
//  Created by Islam Erlan uulu  on 5/2/26.
//

import Foundation

struct Position: Hashable {
    let row: Int
    let col: Int

    func moved(to direction: Direction) -> Position {
        let offset = direction.offset
        return Position(row: row + offset.dRow, col: col + offset.dCol)
    }
}
