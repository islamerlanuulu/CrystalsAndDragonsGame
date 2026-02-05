//
//  Room.swift
//  CrystalsAndDragons
//
//  Created by Islam Erlan uulu  on 5/2/26.
//

import Foundation

final class Room {

    let position: Position

    private(set) var exits: Set<Direction> = []
    private(set) var items: [Item] = []

    init(position: Position) {
        self.position = position
    }

    func addExit(_ direction: Direction) {
        exits.insert(direction)
    }

    func hasExit(_ direction: Direction) -> Bool {
        exits.contains(direction)
    }

    func placeItem(_ item: Item) {
        items.append(item)
    }

    @discardableResult
    func removeItem(_ item: Item) -> Item? {
        guard let index = items.firstIndex(of: item) else { return nil }
        return items.remove(at: index)
    }

    func containsItemOfType(_ type: ItemType) -> Bool {
        items.contains { $0.type == type }
    }
}
