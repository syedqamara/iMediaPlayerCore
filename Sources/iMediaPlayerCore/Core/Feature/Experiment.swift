//
//  File.swift
//  
//
//  Created by Apple on 13/10/2024.
//

import Foundation
public struct Experiment<T> {
    public let current: T
    public let expected: [T]
    public init(current: T, expected: [T]) {
        self.current = current
        self.expected = expected
    }
}

public protocol iMediaExperiments {
    func status<E>(key: String) -> Experiment<E>
    func all<E>() -> [String: Experiment<E>]
}

