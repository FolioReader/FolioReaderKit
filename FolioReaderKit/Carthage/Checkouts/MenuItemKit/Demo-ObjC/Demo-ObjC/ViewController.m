//
//  ViewController.m
//  Demo-ObjC
//
//  Created by CHEN Xian’an on 1/17/16.
//  Copyright © 2016 lazyapps. All rights reserved.
//

#import "ViewController.h"
@import MenuItemKit;

@interface ViewController ()

@property (strong, nonatomic) IBOutlet UIButton *button;

@end

@implementation ViewController

- (IBAction)tapButton:(id)sender
{
  UIMenuController *controller = [UIMenuController sharedMenuController];
  __weak typeof(self) _self = self;
  UIMenuItem *textItem = [[UIMenuItem alloc] initWithTitle:@"Text" handler:^(UIMenuItem * _Nonnull item) {
    [_self showAlertWithTitle:@"Text Item tapped"];
  }];
  
  UIImage *image = [UIImage imageNamed:@"Image"];
  UIMenuItem *imageItem = [[UIMenuItem alloc]
  initWithImage:image handler:^(UIMenuItem * _Nonnull item) {
    [_self showAlertWithTitle:@"Image Item Tapped"];
  }];
  
  UIMenuItem *nextItem = [[UIMenuItem alloc] initWithTitle:@"Show More Items..." handler:^(UIMenuItem * _Nonnull item) {
    MenuItemHandler handler = ^(UIMenuItem * _Nonnull item) { [_self showAlertWithTitle:[item.title stringByAppendingString:@" Tapped"]]; };
    UIMenuItem *item1 = [[UIMenuItem alloc] initWithTitle:@"1" handler:handler];
    UIMenuItem *item2 = [[UIMenuItem alloc] initWithTitle:@"2" handler:handler];
    UIMenuItem *item3 = [[UIMenuItem alloc] initWithTitle:@"3" handler:handler];
    controller.menuItems = @[item1, item2, item3];
    [controller setMenuVisible:YES animated:YES];
  }];
  
  controller.menuItems = @[textItem, imageItem, nextItem];
  [controller setTargetRect:self.button.bounds inView:self.button];
  [controller setMenuVisible:YES animated:YES];
}

- (void)showAlertWithTitle:(NSString *)title
{
  UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
  UIAlertAction *action = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}];
  [alertVC addAction:action];
  [self presentViewController:alertVC animated:YES completion:nil];
}

@end
