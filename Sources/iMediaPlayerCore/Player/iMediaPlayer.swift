//
//  File.swift
//  
//
//  Created by Apple on 13/10/2024.
//

import Foundation

public protocol iMediaPlayerBufferProtocol {
    
}

public protocol iMediaPlayerDelegate: AnyObject {
    func did(recieve: iMediaPlayerBufferProtocol, error: iMediaPlayerErrorProtocol)
}

public protocol iMediaPlayerProtocol {
    var control: iMediaPlayerControlProtocol { get }
    var delegate: iMediaPlayerDelegate? { get set }
}

public protocol iMediaPlayerControlProtocol {
    func play()
    func pause()
    func stop()
    func seek(to time: TimeInterval)
    var currentTime: TimeInterval { get }
    var isPlaying: Bool { get }
}
