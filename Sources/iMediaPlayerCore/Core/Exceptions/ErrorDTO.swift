//
//  File.swift
//  
//
//  Created by Apple on 13/10/2024.
//

import Foundation

public typealias ErrorDTO = iMediaPlayerErrorDTO

public struct iMediaPlayerErrorDTO: Error {
    public let functionName: String
    public let lineNumber: String
    public let errorCode: Int
    public var error: Error?
    public let detail: String
    public let humanDetail: String = ""
    public var errors: [CoreError] = []
}


extension iMediaPlayerErrorDTO: iMediaPlayerErrorProtocol {
    public var errorSteam: [any iMediaPlayerErrorProtocol] { errors }
}
