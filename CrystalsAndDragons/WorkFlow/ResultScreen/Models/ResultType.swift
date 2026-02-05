//
//  ResultType.swift
//  CrystalsAndDragons
//
//  Created by Islam Erlan uulu  on 5/2/26.
//

import Foundation

enum ResultType {
    case win
    case gameOver

    var iconName: String {
        switch self {
        case .win:
            return "win_icon"
        case .gameOver:
            return "dead_icon"
        }
    }

    var title: String {
        switch self {
        case .win:      
            return "ПОБЕДА!"
        case .gameOver:
            return "Поражение"
        }
    }
    
    var message: String {
        switch self {
        case .win:
            return "Вы нашли Святой Грааль!"
        case .gameOver:
            return "У вас закончились ходы."
        }
    }
}
