//
//  RoomView.swift
//  CrystalsAndDragons
//
//  Created by Islam Erlan uulu  on 5/2/26.
//

import UIKit

final class RoomView: BaseView {
    
    var onDirectionTap: ((Direction) -> Void)?
    var onItemTap: ((Item) -> Void)?
    
    private var directionButtons: [Direction: UIButton] = [:]
    
    private let itemsContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        return view
    }()
    
    private var itemPositionCache: [UUID: CGPoint] = [:]
    
    private let roomBorder: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.borderWidth = 3
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func setup() {
        super.setup()
        backgroundColor = .clear
    }
    
    override func setupSubviews() {
        super.setupSubviews()
        add {
            roomBorder
            itemsContainer
        }
        
        for direction in Direction.allCases {
            let button = makeDirectionButton(direction)
            directionButtons[direction] = button
            addSubview(button)
        }
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        layoutDirectionButtons()
        layoutCenterContent()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        placeItemViews()
    }
    
    private func makeDirectionButton(_ direction: Direction) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(direction.arrow, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 28, weight: .bold)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.white, for: .disabled)
        button.backgroundColor = .black
        button.layer.cornerRadius = 25
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tag = Direction.allCases.firstIndex(of: direction) ?? 0
        button.addTarget(self, action: #selector(directionButtonTapped(_:)), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 50),
            button.heightAnchor.constraint(equalToConstant: 50),
        ])
        return button
    }
    
    private func layoutDirectionButtons() {
        guard let north = directionButtons[.north],
              let south = directionButtons[.south],
              let east = directionButtons[.east],
              let west = directionButtons[.west] else { return }
        
        NSLayoutConstraint.activate([
            roomBorder.topAnchor.constraint(equalTo: topAnchor),
            roomBorder.leadingAnchor.constraint(equalTo: leadingAnchor),
            roomBorder.trailingAnchor.constraint(equalTo: trailingAnchor),
            roomBorder.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            north.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            north.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            south.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            south.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            west.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            west.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            east.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            east.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
    
    private func layoutCenterContent() {
        NSLayoutConstraint.activate([
            itemsContainer.topAnchor.constraint(equalTo: topAnchor, constant: 70),
            itemsContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 70),
            itemsContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -70),
            itemsContainer.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -70),
        ])
    }
    
    func update(exits: Set<Direction>, items: [Item]) {
        for direction in Direction.allCases {
            directionButtons[direction]?.isEnabled = exits.contains(direction)
            directionButtons[direction]?.alpha = exits.contains(direction) ? 1.0 : 0.3
        }
        
        itemsContainer.subviews.forEach { $0.removeFromSuperview() }
        
        let currentIDs = Set(items.map { $0.id })
        itemPositionCache = itemPositionCache.filter { currentIDs.contains($0.key) }
        
        for item in items {
            let itemView = ItemView(item: item)
            itemView.frame = CGRect(x: 0, y: 0, width: 56, height: 56)
            itemView.onTap = { [weak self] in
                guard let self else { return }
                self.onItemTap?(item)
            }
            itemsContainer.addSubview(itemView)
        }
        
        setNeedsLayout()
    }
    
    private func placeItemViews() {
        let containerSize = itemsContainer.bounds.size
        guard containerSize.width > 60, containerSize.height > 60 else { return }
        
        let itemSize: CGFloat = 56
        let maxX = containerSize.width - itemSize
        let maxY = containerSize.height - itemSize
        
        var occupiedFrames: [CGRect] = []
        
        for subview in itemsContainer.subviews {
            guard let itemView = subview as? ItemView else { continue }
            
            let itemID = itemView.itemID
            let position: CGPoint
            
            if let cached = itemPositionCache[itemID] {
                position = CGPoint(
                    x: min(max(cached.x, 0), maxX),
                    y: min(max(cached.y, 0), maxY)
                )
            } else {
                position = findFreePosition(
                    itemSize: itemSize,
                    maxX: maxX,
                    maxY: maxY,
                    occupied: occupiedFrames,
                    seed: itemID
                )
                itemPositionCache[itemID] = position
            }
            
            itemView.frame = CGRect(origin: position, size: CGSize(width: itemSize, height: itemSize))
            occupiedFrames.append(itemView.frame)
        }
    }
    
    private func findFreePosition(
        itemSize: CGFloat,
        maxX: CGFloat,
        maxY: CGFloat,
        occupied: [CGRect],
        seed: UUID
    ) -> CGPoint {
        var hasher = Hasher()
        hasher.combine(seed)
        var rng = hasher.finalize()
        
        for _ in 0..<20 {
            rng = rng &* 6364136223846793005 &+ 1
            let xRatio = CGFloat(abs(rng) % 1000) / 1000.0
            rng = rng &* 6364136223846793005 &+ 1
            let yRatio = CGFloat(abs(rng) % 1000) / 1000.0
            
            let x = xRatio * maxX
            let y = yRatio * maxY
            let candidate = CGRect(x: x, y: y, width: itemSize, height: itemSize)
            
            let overlaps = occupied.contains { $0.intersects(candidate.insetBy(dx: -4, dy: -4)) }
            if !overlaps {
                return CGPoint(x: x, y: y)
            }
        }
        
        rng = seed.hashValue &* 6364136223846793005 &+ 1
        let x = CGFloat(abs(rng) % 1000) / 1000.0 * maxX
        rng = rng &* 6364136223846793005 &+ 1
        let y = CGFloat(abs(rng) % 1000) / 1000.0 * maxY
        return CGPoint(x: x, y: y)
    }
    
    @objc
    private func directionButtonTapped(_ sender: UIButton) {
        let direction = Direction.allCases[sender.tag]
        UIView.animate(withDuration: 0.1, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                sender.transform = .identity
            }
        }
        onDirectionTap?(direction)
    }
}
