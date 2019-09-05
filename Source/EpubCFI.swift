//
//  EpubCFI.swift
//  MarathonApp
//
//  Created by David Pei on 8/26/19.
//

import Foundation


/**
The structure derived from standard CFI. CFI details can be found [here]( http://www.idpf.org/epub/linking/cfi/epub-cfi.html#sec-epubcfi-def).

 CFI is a Canonical Fragment Identifier which defines a standardized method for referencing arbitrary content within an EPUB® Publication through the use of fragment identifiers. For example: book.epub#epubcfi(/6/4[chap01ref]!/4[body01]/10[para05]/3:10)
 epubcfi can be considered as an orderd array of html tag element nodes separated by slashes. Essentially, the above cfi should be converted to
 [(6, ""), (4, "chap01ref"), (4, "body01"), (10, "para05"), (3:10)]
 */
public struct CFI: Codable {
    
    /// The basic element of CFI nodes
    struct Node: Codable {
        var index: Int = 0
        var reference: String = ""
    }
    
    private(set) var nodes: [Node] = []
    
    init(nodes: [Node]) {
        self.nodes = nodes
    }
    
    
    /// Initialize CFI by using FolioReader provided information
    ///
    /// - Parameters:
    ///   - nodes: starts with the chapter index and then the DOM tag children indices.
    
    init(nodes: [DOMNode]) {
        nodes.forEach { self.nodes.append(Node(index: $0.index.toCFIIndex, reference: "")) }
    }
    
    // helper functions
    
    var domIndices: [Int] {
        return nodes[2..<nodes.count].map { $0.index.toDOMIndex }
    }
    
    var standardizedFormat: String {
        return nodes.reduce("", { result, node in result + "/\(node.index)" })
    }
}

// The internal node structure especially designed for DOM elements
struct DOMNode: Codable {
    var index: Int
    var tag: String
}



/**
 The class used to parse and generate CFI strings
 
 This class is desigend as the communication between cross-platform CFI strings, CFI objects, and internal DOM objects.
 
 */
class EpubCFI {
    
    private(set) static var packageInfo: [String] = [] {
        didSet {
            packageInfo.enumerated().forEach { _packageInfoDict[$1] = $0 }
        }
    }
    
    private static var _packageInfoDict: [String: Int] = [:]
    
    /// 0 based, incremented by 1
    public static var spineIndex: Int {
        return _packageInfoDict["spine"] ?? 0
    }
    
    static func setPackageInfo(_ info: [String]) {
        packageInfo = info
    }
    
    /// Convert cross platform CFI string to internal CFI structure
    ///
    /// - Parameter cfi: the cross-platform CFI string
    /// - Returns: return the CFI structure if parses fine; nil if fails
    static func parse(cfi: String) -> CFI? {
        // cfi format: #epubcfi(...)
        guard cfi.starts(with: "#epubcfi("),
            let startIndex = cfi.firstIndex(of: "("),
            let endIndex = cfi.firstIndex(of: ")"), startIndex < endIndex else {
                print("not a valid EPUB CFI format")
                return nil
        }
        
        let parts = String(cfi[startIndex..<endIndex]).split(separator: "/")
        let nodes = parts.map { (s) -> CFI.Node in
            guard let nodeString = s as? String else { return CFI.Node() }
            return parseCFINode(cfiNodeStr: nodeString)
        }
        var result = CFI(nodes: nodes)
        return result
    }
    
    
    /// Covert one CFI string snippet to one CFI.Node
    ///
    /// - Parameter cfiNodeStr: CFI string snippet
    /// - Returns: the parsed CFI node; empty CFI.Node if not exists
    static func parseCFINode(cfiNodeStr: String) -> CFI.Node {
        var indexStr = "", refStr = ""
        // Add code to better handle more complex CFI references
        if let start = cfiNodeStr.index(of: "[") {
            
        }
        guard let index = Int(indexStr) else { return CFI.Node() }
        return CFI.Node(index: index.toDOMIndex, reference: refStr)
    }
    
    
    /// Create a CFI object provided by FolioReader information
    ///
    /// - Parameters:
    ///   - chapterIndex: The index of metadata/spine/etc tag found in the OPF file. should start from 0 and increments by 1.
    ///   - odmStr: starts with the chapter index and then the DOM tag children indices.
    /// - Returns: return the generated CFI object; returns nil if data is corrupt
    static func generate(chapterIndex: Int, odmStr: String) -> CFI? {
        guard let data = odmStr.data(using: .utf8) else { return nil }
        do {
            let domNodes = try JSONDecoder().decode([DOMNode].self, from: data)
            let nodes = [DOMNode(index: EpubCFI.spineIndex, tag: ""),
                         DOMNode(index: chapterIndex, tag: "")] + domNodes
            return CFI(nodes: nodes)
        } catch {
            print(error.localizedDescription)
        }
        return nil
    }
}


// MARK: - Int extension
// Coversion between CFI index and DOM/normal index
fileprivate extension Int {
    var toCFIIndex: Int {
        return (self + 1) * 2
    }
    
    var toDOMIndex: Int {
        return self / 2 - 1
    }
}
