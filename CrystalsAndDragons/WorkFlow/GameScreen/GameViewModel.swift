//
//  GameViewModel.swift
//  CrystalsAndDragons
//
//  Created by Islam Erlan uulu  on 5/2/26.
//

import Foundation

final class GameViewModel {
    private let labyrinth: Labyrinth
    private let player: Player
    private let isMapLoggingEnabled = true

    let roomTitle = Observable<String>("")
    let movesLeft = Observable<Int>(0)
    let roomExits = Observable<Set<Direction>>([])
    let roomItems = Observable<[Item]>([])
    let inventory = Observable<[Item]>([])
    let gameState = Observable<GameState>(.playing)
    let statusMessage = Observable<String?>("")

    init(
        rows: Int,
        cols: Int,
        roomCount: Int,
        moveLimit: Int
    ) {
        let result = LabyrinthGenerator.generate(rows: rows, cols: cols, roomCount: roomCount, moveLimit: moveLimit)
        self.labyrinth = result.labyrinth
        self.player = Player(startPosition: result.startPosition, moveLimit: moveLimit)

        refreshRoomState()
        refreshInventory()
    }

    @discardableResult
    func move(_ direction: Direction) -> Bool {
        guard gameState.value == .playing else { return false }

        let currentPos = player.position
        guard let currentRoom = labyrinth.room(at: currentPos),
              currentRoom.hasExit(direction) else { return false }

        let nextPos = currentPos.moved(to: direction)
        guard labyrinth.room(at: nextPos) != nil else { return false }

        player.position = nextPos
        player.consumeMove()

        refreshRoomState()

        if player.movesLeft <= 0 {
            gameState.value = .gameOver
        }

        return true
    }

    func pickUpItem(_ item: Item) {
        guard gameState.value == .playing else { return }
        guard item.type.isCollectible else { return }

        guard let room = labyrinth.room(at: player.position) else { return }
        guard room.removeItem(item) != nil else { return }

        player.addItem(item)
        refreshRoomState()
        refreshInventory()
    }

    func performAction(_ action: ItemAction, on item: Item) {
        guard gameState.value == .playing else { return }

        switch action {
        case .use:
            useItem(item)
        case .drop:
            dropItem(item)
        case .destroy:
            destroyItem(item)
        }
    }

    func availableActions(for item: Item) -> [ItemAction] {
        var actions: [ItemAction] = []
        if item.type.isUsable {
            actions.append(.use)
        }
        actions.append(.drop)
        if item.type != .key {
            actions.append(.destroy)
        }
        return actions
    }

    func actionLabel(for action: ItemAction) -> String {
        switch action {
        case .use:
            return "Использовать"
        case .drop:
            return "Бросить"
        case .destroy:
            return "Уничтожить"
        }
    }

    private func useItem(_ item: Item) {
        switch item.type {
        case .key:
            useKey(item)
        case .food:
            useFood(item)
        default:
            break
        }
    }

    private func useKey(_ item: Item) {
        guard let room = labyrinth.room(at: player.position),
              room.containsItemOfType(.chest) else {
            statusMessage.value = "Здесь нет сундука!"
            return
        }

        player.removeItem(item)
        refreshInventory()

        gameState.value = .win
    }

    private func useFood(_ item: Item) {
        player.removeItem(item)

        let restored = item.type.movesRestored
        player.restoreMoves(restored)

        statusMessage.value = "+\(restored) ходов восстановлено!"
        refreshRoomState()
        refreshInventory()
    }

    private func dropItem(_ item: Item) {
        guard player.removeItem(item) != nil else { return }
        labyrinth.room(at: player.position)?.placeItem(item)
        refreshRoomState()
        refreshInventory()
    }

    private func destroyItem(_ item: Item) {
        player.removeItem(item)
        refreshInventory()
    }

    private func refreshRoomState() {
        guard let room = labyrinth.room(at: player.position) else { return }
        let pos = player.position
        roomTitle.value = "Комната [\(pos.col + 1), \(pos.row + 1)]"
        movesLeft.value = player.movesLeft
        roomExits.value = room.exits
        roomItems.value = room.items
    }

    private func refreshInventory() {
        inventory.value = player.inventory
    }
}
