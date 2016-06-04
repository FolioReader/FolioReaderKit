//
//  UIMenuController.swift
//  MenuItemKit
//
//  Created by CHEN Xian’an on 1/17/16.
//  Copyright © 2016 lazyapps. All rights reserved.
//

import UIKit
import ObjectiveC.runtime

extension UIMenuController {
  
  class func _mik_load() {
    if true {
      let selector = Selector("setMenuItems:")
      let origIMP = class_getMethodImplementation(self, selector)
      typealias IMPType = @convention(c) (AnyObject, Selector, AnyObject) -> ()
      let origIMPC = unsafeBitCast(origIMP, IMPType.self)
      let block: @convention(block) (AnyObject, AnyObject) -> () = {
        if let firstResp = UIResponder.mik_firstResponder {
          swizzleClass(firstResp.dynamicType)
        }
        
        origIMPC($0, selector, $1)
      }
      
      setNewIMPWithBlock(block, forSelector: selector, toClass: self)
    }
    
    if true {
      let selector = #selector(self.setTargetRect(_:inView:))
      let origIMP = class_getMethodImplementation(self, selector)
      typealias IMPType = @convention(c) (AnyObject, Selector, CGRect, UIView) -> ()
      let origIMPC = unsafeBitCast(origIMP, IMPType.self)
      let block: @convention(block) (AnyObject, CGRect, UIView) -> () = {
        if let firstResp = UIResponder.mik_firstResponder {
          swizzleClass(firstResp.dynamicType)
        } else {
          swizzleClass($2.dynamicType)
          // Must call `becomeFirstResponder` since there's no firstResponder yet
          $2.becomeFirstResponder()
        }
        
        origIMPC($0, selector, $1, $2)
      }
      
      setNewIMPWithBlock(block, forSelector: selector, toClass: self)
    }
  }
  
}

extension UILabel {
  
  class func _mik_load() {
    let selector = #selector(self.drawTextInRect(_:))
    let origIMP = class_getMethodImplementation(self, selector)
    typealias IMPType = @convention(c) (UILabel, Selector, CGRect) -> ()
    let origIMPC = unsafeBitCast(origIMP, IMPType.self)
    let block: @convention(block) (UILabel, CGRect) -> () = { label, rect in
      guard
        let text = label.text,
        let item = UIMenuController.sharedMenuController().findMenuItemBySelector(text)
      else {
        origIMPC(label, selector, rect)
        return
      }
      
      let image = item.imageBox.value
      let point = CGPoint(
        x: (label.bounds.width  - (image?.size.width ?? 0))  / 2,
        y: (label.bounds.height - (image?.size.height ?? 0)) / 2
      )
      image?.drawAtPoint(point)
    }
    
    setNewIMPWithBlock(block, forSelector: selector, toClass: self)
  }
  
}

extension NSString {
  
  class func _mik_load() {
    let selector = #selector(self.sizeWithAttributes(_:))
    let origIMP = class_getMethodImplementation(self, selector)
    typealias IMPType = @convention(c) (NSString, Selector, AnyObject) -> CGSize
    let origIMPC = unsafeBitCast(origIMP, IMPType.self)
    let block: @convention(block) (NSString, AnyObject) -> CGSize = { str, attr in
      let selStr = str as String
      if isMenuItemKitSelector(selStr),
         let item = UIMenuController.sharedMenuController().findMenuItemBySelector(selStr)
      {
        return item.imageBox.value?.size ?? CGSizeZero
      }
      
      return origIMPC(str, selector, attr)
    }
    
    setNewIMPWithBlock(block, forSelector: selector, toClass: self)
  }
  
}

extension UIMenuController {
  
  func findMenuItemBySelector(selector: Selector?) -> UIMenuItem? {
    guard let sel = selector else { return nil }
    for item in menuItems ?? [] where sel_isEqual(item.action, sel) {
      return item
    }
    
    return nil
  }
  
  func findMenuItemBySelector(selector: String?) -> UIMenuItem? {
    guard let selStr = selector else { return nil }
    return findMenuItemBySelector(NSSelectorFromString(selStr))
  }
  
}

private extension UIMenuController {
  
  // This is inspired by https://github.com/steipete/PSMenuItem
  static func swizzleClass(klass: AnyClass) {
    objc_sync_enter(klass)
    defer { objc_sync_exit(klass) }
    let key: StaticString = #function
    guard objc_getAssociatedObject(klass, key.utf8Start) == nil else { return }
    
    if true {
      // swizzle canBecomeFirstResponder
      let selector = #selector(UIResponder.canBecomeFirstResponder)
      let block: @convention(block) (AnyObject) -> Bool = { _ in true }
      setNewIMPWithBlock(block, forSelector: selector, toClass: klass)
    }
    
    if true {
      // swizzle canPerformAction:withSender:
      let selector = #selector(UIResponder.canPerformAction(_:withSender:))
      let origIMP = class_getMethodImplementation(klass, selector)
      typealias IMPType = @convention(c) (AnyObject, Selector, Selector, AnyObject) -> Bool
      let origIMPC = unsafeBitCast(origIMP, IMPType.self)
      let block: @convention(block) (AnyObject, Selector, AnyObject) -> Bool = {
        return isMenuItemKitSelector($1) ? true : origIMPC($0, selector, $1, $2)
      }
      
      setNewIMPWithBlock(block, forSelector: selector, toClass: klass)
    }
    
    if true {
      // swizzle methodSignatureForSelector:
      let selector = NSSelectorFromString("methodSignatureForSelector:")
      let origIMP = class_getMethodImplementation(klass, selector)
      typealias IMPType = @convention(c) (AnyObject, Selector, Selector) -> AnyObject
      let origIMPC = unsafeBitCast(origIMP, IMPType.self)
      let block: @convention(block) (AnyObject, Selector) -> AnyObject = {
        if isMenuItemKitSelector($1) {
          // `NSMethodSignature` is not allowed in Swift, this is a workaround
          return NSObject.performSelector(NSSelectorFromString("_mik_fakeSignature")).takeUnretainedValue()
        }
        
        return origIMPC($0, selector, $1)
      }
      
      setNewIMPWithBlock(block, forSelector: selector, toClass: klass)
    }
    
    if true {
      // swizzle forwardInvocation:
      // `NSInvocation` is not allowed in Swift, so we just use AnyObject
      let selector = NSSelectorFromString("forwardInvocation:")
      let origIMP = class_getMethodImplementation(klass, selector)
      typealias IMPType = @convention(c) (AnyObject, Selector, AnyObject) -> AnyObject
      let origIMPC = unsafeBitCast(origIMP, IMPType.self)
      let block: @convention(block) (AnyObject, AnyObject) -> () = {
        if isMenuItemKitSelector($1.selector) {
          guard let item = sharedMenuController().findMenuItemBySelector($1.selector) else { return }
          item.handlerBox.value?(item)
        } else {
          origIMPC($0, selector, $1)
        }
      }
      
      setNewIMPWithBlock(block, forSelector: selector, toClass: klass)
    }
    
    objc_setAssociatedObject(klass, key.utf8Start, true, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
  }
  
}

// MARK: Helper to find first responder
// Source: http://stackoverflow.com/a/14135456/395213
private var _currentFirstResponder: UIResponder? = nil

private extension UIResponder {
  
  static var mik_firstResponder: UIResponder? {
    _currentFirstResponder = nil
    UIApplication.sharedApplication().sendAction(#selector(self.mik_findFirstResponder(_:)), to: nil, from: nil, forEvent: nil)
    return _currentFirstResponder
  }
  
  @objc func mik_findFirstResponder(sender: AnyObject) {
    _currentFirstResponder = self
  }
  
}
