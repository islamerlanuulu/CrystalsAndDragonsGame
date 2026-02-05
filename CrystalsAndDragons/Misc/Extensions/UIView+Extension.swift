//
//  UIView+Extension.swift
//  CrystalsAndDragons
//
//  Created by Islam Erlan uulu  on 4/2/26.
//

import UIKit

extension UIView {
    
    @resultBuilder
    struct SubviewBuilder {
        static func buildBlock(_ components: UIView...) -> [UIView] { components }
    }
    
    func add(@SubviewBuilder _ components: () -> [UIView]) {
        components().forEach(addSubview)
    }
}
