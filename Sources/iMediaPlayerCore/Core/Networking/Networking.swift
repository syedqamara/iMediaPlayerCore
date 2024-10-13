//
//  File 2.swift
//  
//
//  Created by Apple on 13/10/2024.
//

import Foundation

public struct NetworkResponse<T> {
    public var content: T?
    public var error: CoreError?
}

public protocol NetworkingProtcol {
    func send<T>(request: URLRequest, completion: @escaping (NetworkResponse<T>) -> Void)
}

