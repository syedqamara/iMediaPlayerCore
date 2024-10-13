//
//  File.swift
//  
//
//  Created by Apple on 13/10/2024.
//

import Foundation

public enum CoreError: Error {
case system(ErrorDTO), network(ErrorDTO), rendering(ErrorDTO), parsing(ErrorDTO)
}

extension CoreError: iMediaPlayerErrorProtocol {
    public var errorSteam: [any iMediaPlayerErrorProtocol] {
        switch self {
        case .system(let errorDTO):
            return errorDTO.errorSteam
        case .network(let errorDTO):
            return errorDTO.errorSteam
        case .rendering(let errorDTO):
            return errorDTO.errorSteam
        case .parsing(let errorDTO):
            return errorDTO.errorSteam
        }
    }
}
