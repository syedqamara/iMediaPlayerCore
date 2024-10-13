//
//  AudioRenderingProtocol.swift
//  
//
//  Created by Apple on 13/10/2024.
//

import AVFoundation

protocol AudioRenderingProtocol {
    func render(audioBuffer: AVAudioPCMBuffer)
    func stop()
}
