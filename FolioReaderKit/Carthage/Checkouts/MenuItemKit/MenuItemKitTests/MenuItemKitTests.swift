//
//  MenuItemKitTests.swift
//  MenuItemKitTests
//
//  Created by CHEN Xian’an on 1/16/16.
//  Copyright © 2016 lazyapps. All rights reserved.
//

import XCTest
@testable import MenuItemKit

class MenuItemKitTests: XCTestCase {
    
  func testConvenienceInit() {
    let blockItem = UIMenuItem(title: "A", handler: { _ in })
    XCTAssertTrue(NSStringFromSelector(blockItem.action).hasPrefix(block_identifier_prefix))
    let imageItem = UIMenuItem(image: UIImage(), handler: { _ in })
    XCTAssertTrue(NSStringFromSelector(imageItem.action).hasPrefix(image_identifier_prefix))
  }

}
