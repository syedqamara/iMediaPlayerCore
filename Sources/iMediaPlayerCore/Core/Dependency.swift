//
//  File.swift
//  
//
//  Created by Apple on 13/10/2024.
//

import Foundation

public typealias Dependable = iMediaPlayerDependable
public typealias MaybeDependable = iMediaPlayerMaybeDependable
public typealias Dependency = iMediaPlayerDependencyProtocol



public protocol iMediaPlayerDependencyProtocol {
    var toggleProvider: iMediaToggles { get } // for feature management
}

public protocol iMediaPlayerDependable {
    var dependency: iMediaPlayerDependencyProtocol { get }
}

public protocol iMediaPlayerMaybeDependable {
    var dependency: iMediaPlayerDependencyProtocol? { get }
}

public protocol iMediaPlayerApplication {
    init(dependency: iMediaPlayerDependencyProtocol)
}
