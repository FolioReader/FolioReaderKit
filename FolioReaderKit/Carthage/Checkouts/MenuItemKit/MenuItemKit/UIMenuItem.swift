//
//  UIMenuItem.swift
//  MenuItemKit
//
//  Created by CHEN Xian’an on 1/16/16.
//  Copyright © 2016 lazyapps. All rights reserved.
//

import UIKit
import ObjectiveC.runtime

public extension UIMenuItem {
  
  convenience init(title: String, handler: MenuItemHandler) {
    self.init(title: title, action: Selector(block_identifier_prefix + NSUUID.stripedString + ":"))
    handlerBox.value = handler
  }
  
  convenience init(image: UIImage, handler: MenuItemHandler) {
    let selector = image_identifier_prefix + NSUUID.stripedString + ":"
    self.init(title: selector, action: Selector(selector))
    imageBox.value = image
    handlerBox.value = handler
  }
  
}

extension UIMenuItem {
  
  var imageBox: Box<UIImage?> {
    let key: StaticString = #function
    return associatedBoxForKey(key, initialValue: { nil })
  }
  
  var handlerBox: Box<MenuItemHandler?> {
    let key: StaticString = #function
    return associatedBoxForKey(key, initialValue: { nil })
  }
  
  func associatedBoxForKey<T>(key: StaticString, initialValue: () -> T) -> Box<T> {
    guard let box = objc_getAssociatedObject(self, key.utf8Start) as? Box<T> else {
      let box = Box(initialValue())
      objc_setAssociatedObject(self, key.utf8Start, box as AnyObject, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
      return box
    }
    
    return box
  }
  
}

// MARK: Box wrapper
final class Box<T> {
  
  var value: T
  
  init(_ val: T) {
    value = val
  }
  
}

// MARK: NSUUID
private extension NSUUID {
  
  static var stripedString: String {
    return NSUUID().UUIDString.stringByReplacingOccurrencesOfString("-", withString: "_")
  }
  
}
