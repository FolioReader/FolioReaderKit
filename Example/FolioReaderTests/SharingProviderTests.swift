//
//  SharingProviderTests.swift
//  Example
//
//  Created by Brandon Kobilansky on 1/26/16.
//  Copyright © 2016 FolioReader. All rights reserved.
//

@testable import FolioReaderKit

import Quick
import Nimble

class SharingProviderTests: QuickSpec {
    override func spec() {
        var subject: FolioReaderSharingProvider!

        context("when sharing a document") {
            let activityViewController = UIActivityViewController(activityItems: [], applicationActivities: nil)

            it("sets the subject field") {
                subject = self.providerWithHTML()
                let subjectForActivityType = subject.activityViewController(activityViewController, subjectForActivityType: nil)
                expect(subjectForActivityType).to(equal(subject.subject))
            }

            context("without HTML") {
                beforeEach {
                    subject = self.providerWithoutHTML()
                }

                it("returns text for a mail activity") {
                    let itemForActivityType = subject.activityViewController(activityViewController, itemForActivityType: UIActivity.ActivityType.mail) as? String
                    expect(itemForActivityType).to(equal(subject.text))
                }
            }

            context("with HTML") {
                beforeEach {
                    subject = self.providerWithHTML()
                }

                it("returns HTML for a mail activity") {
                    let itemForActivityType = subject.activityViewController(activityViewController, itemForActivityType: UIActivity.ActivityType.mail) as? String
                    expect(itemForActivityType).to(equal(subject.html))
                }
            }
        }
    }

    func providerWithHTML() -> FolioReaderSharingProvider {
        return FolioReaderSharingProvider(subject: "a subject", text: "some text", html: "<html><body>foo</body></html>")
    }

    func providerWithoutHTML() -> FolioReaderSharingProvider {
        return FolioReaderSharingProvider(subject: "a subject", text: "some text", html: nil)
    }
}

