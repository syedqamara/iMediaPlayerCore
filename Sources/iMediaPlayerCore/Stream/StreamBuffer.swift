//
//  File.swift
//  
//
//  Created by Apple on 13/10/2024.
//

import Foundation

protocol StreamBufferProtocol {
    func buffer<B: iMediaPlayerBufferProtocol>(for url: URL, completion: @escaping (Result<B, CoreError>) -> ())
}
