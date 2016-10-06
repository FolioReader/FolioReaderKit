//
//  FolioReaderTests.swift
//  FolioReaderTests
//
//  Created by Brandon Kobilansky on 1/25/16.
//  Copyright © 2016 FolioReader. All rights reserved.
//

@testable import FolioReaderKit

import Quick
import Nimble

class FolioReaderTests: QuickSpec {
    override func spec() {
        context("epub parsing") {
            var subject: FREpubParser!

            beforeEach {
                let path = Bundle(for: type(of: self)).path(forResource: "The Silver Chair", ofType: "epub")!
                subject = FREpubParser()
                let book = subject.readEpub(epubPath: path)
                print(book?.tableOfContents.first?.title)
            }

            it("correctly parses a properly formatted document") {
                expect(subject.book.tableOfContents.count).to(equal(17))
            }
        }
    }
}
