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
            var epubPath: String!

            beforeEach {
                guard let path = Bundle.main.path(forResource: "The Silver Chair", ofType: "epub") else {
                    fail("Could not read the epub file")
                    return
                }

                subject = FREpubParser()
                epubPath = path

                do {
                    let book = try subject.readEpub(epubPath: epubPath)
                    print(book.tableOfContents.first!.title)
                } catch {
                    fail("Error: \(error.localizedDescription)")
                }
            }

            it("flat table of contents") {
                expect(subject.flatTOC.count).to(equal(17))
            }

            it("parses table of contents") {
                expect(subject.book.tableOfContents.count).to(equal(17))
            }

            it("parses cover image") {
                guard let coverImage = subject.book.coverImage, let fromFileImage = UIImage(contentsOfFile: coverImage.fullHref) else {
                    fail("Could not read the cover image")
                    return
                }

                do {
                    let parsedImage = try subject.parseCoverImage(epubPath)
                    let data1 = parsedImage.pngData()
                    let data2 = fromFileImage.pngData()
                    expect(data1).to(equal(data2))
                } catch {
                    fail("Error: \(error.localizedDescription)")
                }
            }

            it("parses book title") {
                do {
                    let title = try subject.parseTitle(epubPath)
                    expect(title).to(equal("The Silver Chair"))
                } catch {
                    fail("Error: \(error.localizedDescription)")
                }
            }

            it("parses author name") {
                do {
                    let name = try subject.parseAuthorName(epubPath)
                    expect(name).to(equal("C. S. Lewis"))
                } catch {
                    fail("Error: \(error.localizedDescription)")
                }
            }
        }
    }
}
