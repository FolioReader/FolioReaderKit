//
//  AppDelegate.swift
//  StoryboardExample
//
//  Created by Panajotis Maroungas on 18/08/16.
//  Copyright © 2016 FolioReader. All rights reserved.
//

import UIKit
import FolioReaderKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var epubReaderOne: FolioReaderContainer?
    var epubReaderTwo: FolioReaderContainer?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        self.epubReaderOne?.saveReaderState()
        self.epubReaderTwo?.saveReaderState()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        self.epubReaderOne?.saveReaderState()
        self.epubReaderTwo?.saveReaderState()
    }
}
