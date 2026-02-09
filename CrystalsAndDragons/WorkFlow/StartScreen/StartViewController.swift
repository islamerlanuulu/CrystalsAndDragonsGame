//
//  StartViewController.swift
//  CrystalsAndDragons
//
//  Created by Islam Erlan uulu  on 5/2/26.
//

import UIKit

final class StartViewController: BaseViewController {

    var onStartGame: ((_ rows: Int, _ cols: Int, _ roomCount: Int, _ moveLimit: Int) -> Void)?
    
    private let viewModel = StartViewModel()

    private let titleLabel: UILabel = {
        let view = UILabel()
        view.text = "Кристаллы и Драконы"
        view.font = .systemFont(ofSize: 28, weight: .bold)
        view.textColor = .black
        view.textAlignment = .center
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let subtitleLabel: UILabel = {
        let view = UILabel()
        view.text = "Найдите ключ, \nоткройте сундук и заберите Святой Грааль!"
        view.font = .systemFont(ofSize: 14)
        view.textColor = .darkGray
        view.textAlignment = .center
        view.numberOfLines = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let roomCountField: UITextField = {
        let view = UITextField()
        view.font = .systemFont(ofSize: 16)
        view.textColor = .black
        view.keyboardType = .numberPad
        view.backgroundColor = UIColor(white: 0.93, alpha: 1.0)
        view.layer.cornerRadius = 8
        view.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
        view.leftViewMode = .always
        view.textAlignment = .center
        view.attributedPlaceholder = NSAttributedString(
            string: "Количество комнат (4–200)",
            attributes: [.foregroundColor: UIColor.gray]
        )
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var startButton: UIButton = {
        let view = UIButton(type: .system)
        view.setTitle("Начать игру", for: .normal)
        view.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        view.setTitleColor(.white, for: .normal)
        view.backgroundColor = .black
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(startTapped), for: .touchUpInside)
        return view
    }()

    private let errorLabel: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 13)
        view.textColor = .systemRed
        view.textAlignment = .center
        view.numberOfLines = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()

    override func setup() {
        super.setup()
        title = "Новая игра"
        
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
    }

    override func setupSubviews() {
        super.setupSubviews()
        view.add {
            titleLabel
            subtitleLabel
            roomCountField
            errorLabel
            startButton
        }
    }

    override func setupConstraints() {
        super.setupConstraints()
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            roomCountField.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 30),
            roomCountField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            roomCountField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            roomCountField.heightAnchor.constraint(equalToConstant: 48),

            errorLabel.topAnchor.constraint(equalTo: roomCountField.bottomAnchor, constant: 8),
            errorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            errorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            startButton.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 16),
            startButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            startButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            startButton.heightAnchor.constraint(equalToConstant: 50),
        ])
    }

    override func bindViewModel() {
        super.bindViewModel()
        viewModel.errorMessage.bind { [weak self] message in
            guard let self else { return }
            if let message, !message.isEmpty {
                self.errorLabel.text = message
                self.errorLabel.isHidden = false
            } else {
                self.errorLabel.isHidden = true
            }
        }

        viewModel.startConfig.bind { [weak self] config in
            guard let self, let config else { return }
            self.onStartGame?(config.rows, config.cols, config.roomCount, config.moveLimit)
            self.viewModel.clearStartConfig()
        }
    }

    @objc
    private func startTapped() {
        view.endEditing(true)
        viewModel.start(with: roomCountField.text)
    }
}
