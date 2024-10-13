//
//  File.swift
//  
//
//  Created by Apple on 13/10/2024.
//

import Foundation

public enum FeatureStatus: String {
case active, disabled, indevelopment, rollout
}

public protocol iMediaToggles {
    func status(key: String) -> FeatureStatus
    func all() -> [String: FeatureStatus]
}

public extension iMediaToggles {
    func isEnabled(key: String) -> Bool {
        status(key: key) == .active || status(key: key) == .rollout
    }
}
