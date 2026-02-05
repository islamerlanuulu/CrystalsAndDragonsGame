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
        let moveLimit = rows * cols * 2

        errorMessage.value = nil
        startConfig.value = StartConfig(rows: rows, cols: cols, moveLimit: moveLimit)
    }

    func clearStartConfig() {
        startConfig.value = nil
    }

    private static func calculateGrid(for roomCount: Int) -> (rows: Int, cols: Int) {
        let sqrtVal = Int(Double(roomCount).squareRoot())
        var bestRows = sqrtVal
        var bestCols = sqrtVal

        if bestRows * bestCols < roomCount {
            bestCols = sqrtVal + 1
        }
        if bestRows * bestCols < roomCount {
            bestRows = sqrtVal + 1
        }

        bestRows = max(bestRows, 2)
        bestCols = max(bestCols, 2)

        return (bestRows, bestCols)
    }
}
