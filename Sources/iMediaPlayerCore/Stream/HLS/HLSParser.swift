import Foundation


public struct HLSParser: iMediaStreamParserProtocol {
    private let versionParser = VersionParser()
    private let variantStreamParser = VariantStreamParser()
    private let alternateMediaParser = AlternateMediaParser()
    private let targetDurationParser = TargetDurationParser()
    private let mediaSequenceParser = MediaSequenceParser()
    private let playlistTypeParser = PlaylistTypeParser()

    private func parse(from data: Data) -> Result<HLSStream, ErrorDTO> {
        guard let playlistContent = String(data: data, encoding: .utf8) else {
            let error = ErrorDTO(functionName: #function, lineNumber: "\(#line)", errorCode: 1, detail: "Unable to decode UTF-8 string")
            return .failure(error)
        }

        var variantStreams: [HLSStream.VariantStream] = []
        var alternateMedia: [HLSStream.AlternateMedia] = []
        var isLive = false
        var version = 1 // Default version
        var targetDuration: TimeInterval = 0.0
        var mediaSequence: Int?

        let lines = playlistContent.split(separator: "\n")

        for (index, line) in lines.enumerated() {
            let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)

            // Delegating parsing tasks to specific parsers
            if trimmedLine.hasPrefix("#EXTM3U") {
                continue
            } else if trimmedLine.hasPrefix("#EXT-X-VERSION:") {
                version = versionParser.parse(trimmedLine) ?? version
            } else if trimmedLine.hasPrefix("#EXT-X-STREAM-INF") {
                let nextLine = index + 1 < lines.count ? String(lines[index + 1]) : nil
                if let variantStream = variantStreamParser.parse(String(line), nextLine: nextLine) {
                    variantStreams.append(variantStream)
                }
            } else if trimmedLine.hasPrefix("#EXT-X-MEDIA") {
                if let media = alternateMediaParser.parse(trimmedLine) {
                    alternateMedia.append(media)
                }
            } else if trimmedLine.hasPrefix("#EXT-X-TARGETDURATION:") {
                targetDuration = targetDurationParser.parse(trimmedLine) ?? 0
            } else if trimmedLine.hasPrefix("#EXT-X-MEDIA-SEQUENCE:") {
                mediaSequence = mediaSequenceParser.parse(trimmedLine)
            } else if trimmedLine.hasPrefix("#EXT-X-PLAYLIST-TYPE:") {
                isLive = playlistTypeParser.parse(trimmedLine) ?? isLive
            }
        }

        let masterPlaylist = HLSStream.MasterPlaylist(playlistURL: URL(string: "http://example.com")!, version: version, variantStreams: variantStreams, alternateMedia: alternateMedia, targetDuration: targetDuration, mediaSequence: mediaSequence, isLive: isLive)

        let stream = HLSStream(masterPlaylist: masterPlaylist, variantStreams: variantStreams, alternateMedia: alternateMedia)
        return .success(stream)
    }
}

// MARK: - Conforms to iMediaStreamParserProtocol

extension HLSParser {
    public func parse(data: Data) -> Result<iMediaStream, CoreError> {
        let result = self.parse(from: data)
        switch result {
        case .success(let success):
            return .success(.init(pathType: .remote, stream: .hls(success)))
        case .failure(let failure):
            return .failure(.parsing(failure))
        }
    }
}

// MARK: - Parsing Components

extension HLSParser {
    private struct VersionParser {
        func parse(_ line: String) -> Int? {
            if let versionString = line.split(separator: ":").last, let version = Int(versionString) {
                return version
            }
            return nil
        }
    }

    private struct VariantStreamParser {
        func parse(_ line: String, nextLine: String?) -> HLSStream.VariantStream? {
            let attributes = line.replacingOccurrences(of: "#EXT-X-STREAM-INF:", with: "").split(separator: ",")
            var bandwidth: Int?
            var codecs: String?
            var resolution: HLSStream.VariantStream.Resolution?
            var averageBandwidth: Int?
            var frameRate: Double?

            for attribute in attributes {
                let attributeString = String(attribute).trimmingCharacters(in: .whitespacesAndNewlines)
                if attributeString.hasPrefix("BANDWIDTH=") {
                    bandwidth = Int(attributeString.replacingOccurrences(of: "BANDWIDTH=", with: "")) ?? nil
                } else if attributeString.hasPrefix("CODECS=") {
                    codecs = attributeString.replacingOccurrences(of: "CODECS=", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                } else if attributeString.hasPrefix("RESOLUTION=") {
                    let resolutionString = attributeString.replacingOccurrences(of: "RESOLUTION=", with: "")
                    let dimensions = resolutionString.split(separator: "x")
                    if dimensions.count == 2,
                       let width = Int(dimensions[0]), let height = Int(dimensions[1]) {
                        resolution = HLSStream.VariantStream.Resolution(width: width, height: height)
                    }
                } else if attributeString.hasPrefix("AVERAGE-BANDWIDTH=") {
                    averageBandwidth = Int(attributeString.replacingOccurrences(of: "AVERAGE-BANDWIDTH=", with: "")) ?? nil
                } else if attributeString.hasPrefix("FRAME-RATE=") {
                    frameRate = Double(attributeString.replacingOccurrences(of: "FRAME-RATE=", with: "")) ?? nil
                }
            }

            // Get the URL of the variant stream (next line)
            guard let streamURLString = nextLine?.trimmingCharacters(in: .whitespacesAndNewlines),
                  let streamURL = URL(string: streamURLString) else {
                return nil
            }

            let mediaPlaylist = HLSStream.MediaPlaylist(playlistURL: streamURL, segments: [], targetDuration: 0, totalDuration: 0, isLive: false, isIFrameOnly: nil, mediaSequence: 0) // Placeholder
            if let bandwidth = bandwidth, let codecs = codecs {
                return HLSStream.VariantStream(resolution: resolution, bandwidth: bandwidth, codecs: codecs, averageBandwidth: averageBandwidth, frameRate: frameRate, segmentList: mediaPlaylist)
            }
            return nil
        }
    }

    private struct AlternateMediaParser {
        func parse(_ line: String) -> HLSStream.AlternateMedia? {
            let mediaAttributes = line.replacingOccurrences(of: "#EXT-X-MEDIA:", with: "").split(separator: ",")
            var mediaType: HLSStream.AlternateMedia.MediaType?
            var groupId: String?
            var name: String?
            var defaultMedia: Bool = false
            var autoselect: Bool = false
            var forced: Bool?
            var characteristics: [String]?
            var uri: URL?

            for attribute in mediaAttributes {
                let attributeString = String(attribute).trimmingCharacters(in: .whitespacesAndNewlines)
                if attributeString.hasPrefix("TYPE=") {
                    let typeString = attributeString.replacingOccurrences(of: "TYPE=", with: "").trimmingCharacters(in: .quotes)
                    switch typeString {
                    case "AUDIO":
                        mediaType = .audio
                    case "SUBTITLES":
                        mediaType = .subtitles
                    case "CLOSED-CAPTIONS":
                        mediaType = .closedCaptions
                    case "VIDEO":
                        mediaType = .video
                    default:
                        break
                    }
                } else if attributeString.hasPrefix("GROUP-ID=") {
                    groupId = attributeString.replacingOccurrences(of: "GROUP-ID=", with: "").trimmingCharacters(in: .quotes)
                } else if attributeString.hasPrefix("NAME=") {
                    name = attributeString.replacingOccurrences(of: "NAME=", with: "").trimmingCharacters(in: .quotes)
                } else if attributeString.hasPrefix("DEFAULT=") {
                    defaultMedia = (attributeString.replacingOccurrences(of: "DEFAULT=", with: "").trimmingCharacters(in: .quotes).uppercased() == "YES")
                } else if attributeString.hasPrefix("AUTOSELECT=") {
                    autoselect = (attributeString.replacingOccurrences(of: "AUTOSELECT=", with: "").trimmingCharacters(in: .quotes).uppercased() == "YES")
                } else if attributeString.hasPrefix("FORCED=") {
                    forced = (attributeString.replacingOccurrences(of: "FORCED=", with: "").trimmingCharacters(in: .quotes).uppercased() == "YES")
                } else if attributeString.hasPrefix("CHARACTERISTICS=") {
                    characteristics = attributeString.replacingOccurrences(of: "CHARACTERISTICS=", with: "").trimmingCharacters(in: .quotes).components(separatedBy: ",")
                } else if attributeString.hasPrefix("URI=") {
                    if let uriString = attributeString.replacingOccurrences(of: "URI=", with: "").trimmingCharacters(in: .quotes).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                       let mediaURI = URL(string: uriString) {
                        uri = mediaURI
                    }
                }
            }

            if let mediaType = mediaType, let groupId = groupId, let name = name {
                return HLSStream.AlternateMedia(type: mediaType, groupId: groupId, name: name, defaultMedia: defaultMedia, autoselect: autoselect, forced: forced, characteristics: characteristics, uri: uri)
            }
            return nil
        }
    }

    private struct TargetDurationParser {
        func parse(_ line: String) -> Double? {
            if let durationString = line.split(separator: ":").last, let duration = Double(durationString) {
                return duration
            }
            return nil
        }
    }

    private struct MediaSequenceParser {
        func parse(_ line: String) -> Int? {
            if let sequenceString = line.split(separator: ":").last, let sequence = Int(sequenceString) {
                return sequence
            }
            return nil
        }
    }

    private struct PlaylistTypeParser {
        func parse(_ line: String) -> Bool? {
            let typeString = line.replacingOccurrences(of: "#EXT-X-PLAYLIST-TYPE:", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
            return typeString == "EVENT" ? true : nil
        }
    }
}
