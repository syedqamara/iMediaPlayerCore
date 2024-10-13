//
//  VideoRenderingProtocol.swift
//  
//
//  Created by Apple on 13/10/2024.
//

import AVFoundation

protocol VideoRenderingProtocol {
    func render(videoBuffer: CVPixelBuffer)
    func stop()
}
