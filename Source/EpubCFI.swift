//
//  EpubCFI.swift
//  MarathonApp
//
//  Created by David Pei on 8/26/19.
//

import Foundation

public struct CFI: Codable {
    var content: Int = 0
    var spine: Int = 0
    var page: Int = 0
    var paragraph: Int = 0
}

class EpubCFI {
    static func parse(cfi: String) -> CFI? {
        // cfi format: #epubcfi(...)
        guard cfi.starts(with: "#epubcfi("),
            let startIndex = cfi.firstIndex(of: "("),
            let endIndex = cfi.firstIndex(of: ")"), startIndex < endIndex else {
                print("not a valid EPUB CFI format")
                return nil
        }
        
        // 0: empty; 1: content index in opf; 2: spine index; 3: page index; 4: p tag index
        let parts = String(cfi[startIndex..<endIndex]).split(separator: "/")
        let indices = parts.map { (s) -> Int in
            return (Int(String(s)) ?? 0) / 2
        }
        let result = CFI(content: indices[1], spine: indices[2], page: indices[3], paragraph: indices[4])
        return result
    }
}
