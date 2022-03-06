//
//  ObservableObject.swift
//  PeggleClone
//
//  Created by Kyle キラ on 6/2/22.
//

import UIKit

final class ObservableObject<T> {

    var value: T {
        didSet {
            listeners.forEach {
                $0(value)
            }
        }
    }

    private var listeners: [((T) -> Void)] = []

    init(_ value: T) {
        self.value = value
    }

    func bind(_ listener: @escaping(T) -> Void, notifyInitialValue: Bool = true) {
        if notifyInitialValue {
            listener(value)
        }

        self.listeners.append(listener)
    }

}
