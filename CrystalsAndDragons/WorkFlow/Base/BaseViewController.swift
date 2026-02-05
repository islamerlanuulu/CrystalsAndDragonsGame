//
//  BaseViewController.swift
//  CrystalsAndDragons
//
//  Created by Islam Erlan uulu  on 5/2/26.
//

import UIKit

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setup()
    }

    func setup() {
        setupSubviews()
        setupConstraints()
        bindViewModel()
    }

    func setupSubviews() {

    }

    func setupConstraints() {

    }

    func bindViewModel() {

    }
}
