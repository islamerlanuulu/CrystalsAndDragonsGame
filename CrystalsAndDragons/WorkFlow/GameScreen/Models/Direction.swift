//
//  Direction.swift
//  CrystalsAndDragons
//
//  Created by Islam Erlan uulu  on 5/2/26.
//

import Foundation

enum Direction: String, CaseIterable {
    case north = "N"
    case south = "S"
    case east = "E"
    case west = "W"

    var opposite: Direction {
        switch self {
        case .north:
            return .south
        case .south:
            return .north
        case .east:
            return .west
        case .west:
            return .east
        }
    }

    var offset: (dRow: Int, dCol: Int) {
        switch self {
        case .north:
            return (-1,  0)
        case .south:
            return ( 1,  0)
        case .east:
            return ( 0,  1)
        case .west:
            return ( 0, -1)
        }
    }

    var arrow: String {
        switch self {
        case .north: 
            return "↑"
        case .south: 
            return "↓"
        case .east:  
            return "→"
        case .west:  
            return "←"
        }
    }
}
