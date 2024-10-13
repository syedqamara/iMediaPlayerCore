//
//  File.swift
//  
//
//  Created by Apple on 13/10/2024.
//

import Foundation

public enum iMediaPathType {
    case remote
    case local
}
public enum iMediaRendingQuality {
    case low, medium, high, _4K
}
public enum iMediaStreamType {
    case hls(HLSStream)
}


public struct iMediaStream {
    let pathType: iMediaPathType
    let stream: iMediaStreamType
}
