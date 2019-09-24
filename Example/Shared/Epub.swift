//
//  Epub.swift
//  Example
//
//  Created by Kevin Delord on 18/05/2017.
//  Copyright © 2017 FolioReader. All rights reserved.
//

import Foundation
import FolioReaderKit

enum Epub: Int {
    case bookOne = 0
    case bookTwo
    case bookThree

    var name: String {
        switch self {
        case .bookOne:      return "The Silver Chair" // standard eBook
        case .bookTwo:      return "The Adventures Of Sherlock Holmes - Adventure I" // audio-eBook
        case .bookThree:    return "accel_encrypted"
        }
    }

    var shouldHideNavigationOnTap: Bool {
        switch self {
        case .bookOne:      return false
        case .bookTwo:      return true
        case .bookThree:    return true
        }
    }

    var scrollDirection: FolioReaderScrollDirection {
        switch self {
        case .bookOne:      return .vertical
        case .bookTwo:      return .horizontal
        case .bookThree:    return .horizontal
        }
    }

    var bookPath: String? {
        return Bundle.main.path(forResource: self.name, ofType: "epub")
    }

    var readerIdentifier: String {
        switch self {
        case .bookOne:      return "READER_ONE"
        case .bookTwo:      return "READER_TWO"
        case .bookThree:    return "READER_THREE"
        }
    }
}
