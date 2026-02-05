//
//  ItemActionSheetView.swift
//  CrystalsAndDragons
//
//  Created by Islam Erlan uulu  on 5/2/26.
//

import UIKit

final class ItemActionSheetView: BaseView {
    
    var onAction: ((ItemAction) -> Void)?
    var onDismiss: (() -> Void)?
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let handleView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.15)
        view.layer.cornerRadius = 2.5
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let iconImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 18, weight: .bold)
        view.textColor = .black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let buttonsStack: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 12
        view.distribution = .fillEqually
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let dimView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var containerBottomConstraint: NSLayoutConstraint?
    
    init(item: Item, actions: [ItemAction], actionLabels: [ItemAction: String]) {
        super.init(frame: .zero)
        configure(item: item, actions: actions, actionLabels: actionLabels)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setup() {
        super.setup()
        translatesAutoresizingMaskIntoConstraints = false
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dimTapped))
        dimView.addGestureRecognizer(tap)
    }
    
    override func setupSubviews() {
        super.setupSubviews()
        add {
            dimView
            containerView
        }
        
        containerView.add {
            handleView
            iconImageView
            titleLabel
            buttonsStack
        }
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        let bottomConstraint = containerView.bottomAnchor.constraint(equalTo: bottomAnchor)
        self.containerBottomConstraint = bottomConstraint
        
        NSLayoutConstraint.activate([
            dimView.topAnchor.constraint(equalTo: topAnchor),
            dimView.leadingAnchor.constraint(equalTo: leadingAnchor),
            dimView.trailingAnchor.constraint(equalTo: trailingAnchor),
            dimView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomConstraint,
            
            handleView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            handleView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            handleView.widthAnchor.constraint(equalToConstant: 40),
            handleView.heightAnchor.constraint(equalToConstant: 5),
            
            iconImageView.topAnchor.constraint(equalTo: handleView.bottomAnchor, constant: 16),
            iconImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            iconImageView.widthAnchor.constraint(equalToConstant: 36),
            iconImageView.heightAnchor.constraint(equalToConstant: 36),
            
            titleLabel.centerYAnchor.constraint(equalTo: iconImageView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            buttonsStack.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 16),
            buttonsStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            buttonsStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            buttonsStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -30),
            buttonsStack.heightAnchor.constraint(equalToConstant: 44),
        ])
    }
    
    private func configure(item: Item, actions: [ItemAction], actionLabels: [ItemAction: String]) {
        iconImageView.image = UIImage(named: item.type.iconName)
        titleLabel.text = item.type.rawValue
        
        buttonsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for action in actions {
            let button = UIButton(type: .system)
            button.setTitle(actionLabels[action] ?? action.label, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
            button.layer.cornerRadius = 10
            button.clipsToBounds = true
            
            switch action {
            case .use:
                button.backgroundColor = .systemGreen
                button.setTitleColor(.white, for: .normal)
            case .drop:
                button.backgroundColor = UIColor.black.withAlphaComponent(0.08)
                button.setTitleColor(.black, for: .normal)
            case .destroy:
                button.backgroundColor = .systemRed.withAlphaComponent(0.8)
                button.setTitleColor(.white, for: .normal)
            }
            
            button.tag = actions.firstIndex(of: action)!
            button.addTarget(self, action: #selector(actionButtonTapped(_:)), for: .touchUpInside)
            buttonsStack.addArrangedSubview(button)
        }
        
        self.storedActions = actions
    }
    
    func show(in parent: UIView) {
        parent.addSubview(self)
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: parent.topAnchor),
            leadingAnchor.constraint(equalTo: parent.leadingAnchor),
            trailingAnchor.constraint(equalTo: parent.trailingAnchor),
            bottomAnchor.constraint(equalTo: parent.bottomAnchor),
        ])
        
        containerView.transform = CGAffineTransform(translationX: 0, y: 300)
        dimView.alpha = 0
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
            self.containerView.transform = .identity
            self.dimView.alpha = 1
        }
    }
    
    func dismiss(completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn, animations: {
            self.containerView.transform = CGAffineTransform(translationX: 0, y: 300)
            self.dimView.alpha = 0
        }) { _ in
            self.removeFromSuperview()
            completion?()
        }
    }
    
    private var storedActions: [ItemAction] = []
    
    @objc
    private func actionButtonTapped(_ sender: UIButton) {
        let action = storedActions[sender.tag]
        dismiss { [weak self] in
            guard let self else  { return }
            self.onAction?(action)
        }
    }
    
    @objc
    private func dimTapped() {
        dismiss { [weak self] in
            guard let self else  { return }
            self.onDismiss?()
        }
    }
}

private extension ItemAction {
    var label: String {
        switch self {
        case .use:
            return "Использовать"
        case .drop:
            return "Бросить"
        case .destroy:
            return "Уничтожить"
        }
    }
}
