//
//  UIMenuItem+CXAImageSupport.m
//  UIMenuItem+CXAImageSupport
//
//  Created by CHEN Xian'an on 1/3/13.
//  Copyright (c) 2013 lazyapps. All rights reserved.
//

#import "UIMenuItem+CXAImageSupport.h"
#import <objc/runtime.h>

#define INVISIBLE_IDENTIFIER @"\uFEFF\u200B"

static NSMutableDictionary *titleImagePairs;
static NSMutableDictionary *titleHidesShadowPairs;

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
    titleImagePairs = [@{} mutableCopy];
    titleHidesShadowPairs = [@{} mutableCopy];
  });
}

+ (void)dealloc
{
  titleImagePairs = nil;
  titleHidesShadowPairs = nil;
}

- (id)cxa_initWithTitle:(NSString *)title
                 action:(SEL)action
                  image:(UIImage *)image
{
  return [self cxa_initWithTitle:title action:action image:image hidesShadow:NO];
}

- (id)cxa_initWithTitle:(NSString *)title
                 action:(SEL)action
                  image:(UIImage *)image
            hidesShadow:(BOOL)hidesShadow
{
  id item = [self initWithTitle:nil action:action];
  if (item)
    [item cxa_setImage:image hidesShadow:hidesShadow forTitle:title];
  
  return item;
}

- (void)cxa_setImage:(UIImage *)image
            forTitle:(NSString *)title
{
  [self cxa_setImage:image hidesShadow:NO forTitle:title];
}

- (void)cxa_setImage:(UIImage *)image
         hidesShadow:(BOOL)hidesShadow
            forTitle:(NSString *)title
{
  if (!title)
    @throw [NSException exceptionWithName:@"UIMenuItem+CXAImageSupport" reason:@"title can't be nil" userInfo:nil];
  
  title = [title cxa_stringByWrappingInvisibleIdentifiers];
  self.title = title;
  titleImagePairs[title] = image;
  titleHidesShadowPairs[title] = hidesShadow ? @YES : @NO;
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

@interface UILabel (CXAImageSupport) @end

@implementation UILabel (CXAImageSupport)

+ (void)load
{
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
}

@end

static void newDrawTextInRect(UILabel *self, SEL _cmd, CGRect rect)
{
  if (![self.text cxa_doesWrapInvisibleIdentifiers] ||
      !titleImagePairs[self.text]){
    origDrawTextInRect(self, @selector(drawTextInRect:), rect);
    return;
  }

  UIImage *img = titleImagePairs[self.text];
  CGSize size = img.size;
  CGPoint point = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
  point.x = ceilf(point.x - size.width/2);
  point.y = ceilf(point.y - size.height/2);
  
  BOOL drawsShadow = ![titleHidesShadowPairs[self.text] boolValue];
  CGContextRef context;
  if (drawsShadow){
    context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, CGSizeMake(0, -1), 0, [[UIColor blackColor] colorWithAlphaComponent:1./3.].CGColor);
  }
  
  [img drawAtPoint:point];
  if (drawsShadow)
    CGContextRestoreGState(context);
}

static void newSetFrame(UILabel *self, SEL _cmd, CGRect rect)
{
  if ([self.text cxa_doesWrapInvisibleIdentifiers] &&
      titleImagePairs[self.text])
    rect = self.superview.bounds;
  
  origSetFrame(self, @selector(setFrame:), rect);
}

static CGSize newSizeWithFont(NSString *self, SEL _cmd, UIFont *font)
{
  if ([self cxa_doesWrapInvisibleIdentifiers] &&
      titleImagePairs[self])
    return [titleImagePairs[self] size];
  
  return origSizeWithFont(self, _cmd, font);
}
