//
//  UIMenuItem+CXAImageSupport.m
//  UIMenuItem+CXAImageSupport
//
//  Copyright (c) 2013 CHEN Xian'an <xianan.chen@gmail.com>. All rights reserved.
//  UIMenuItem+CXAImageSupport is released under the MIT license. In short, it's royalty-free but you must you keep the copyright notice in your code or software distribution.
//

#import "UIMenuItem+CXAImageSupport.h"
#import <objc/runtime.h>

#define INVISIBLE_IDENTIFIER @"\uFEFF\u200B"

static NSMutableDictionary<NSString *, CXAMenuItemSettings *> *titleSettingsPairs;

@interface NSString (CXAImageSupport)

- (NSString *)cxa_stringByWrappingInvisibleIdentifiers;
- (BOOL)cxa_doesWrapInvisibleIdentifiers;

@end

#pragma mark - UIMenuItem CXAImageSupport category
@implementation UIMenuItem (CXAImageSupport)

+ (void)load
{
  static dispatch_once_t once;
  dispatch_once(&once, ^{
    titleSettingsPairs = [NSMutableDictionary dictionary];
  });
}

+ (void)dealloc
{
  titleSettingsPairs = nil;
}

- (instancetype)cxa_initWithTitle:(NSString *)title
                           action:(SEL)action
                            image:(UIImage *)image
{
  return [self initWithTitle:title action:action image:image];
}

- (instancetype)cxa_initWithTitle:(NSString *)title
                           action:(SEL)action
                         settings:(CXAMenuItemSettings *)settings
{
  return [self initWithTitle:title action:action settings:settings];
}

- (instancetype)initWithTitle:(NSString *)title
                       action:(SEL)action
                        image:(UIImage *)image
{
  return [self initWithTitle:title action:action settings:[CXAMenuItemSettings settingsWithDictionary:@{@"image" : image}]];
}

- (instancetype)initWithTitle:(NSString *)title
                       action:(SEL)action
                     settings:(CXAMenuItemSettings *)settings
{
  id item = [self initWithTitle:title action:action];
  if (!item)
    return nil;
  
  [item cxa_setSettings:settings];
  return item;
}

- (void)cxa_setImage:(UIImage *)image
{
  [self cxa_setSettings:[CXAMenuItemSettings settingsWithDictionary:@{@"image" : image}]];
}

- (void)cxa_setSettings:(CXAMenuItemSettings *)settings
{
  if (!self.title)
    @throw [NSException exceptionWithName:@"UIMenuItem+CXAImageSupport" reason:@"title can't be nil. Assign your item a title before assigning settings." userInfo:nil];
  
  if (![self.title cxa_doesWrapInvisibleIdentifiers])
    self.title = [self.title cxa_stringByWrappingInvisibleIdentifiers];
  
  titleSettingsPairs[self.title] = [settings copy];
}

@end

#pragma mark - NSString helper category
@implementation NSString (CXAImageSupport)

- (NSString *)cxa_stringByWrappingInvisibleIdentifiers
{
  return [NSString stringWithFormat:@"%@%@%@", INVISIBLE_IDENTIFIER, self, INVISIBLE_IDENTIFIER];
}

- (BOOL)cxa_doesWrapInvisibleIdentifiers
{
  BOOL doesStartMatch = [self rangeOfString:INVISIBLE_IDENTIFIER options:NSAnchoredSearch].location != NSNotFound;
  if (!doesStartMatch)
    return NO;
  
  BOOL doesEndMatch = [self rangeOfString:INVISIBLE_IDENTIFIER options:NSAnchoredSearch | NSBackwardsSearch].location != NSNotFound;
  return doesEndMatch;
}

@end

#pragma mark - Method swizzling

static void (*origDrawTextInRect)(id, SEL, CGRect);
static void newDrawTextInRect(id, SEL, CGRect);
static void (*origSetFrame)(id, SEL, CGRect);
static void newSetFrame(id, SEL, CGRect);
static CGSize (*origSizeWithFont)(id, SEL, id);
static CGSize newSizeWithFont(id, SEL, id);
static CGSize (*origSizeWithAttributes)(id, SEL, id);
static CGSize newSizeWithAttributes(id, SEL, id);

@interface UILabel (CXAImageSupport) @end

@implementation UILabel (CXAImageSupport)

+ (void)load
{
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    Method origMethod = class_getInstanceMethod(self, @selector(drawTextInRect:));
    origDrawTextInRect = (void *)method_getImplementation(origMethod);
    if (!class_addMethod(self, @selector(drawTextInRect:), (IMP)newDrawTextInRect, method_getTypeEncoding(origMethod)))
      method_setImplementation(origMethod, (IMP)newDrawTextInRect);
    
    origMethod = class_getInstanceMethod(self, @selector(setFrame:));
    origSetFrame = (void *)method_getImplementation(origMethod);
    if (!class_addMethod(self, @selector(setFrame:), (IMP)newSetFrame, method_getTypeEncoding(origMethod)))
      method_setImplementation(origMethod, (IMP)newSetFrame);
    
    origMethod = class_getInstanceMethod([NSString class], @selector(sizeWithFont:));
    origSizeWithFont = (void *)method_getImplementation(origMethod);
    if (!class_addMethod([NSString class], @selector(sizeWithFont:), (IMP)newSizeWithFont, method_getTypeEncoding(origMethod)))
      method_setImplementation(origMethod, (IMP)newSizeWithFont);
    
    origMethod = class_getInstanceMethod([NSString class], @selector(sizeWithAttributes:));
    origSizeWithAttributes = (void *)method_getImplementation(origMethod);
    if (!class_addMethod([NSString class], @selector(sizeWithAttributes:), (IMP)newSizeWithAttributes, method_getTypeEncoding(origMethod)))
      method_setImplementation(origMethod, (IMP)newSizeWithAttributes);

  });
}

@end

@implementation CXAMenuItemSettings

+ (instancetype)settingsWithDictionary:(NSDictionary<NSString *, id> *)dict
{
  CXAMenuItemSettings *settings = [CXAMenuItemSettings new];
  [settings setValuesForKeysWithDictionary:dict];
  
  return settings;
}

- (id)copyWithZone:(NSZone *)zone
{
  CXAMenuItemSettings *settings = [CXAMenuItemSettings new];
  settings.image = self.image;
  settings.shadowDisabled = self.shadowDisabled;
  settings.shadowColor = self.shadowColor;
  settings.shrinkWidth = self.shrinkWidth;
  
  return settings;
}

@end

static void newDrawTextInRect(UILabel *self, SEL _cmd, CGRect rect)
{
  if (![self.text cxa_doesWrapInvisibleIdentifiers] ||
      !titleSettingsPairs[self.text]){
    origDrawTextInRect(self, @selector(drawTextInRect:), rect);
    return;
  }

  UIImage *img = [titleSettingsPairs[self.text] image];
  CGSize size = img.size;
  CGPoint point = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
  point.x = ceilf(point.x - size.width/2);
  point.y = ceilf(point.y - size.height/2);
  
  BOOL drawsShadow = ![titleSettingsPairs[self.text] shadowDisabled];
  CGContextRef context = UIGraphicsGetCurrentContext();
  if (drawsShadow){
    CGContextSaveGState(context);
    UIColor *shadowColor = [titleSettingsPairs[self.text] shadowColor] ?: [[UIColor blackColor] colorWithAlphaComponent:1./3.];
    CGContextSetShadowWithColor(context, CGSizeMake(0, -1), 0, shadowColor.CGColor);
  }
  
  [img drawAtPoint:point];
  if (drawsShadow)
    CGContextRestoreGState(context);
}

static void newSetFrame(UILabel *self, SEL _cmd, CGRect rect)
{
  if ([self.text cxa_doesWrapInvisibleIdentifiers] &&
      titleSettingsPairs[self.text])
    rect = self.superview.bounds;
  
  origSetFrame(self, @selector(setFrame:), rect);
}

static CGSize newSizeWithFont(NSString *self, SEL _cmd, UIFont *font)
{
  if ([self cxa_doesWrapInvisibleIdentifiers] &&
      titleSettingsPairs[self]){
    CGSize size = [[titleSettingsPairs[self] image] size];
    size.width -= [titleSettingsPairs[self] shrinkWidth];
    return size;
  }
  
  return origSizeWithFont(self, _cmd, font);
}

static CGSize newSizeWithAttributes(NSString *self, SEL _cmd, NSDictionary *attributes)
{
  if ([self cxa_doesWrapInvisibleIdentifiers] &&
      titleSettingsPairs[self]){
    CGSize size = [[titleSettingsPairs[self] image] size];
    size.width -= [titleSettingsPairs[self] shrinkWidth];
    return size;
  }
  
  return origSizeWithAttributes(self, _cmd, attributes);
}
