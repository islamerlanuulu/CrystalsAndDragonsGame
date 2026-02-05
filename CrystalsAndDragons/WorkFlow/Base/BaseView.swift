//
//  BaseView.swift
//  CrystalsAndDragons
//
//  Created by Islam Erlan uulu  on 5/2/26.
//

import UIKit

class BaseView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup() {
        setupSubviews()
        setupConstraints()
    }

    func setupSubviews() {
        
    }
    
    func setupConstraints() {
        
    }
}
