//
//  ResultViewController.swift
//  CrystalsAndDragons
//
//  Created by Islam Erlan uulu on 5/2/26.
//

import UIKit

final class ResultViewController: BaseViewController {

    var onRestart: (() -> Void)?
    var resultType: ResultType = .gameOver

    private lazy var iconImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: resultType.iconName)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 32, weight: .bold)
        view.textAlignment = .center
        view.text = resultType.title
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var messageLabel: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 16)
        view.textColor = .darkGray
        view.textAlignment = .center
        view.numberOfLines = 0
        view.text = resultType.message
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var restartButton: UIButton = {
        let view = UIButton(type: .system)
        view.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        view.setTitleColor(.white, for: .normal)
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setTitle("Сыграть еще раз", for: .normal)
        view.backgroundColor = .black
        view.addTarget(self, action: #selector(restartTapped), for: .touchUpInside)
        return view
    }()

    private lazy var stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 16
        view.alignment = .center
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func setup() {
        super.setup()
        navigationItem.hidesBackButton = true
    }

    override func setupSubviews() {
        super.setupSubviews()
        view.addSubview(stackView)
        
        stackView.addArrangedSubviews {
            iconImageView
            titleLabel
            messageLabel
            restartButton
        }
    }

    override func setupConstraints() {
        super.setupConstraints()
        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -30),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            iconImageView.widthAnchor.constraint(equalToConstant: 80),
            iconImageView.heightAnchor.constraint(equalToConstant: 80),
            
            restartButton.heightAnchor.constraint(equalToConstant: 50),
            restartButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            restartButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
    }

    @objc
    private func restartTapped() {
        onRestart?()
    }
}
