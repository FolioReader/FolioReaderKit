//
//  UIMenuItem+CXAImageSupport.h
//  UIMenuItem+CXAImageSupport
//
//  Copyright (c) 2013 CHEN Xian'an <xianan.chen@gmail.com>. All rights reserved.
//  UIMenuItem+CXAImageSupport is released under the MIT license. In short, it's royalty-free but you must you keep the copyright notice in your code or software distribution.
//

#import <UIKit/UIKit.h>

#if !__has_feature(nullability)

#define NS_ASSUME_NONNULL_BEGIN
#define NS_ASSUME_NONNULL_END
#define __nullable

#endif

@class CXAMenuItemSettings;

NS_ASSUME_NONNULL_BEGIN

@interface UIMenuItem (CXAImageSupport)

- (instancetype)cxa_initWithTitle:(NSString *)title action:(SEL)action image:(UIImage *)image DEPRECATED_MSG_ATTRIBUTE("use `-initWithTitle:action:image:` instead.");
- (instancetype)cxa_initWithTitle:(NSString *)title action:(SEL)action settings:(CXAMenuItemSettings *)settings DEPRECATED_MSG_ATTRIBUTE("use `-initWithTitle:settings:` instead.");
- (instancetype)initWithTitle:(NSString *)title action:(SEL)action image:(UIImage *)image;
- (instancetype)initWithTitle:(NSString *)title action:(SEL)action settings:(CXAMenuItemSettings *)settings;
- (void)cxa_setImage:(UIImage *)image;
- (void)cxa_setSettings:(CXAMenuItemSettings *)settings;

@end

// Uses a settings class instead of NSDictionary to avoid misspelled keys
@interface CXAMenuItemSettings : NSObject <NSCopying>

+ (instancetype)settingsWithDictionary:(NSDictionary<NSString *, id> *)dict;

@property (nonatomic, strong) UIImage *image;
@property (nonatomic) BOOL shadowDisabled;
@property (nonatomic, strong) UIColor * __nullable shadowColor; // Default is [[UIColor blackColor] colorWithAlphaComponent:1./3.]
@property (nonatomic) CGFloat shrinkWidth; // For adjustment item width only, will not be preciouse because menu item will keep its minimun width, it's useful for showing some large amount of menu items without expanding.

@end

NS_ASSUME_NONNULL_END

