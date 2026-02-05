//
//  GameViewController.swift
//  CrystalsAndDragons
//
//  Created by Islam Erlan uulu  on 5/2/26.
//

import UIKit

final class GameViewController: BaseViewController {
    var rows: Int = 0
    var cols: Int = 0
    var moveLimit: Int = 0
    var onGameEnd: ((ResultType) -> Void)?
    
    private var viewModel: GameViewModel!
    
    private let roomTitleLabel: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 18, weight: .bold)
        view.textColor = .black
        view.textAlignment = .center
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let movesLabel: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 14, weight: .medium)
        view.textColor = .systemOrange
        view.textAlignment = .center
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let statusLabel: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 13, weight: .medium)
        view.textColor = .systemGreen
        view.textAlignment = .center
        view.numberOfLines = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alpha = 0
        return view
    }()
    
    private let roomView = RoomView()
    private let inventoryView = InventoryView()
    
    override func setup() {
        viewModel = GameViewModel(rows: rows, cols: cols, moveLimit: moveLimit)
        super.setup()
        navigationItem.hidesBackButton = true

        roomView.translatesAutoresizingMaskIntoConstraints = false
        inventoryView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override func setupSubviews() {
        super.setupSubviews()
        view.add {
            roomTitleLabel
            movesLabel
            statusLabel
            roomView
            inventoryView
        }
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        NSLayoutConstraint.activate([
            roomTitleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            roomTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            roomTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            movesLabel.topAnchor.constraint(equalTo: roomTitleLabel.bottomAnchor, constant: 4),
            movesLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            statusLabel.topAnchor.constraint(equalTo: movesLabel.bottomAnchor, constant: 2),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            roomView.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 8),
            roomView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            roomView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            roomView.bottomAnchor.constraint(equalTo: inventoryView.topAnchor, constant: -8),
            
            inventoryView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            inventoryView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            inventoryView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            inventoryView.heightAnchor.constraint(equalToConstant: 90),
        ])
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        viewModel.roomTitle.bind { [weak self] title in
            guard let self else  { return }
            self.roomTitleLabel.text = title
        }
        
        viewModel.movesLeft.bind { [weak self] moves in
            guard let self else  { return }
            self.movesLabel.text = "Осталось ходов: \(moves)"
        }
        
        viewModel.roomExits.bind { [weak self] _ in
            guard let self else { return }
            self.roomView.update(exits: self.viewModel.roomExits.value,
                                 items: self.viewModel.roomItems.value)
        }
        
        viewModel.roomItems.bind { [weak self] _ in
            guard let self else { return }
            self.roomView.update(exits: self.viewModel.roomExits.value,
                                 items: self.viewModel.roomItems.value)
        }
        
        viewModel.inventory.bind { [weak self] items in
            guard let self else  { return }
            self.inventoryView.update(items: items)
        }
        
        viewModel.gameState.bind { [weak self] state in
            guard let self else { return }
            guard state != .playing else { return }
            self.handleGameStateChange(state)
        }
        
        viewModel.statusMessage.bind { [weak self] message in
            guard let self, let message, !message.isEmpty else { return }
            self.statusLabel.text = message
            self.statusLabel.alpha = 1
            UIView.animate(withDuration: 0.3, delay: 2.0, options: []) {
                self.statusLabel.alpha = 0
            }
        }
        
        roomView.onDirectionTap = { [weak self] direction in
            guard let self else { return }
            self.viewModel.move(direction)
        }
        
        roomView.onItemTap = { [weak self] item in
            guard let self else { return }
            self.viewModel.pickUpItem(item)
        }
        
        inventoryView.onItemTap = { [weak self] item in
            guard let self else { return }
            self.showItemActionSheet(for: item)
        }
    }
    
    private func showItemActionSheet(for item: Item) {
        let actions = viewModel.availableActions(for: item)
        var labels: [ItemAction: String] = [:]
        for action in actions {
            labels[action] = viewModel.actionLabel(for: action)
        }
        
        let sheet = ItemActionSheetView(item: item, actions: actions, actionLabels: labels)
        sheet.onAction = { [weak self] action in
            self?.viewModel.performAction(action, on: item)
        }
        sheet.show(in: view)
    }
    
    private func handleGameStateChange(_ state: GameState) {
        switch state {
        case .playing:
            return
        case .win:
            onGameEnd?(.win)
        case .gameOver:
            onGameEnd?(.gameOver)
        }
    }
}
