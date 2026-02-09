//
//  AppCoordinator.swift
//  CrystalsAndDragons
//
//  Created by Islam Erlan uulu  on 5/2/26.
//

import UIKit

final class AppCoordinator {

    private let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        showStart()
    }

    private func showStart() {
        let vc = StartViewController()
        vc.onStartGame = { [weak self] rows, cols, roomCount, moveLimit in
            guard let self else { return }
            self.showGame(rows: rows, cols: cols, roomCount: roomCount, moveLimit: moveLimit)
        }
        navigationController.setViewControllers([vc], animated: false)
    }

    private func showGame(rows: Int, cols: Int, roomCount: Int, moveLimit: Int) {
        let vc = GameViewController()
        vc.rows = rows
        vc.cols = cols
        vc.roomCount = roomCount
        vc.moveLimit = moveLimit
        vc.onGameEnd = { [weak self] resultType in
            guard let self else { return }
            self.showResult(resultType)
        }
        navigationController.pushViewController(vc, animated: true)
    }

    private func showResult(_ resultType: ResultType) {
        let vc = ResultViewController()
        vc.resultType = resultType
        vc.onRestart = { [weak self] in
            guard let self else { return }
            self.showStart()
        }
        navigationController.pushViewController(vc, animated: true)
    }
}
