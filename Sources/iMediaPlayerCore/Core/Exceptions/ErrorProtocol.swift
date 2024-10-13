//
//  File.swift
//  
//
//  Created by Apple on 13/10/2024.
//

import Foundation

public let EndLine = "\n"

public protocol iMediaPlayerErrorProtocol {
    var errorSteam: [iMediaPlayerErrorProtocol] { get }
}

extension iMediaPlayerErrorProtocol {
    func debugingDetail(spaceCount: Int = 0) -> String {
        var errorCompleteText = ""
        for errorSteam in self.errorSteam {
            let space = Array(repeating: " ", count: spaceCount).joined(separator: "")
            let errorText = errorSteam.debugingDetail(spaceCount: spaceCount + 4)
            errorCompleteText += space + errorText + EndLine
        }
        return errorCompleteText
    }
}
