//
//  UIMenuItem+CXAImageSupport.h
//  UIMenuItem+CXAImageSupport
//
//  Created by CHEN Xian'an on 1/3/13.
//  Copyright (c) 2013 lazyapps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIMenuItem (CXAImageSupport)

- (id)cxa_initWithTitle:(NSString *)title action:(SEL)action image:(UIImage *)image;
- (id)cxa_initWithTitle:(NSString *)title action:(SEL)action image:(UIImage *)image hidesShadow:(BOOL)hidesShadow;
- (void)cxa_setImage:(UIImage *)image forTitle:(NSString *)title;
- (void)cxa_setImage:(UIImage *)image hidesShadow:(BOOL)hidesShadow forTitle:(NSString *)title;

@end
