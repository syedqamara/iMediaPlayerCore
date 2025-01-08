// The Swift Programming Language
// https://docs.swift.org/swift-book

import AVFoundation

extension String {
    func maskify(_ string:String) -> String {
      var returnedString = string
      let range = string.startIndex..<string.index(string.endIndex, offsetBy: -4)
      let replacement = String(repeating: "#", count: string.count - 4)
      returnedString.replaceSubrange(range, with: replacement)
      return returnedString
    }
}

