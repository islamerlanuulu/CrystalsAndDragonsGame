//
//  Player.swift
//  CrystalsAndDragons
//
//  Created by Islam Erlan uulu  on 5/2/26.
//

import Foundation

final class Player {

    var position: Position
    private(set) var inventory: [Item] = []

    var movesLeft: Int
    let moveLimit: Int

    init(startPosition: Position, moveLimit: Int) {
        self.position = startPosition
        self.movesLeft = moveLimit
        self.moveLimit = moveLimit
    }

    func addItem(_ item: Item) {
        inventory.append(item)
    }

    @discardableResult
    func removeItem(_ item: Item) -> Item? {
        guard let index = inventory.firstIndex(of: item) else { return nil }
        return inventory.remove(at: index)
    }

    func hasItemOfType(_ type: ItemType) -> Bool {
        inventory.contains { $0.type == type }
    }

    @discardableResult
    func consumeMove() -> Bool {
        movesLeft -= 1
        return movesLeft > 0
    }

    func restoreMoves(_ amount: Int) {
        movesLeft = min(movesLeft + amount, moveLimit)
    }
}
