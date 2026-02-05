//
//  Observable.swift
//  CrystalsAndDragons
//
//  Created by Islam Erlan uulu  on 5/2/26.
//

import Foundation

final class Observable<T> {
    
    var value: T {
        didSet {
            notifyObservers()
        }
    }
    
    private var observers: [UUID: (T) -> Void] = [:]
    
    init(_ value: T) {
        self.value = value
    }
    
    @discardableResult
    func bind(_ observer: @escaping (T) -> Void) -> UUID {
        let id = UUID()
        observers[id] = observer
        observer(value)
        return id
    }
    
    func unbind(_ id: UUID) {
        observers.removeValue(forKey: id)
    }
    
    private func notifyObservers() {
        for (_, observer) in observers {
            observer(value)
        }
    }
}
