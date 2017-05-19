//
//  AppDelegate.swift
//  Example
//
//  Created by Heberti Almeida on 08/04/15.
//  Copyright (c) 2015 Folio Reader. All rights reserved.
//

import UIKit
import FolioReaderKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var standardEpub: FolioReaderContainer?
    var audioEpub: FolioReaderContainer?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        /// Save Reader state, book, page and scroll offset.
        self.standardEpub?.saveReaderState()
        self.audioEpub?.saveReaderState()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        /// Save Reader state, book, page and scroll offset.
        self.standardEpub?.saveReaderState()
        self.audioEpub?.saveReaderState()
    }
}
