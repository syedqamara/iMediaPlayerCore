//
//  File.swift
//  
//
//  Created by Apple on 13/10/2024.
//

import Foundation

public protocol iMediaPlayerMasterPlaylistProtocol {
    var mediaPlaylist: [iMediaPlayerMediaPlaylistProtocol] { get }
}

public protocol iMediaPlayerMediaPlaylistProtocol {
    var streams: [iMediaStream] { get }
}
