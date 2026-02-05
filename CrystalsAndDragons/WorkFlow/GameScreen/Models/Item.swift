//
//  Item.swift
//  CrystalsAndDragons
//
//  Created by Islam Erlan uulu  on 5/2/26.
//

import UIKit

enum ItemType: String, CaseIterable {
    case key = "Ключ"
    case chest = "Сундук"
    case food = "Еда"
    case stone = "Камень"
    case mushroom = "Гриб"
    case bone = "Кость"
    
    var isCollectible: Bool {
        switch self {
        case .chest:
            return false
        default:
            return true
        }
    }
    
    var isUsable: Bool {
        switch self {
        case .key, .food:
            return true
        default:
            return false
        }
    }
    
    var iconName: String {
        switch self {
        case .key:
            return "key_icon"
        case .chest:
            return "box_icon"
        case .food:
            return "food_icon"
        case .stone:
            return "stone_icon"
        case .mushroom:
            return "mushroom_icon"
        case .bone:
            return "bone_icon"
        }
    }
    
    var movesRestored: Int {
        switch self {
        case .food:
            return 5
        default:
            return 0
        }
    }
}

struct Item: Equatable {
    let id: UUID
    let type: ItemType
    
    init(type: ItemType) {
        self.id = UUID()
        self.type = type
    }
    
    static func == (lhs: Item, rhs: Item) -> Bool {
        lhs.id == rhs.id
    }
}
