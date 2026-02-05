//
//  InventoryView.swift
//  CrystalsAndDragons
//
//  Created by Islam Erlan uulu  on 5/2/26.
//

import UIKit

final class InventoryView: BaseView {
    
    var onItemTap: ((Item) -> Void)?
    
    private let titleLabel: UILabel = {
        let view = UILabel()
        view.text = "Инвентарь"
        view.font = .systemFont(ofSize: 13, weight: .semibold)
        view.textColor = .darkGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.showsHorizontalScrollIndicator = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 10
        view.alignment = .center
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let emptyLabel: UILabel = {
        let view = UILabel()
        view.text = "Пусто"
        view.font = .italicSystemFont(ofSize: 12)
        view.textColor = .darkGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func setup() {
        super.setup()
        backgroundColor = UIColor(white: 0.93, alpha: 1.0)
        layer.cornerRadius = 12
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    override func setupSubviews() {
        super.setupSubviews()
        add {
            titleLabel
            scrollView
            emptyLabel
        }
        
        scrollView.addSubview(stackView)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            scrollView.heightAnchor.constraint(equalToConstant: 60),
            
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
            
            emptyLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor),
        ])
    }
    
    func update(items: [Item]) {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        emptyLabel.isHidden = !items.isEmpty
        
        for item in items {
            let itemView = ItemView(item: item)
            itemView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                itemView.widthAnchor.constraint(equalToConstant: 56),
                itemView.heightAnchor.constraint(equalToConstant: 56),
            ])
            itemView.onTap = { [weak self] in
                guard let self else { return }
                self.onItemTap?(item)
            }
            stackView.addArrangedSubview(itemView)
        }
    }
}
