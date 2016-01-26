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
                let path = NSBundle(forClass: self.dynamicType).pathForResource("The Silver Chair", ofType: "epub")!
                subject = FREpubParser()
                subject.readEpub(epubPath: path)
            }

            it("correctly parses a properly formatted document") {
                expect(subject.book.tableOfContents.count).to(equal(17))
            }
        }
    }
}
