//
//  Internals.swift
//  MenuItemKit
//
//  Created by CHEN Xian’an on 1/17/16.
//  Copyright © 2016 lazyapps. All rights reserved.
//

import ObjectiveC.runtime

let block_identifier_prefix = "_menuitemkit_block_"

let image_identifier_prefix = block_identifier_prefix + "image_"

func setNewIMPWithBlock<T>(block: T, forSelector selector: Selector, toClass klass: AnyClass) {
  let method = class_getInstanceMethod(klass, selector)
  let imp = imp_implementationWithBlock(unsafeBitCast(block, AnyObject.self))
  if !class_addMethod(klass, selector, imp, method_getTypeEncoding(method)) {
    method_setImplementation(method, imp)
  }
}

func isMenuItemKitSelector(str: String) -> Bool {
  return str.hasPrefix(block_identifier_prefix)
}

func isMenuItemKitSelector(sel: Selector) -> Bool {
  return isMenuItemKitSelector(NSStringFromSelector(sel))
}
