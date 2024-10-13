//
//  File.swift
//  
//
//  Created by Apple on 13/10/2024.
//

import Foundation

public protocol StreamManagerDelegate {
    
}

public protocol StreamManagerProtocol {
    var current: iMediaStream? { get }
    var all: [iMediaStream] { get }
    
    func start()
    func stop()
    func `switch`(to stream: iMediaStream)
}
