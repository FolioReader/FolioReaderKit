//
//  Swizzlings.m
//  MenuItemKit
//
//  Created by CHEN Xian’an on 1/17/16.
//  Copyright © 2016 lazyapps. All rights reserved.
//

@import UIKit;

@implementation NSObject (MenuItemKit)

+ (void)load
{
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    for (id klass in @[[UIMenuController class], [UILabel class], [NSString class]]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
      [klass performSelector:NSSelectorFromString(@"_mik_load")];
#pragma clang diagnostic pop
    }
  });
}

+ (NSMethodSignature *)_mik_fakeSignature
{
  return [NSMethodSignature signatureWithObjCTypes:"v@:@"];
}



@end