//
//  StartViewModel.swift
//  CrystalsAndDragons
//
//  Created by Islam Erlan uulu  on 5/2/26.
//

import Foundation

final class StartViewModel {

    let errorMessage = Observable<String?>(nil)
    let startConfig = Observable<StartConfig?>(nil)

    private let minRooms = 4
    private let maxRooms = 200

    func start(with text: String?) {
        let trimmed = text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard let roomCount = Int(trimmed),
              roomCount >= minRooms,
              roomCount <= maxRooms else {
            errorMessage.value = "Введите число комнат от 4 до 200"
            return
        }

        let (rows, cols) = Self.calculateGrid(for: roomCount)
        let moveLimit = roomCount * 2

        errorMessage.value = nil
        startConfig.value = StartConfig(rows: rows, cols: cols, roomCount: roomCount, moveLimit: moveLimit)
    }

    func clearStartConfig() {
        startConfig.value = nil
    }

    private static func calculateGrid(for roomCount: Int) -> (rows: Int, cols: Int) {
        guard roomCount > 0 else { return (1, 1) }

        var cols = Int(ceil(sqrt(Double(roomCount))))
        var rows = Int(ceil(Double(roomCount) / Double(cols)))

        if rows > cols {
            swap(&rows, &cols)
        }

        return (rows, cols)
    }
}
