//
//  UIStackView+Extensions.swift
//  CrystalsAndDragons
//
//  Created by Islam Erlan uulu  on 5/2/26.
//

import UIKit

extension UIStackView {
    
    @resultBuilder
    struct SubviewBuilder {
        static func buildBlock(_ components: UIView...) -> [UIView] {
            components
        }
    }
    
    func addArrangedSubviews(@SubviewBuilder _ components: () -> ([UIView])) {
        components().forEach(addArrangedSubview)
    }
}
