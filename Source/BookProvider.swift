//
//  BookProvider.swift
//  FolioReaderKit
//
//  Created by David Pei on 9/24/19.
//

import Foundation

final class BookProvider {
    
    static let shared = BookProvider()
    
    var currentBook = FRBook()
    
    init() {
        URLProtocol.registerClass(BookProviderURLProtocol.self)
    }
}
