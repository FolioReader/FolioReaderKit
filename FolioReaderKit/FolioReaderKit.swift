//
//  FolioReaderKit.swift
//  FolioReaderKit
//
//  Created by Heberti Almeida on 08/04/15.
//  Copyright (c) 2015 Folio Reader. All rights reserved.
//

import Foundation

// MARK: - Internal constants

internal let isPad = UIDevice.currentDevice().userInterfaceIdiom == .Pad
internal let isPhone = UIDevice.currentDevice().userInterfaceIdiom == .Phone
internal let isPhone4 = (UIScreen.mainScreen().bounds.size.height == 480)
internal let isPhone5 = (UIScreen.mainScreen().bounds.size.height == 568)

// MARK: - Present Folio Reader

/**
Present a animated login for a Parent View Controller.
*/
public func presentReaderForParentViewController(parentViewController: UIViewController, andConfig config: FolioReaderConfig) {
    presentReaderForParentViewController(parentViewController, animated: true, andConfig: config)
}

/**
Present a Folio Reader for a Parent View Controller.
*/
public func presentReaderForParentViewController(parentViewController: UIViewController, #animated: Bool, andConfig config: FolioReaderConfig) {
    println("present reader")
    
    let reader = FolioReaderContainer()
//    let reader = FolioReaderCenter()
//    let navigationController = UINavigationController(rootViewController: reader)
    parentViewController.presentViewController(reader, animated: animated, completion: nil)
}