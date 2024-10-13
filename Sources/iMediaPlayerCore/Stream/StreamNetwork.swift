//
//  File.swift
//  
//
//  Created by Apple on 13/10/2024.
//

import Foundation

public protocol StreamManifestNetworkProtocol {
    func manifest(url: URL, completion: @escaping (NetworkResponse<iMediaStream>) -> ())
}

public struct StreamDownloadResponse {
    let remote: URL
    let local: URL
}

public protocol StreamDownloadNetworkProtocol {
    func download(url: URL, cometion: @escaping (StreamDownloadResponse) -> ())
}

