//
//  CXAAppDelegate.m
//  UIMenuItem+CXAImageSupport
//
//  Created by CHEN Xian'an on 1/3/13.
//  Copyright (c) 2013 lazyapps. All rights reserved.
//

#import "CXAAppDelegate.h"
#import "CXADemoViewController.h"

@implementation CXAAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  self.window.rootViewController = [[CXADemoViewController alloc] init];
  [self.window makeKeyAndVisible];
  
  return YES;
}

@end
