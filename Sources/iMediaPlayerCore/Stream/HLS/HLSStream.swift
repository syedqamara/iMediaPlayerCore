//
//  File.swift
//  
//
//  Created by Apple on 13/10/2024.
//

import Foundation
// MARK: - HLS Stream Data Structure

public struct HLSStream {
    public let masterPlaylist: MasterPlaylist
    public let variantStreams: [VariantStream]
    public let alternateMedia: [AlternateMedia]
    
    public init(masterPlaylist: MasterPlaylist, variantStreams: [VariantStream], alternateMedia: [AlternateMedia]) {
        self.masterPlaylist = masterPlaylist
        self.variantStreams = variantStreams
        self.alternateMedia = alternateMedia
    }

    // MARK: Master Playlist
    public struct MasterPlaylist {
        public let playlistURL: URL
        public let version: Int
        public let variantStreams: [VariantStream]
        public let alternateMedia: [AlternateMedia]  // Audio, Subtitles, etc.
        public let targetDuration: TimeInterval
        public let mediaSequence: Int?
        public let isLive: Bool
        
        public init(playlistURL: URL, version: Int, variantStreams: [VariantStream], alternateMedia: [AlternateMedia], targetDuration: TimeInterval, mediaSequence: Int?, isLive: Bool) {
            self.playlistURL = playlistURL
            self.version = version
            self.variantStreams = variantStreams
            self.alternateMedia = alternateMedia
            self.targetDuration = targetDuration
            self.mediaSequence = mediaSequence
            self.isLive = isLive
        }
    }
    
    // MARK: Variant Stream
    public struct VariantStream {
        public let resolution: Resolution?
        public let bandwidth: Int
        public let codecs: String
        public let averageBandwidth: Int?
        public let frameRate: Double?
        public let segmentList: MediaPlaylist
        
        public init(resolution: Resolution?, bandwidth: Int, codecs: String, averageBandwidth: Int?, frameRate: Double?, segmentList: MediaPlaylist) {
            self.resolution = resolution
            self.bandwidth = bandwidth
            self.codecs = codecs
            self.averageBandwidth = averageBandwidth
            self.frameRate = frameRate
            self.segmentList = segmentList
        }

        public struct Resolution: Equatable {
            public let width: Int
            public let height: Int
            
            public init(width: Int, height: Int) {
                self.width = width
                self.height = height
            }
        }
    }
    
    // MARK: Media Playlist
    public struct MediaPlaylist {
        public let playlistURL: URL
        public let segments: [Segment]
        public let targetDuration: Double  // The max duration of any segment
        public let totalDuration: Double   // Total duration of the playlist
        public let isLive: Bool            // Indicates live stream
        public let isIFrameOnly: Bool?     // For I-frame only streams
        public let mediaSequence: Int      // Identifies the first segment in the playlist
        
        public init(playlistURL: URL, segments: [Segment], targetDuration: Double, totalDuration: Double, isLive: Bool, isIFrameOnly: Bool?, mediaSequence: Int) {
            self.playlistURL = playlistURL
            self.segments = segments
            self.targetDuration = targetDuration
            self.totalDuration = totalDuration
            self.isLive = isLive
            self.isIFrameOnly = isIFrameOnly
            self.mediaSequence = mediaSequence
        }
    }
    
    // MARK: Segment
    public struct Segment {
        public let url: URL
        public let duration: Double
        public let sequence: Int            // Sequence number of the segment
        public let title: String?           // Optional title for the segment
        public let discontinuity: Bool      // Indicates if there is a discontinuity
        public let key: EncryptionKey?      // Encryption key for encrypted segments
        public let byteRange: ByteRange?    // Range for byte-range requests
        
        public init(url: URL, duration: Double, sequence: Int, title: String?, discontinuity: Bool, key: EncryptionKey?, byteRange: ByteRange?) {
            self.url = url
            self.duration = duration
            self.sequence = sequence
            self.title = title
            self.discontinuity = discontinuity
            self.key = key
            self.byteRange = byteRange
        }
    }
    
    // MARK: Encryption Key
    public struct EncryptionKey {
        public let method: String          // Encryption method (e.g., AES-128, SAMPLE-AES)
        public let uri: URL                // URI to fetch the key
        public let iv: String?             // Initialization Vector for the key
        
        public init(method: String, uri: URL, iv: String?) {
            self.method = method
            self.uri = uri
            self.iv = iv
        }
    }
    
    // MARK: Byte Range
    public struct ByteRange {
        public let length: Int             // Length of the byte range
        public let start: Int?             // Starting byte (if not sequential)
        
        public init(length: Int, start: Int?) {
            self.length = length
            self.start = start
        }
    }
    
    // MARK: Alternate Media (e.g., Audio, Subtitles)
    public struct AlternateMedia {
        public let type: MediaType         // Type of media (audio, subtitles, etc.)
        public let groupId: String         // Group ID for associating with variant streams
        public let name: String            // Name of the track (e.g., "English")
        public let defaultMedia: Bool      // Is this the default media track?
        public let autoselect: Bool        // Is this track auto-selected?
        public let forced: Bool?           // Is this a forced subtitle track?
        public let characteristics: [String]? // E.g., public.accessibility.transcribes-spoken-dialog
        public let uri: URL?               // URI to the media (if external)
        
        public init(type: MediaType, groupId: String, name: String, defaultMedia: Bool, autoselect: Bool, forced: Bool?, characteristics: [String]?, uri: URL?) {
            self.type = type
            self.groupId = groupId
            self.name = name
            self.defaultMedia = defaultMedia
            self.autoselect = autoselect
            self.forced = forced
            self.characteristics = characteristics
            self.uri = uri
        }
        
        public enum MediaType {
            case audio
            case subtitles
            case closedCaptions
            case video
        }
    }
    
    // MARK: Helper Methods

    public func fetchVariantStream(forResolution resolution: VariantStream.Resolution) -> VariantStream? {
        return variantStreams.first { $0.resolution == resolution }
    }
    
    public func fetchDefaultAudioTrack() -> AlternateMedia? {
        return alternateMedia.first { $0.type == .audio && $0.defaultMedia }
    }
    
    public func fetchSubtitles(forLanguage language: String) -> AlternateMedia? {
        return alternateMedia.first { $0.type == .subtitles && $0.name == language }
    }
}
