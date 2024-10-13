//
//  File.swift
//  
//
//  Created by Apple on 13/10/2024.
//

import Foundation

enum NetworkMode {
case cellular, wifi
}

protocol NetworkMonitorProtocol {
    func start()
    func stop()
    var bandwidth: Double { get }
    var mode: NetworkMode { get }
    var delegate: NetworkMonitorDelegate? { get set }
}

protocol NetworkMonitorDelegate {
    func bandwidthDidChange(_ bandwidth: Double)
    func modeDidChange(_ mode: NetworkMode)
}
