//
//  iMediaStreamParserProtocol.swift
//
//
//  Created by Apple on 13/10/2024.
//

import Foundation

public protocol iMediaStreamParserProtocol {
    func parse(data: Data) -> Result<iMediaStream, CoreError>
}
