//
//  PageViewController.swift
//  FolioReaderKit
//
//  Created by Heberti Almeida on 14/07/16.
//  Copyright © 2016 FolioReader. All rights reserved.
//

import UIKit

class PageViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    var segmentedControl: UISegmentedControl!
    var viewList = NSArray()
    var segmentedControlItems = [String]()
    var viewControllerOne: UIViewController!
    var viewControllerTwo: UIViewController!
    var index = 0
    
    override init(transitionStyle style: UIPageViewControllerTransitionStyle, navigationOrientation: UIPageViewControllerNavigationOrientation, options: [String : AnyObject]?) {
        super.init(transitionStyle: style, navigationOrientation: navigationOrientation, options: options)
        
        self.edgesForExtendedLayout = .None
        self.extendedLayoutIncludesOpaqueBars = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        segmentedControl = UISegmentedControl(items: segmentedControlItems)
        segmentedControl.addTarget(self, action: #selector(PageViewController.didSwitchMenu(_:)), forControlEvents: UIControlEvents.ValueChanged)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.setWidth(100, forSegmentAtIndex: 0)
        segmentedControl.setWidth(100, forSegmentAtIndex: 1)
        self.navigationItem.titleView = segmentedControl
        
        viewList = [viewControllerOne, viewControllerTwo]
        
        viewControllerOne.didMoveToParentViewController(self)
        viewControllerTwo.didMoveToParentViewController(self)
        
        self.delegate = self
        self.dataSource = self
        self.view.backgroundColor = UIColor.whiteColor()
        self.setViewControllers([viewControllerOne], direction: .Forward, animated: false, completion: nil)
        
        setCloseButton()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        configureNavBar()
    }
    
    func configureNavBar() {
        let navBackground = isNight(readerConfig.nightModeMenuBackground, UIColor.whiteColor())
        let tintColor = readerConfig.tintColor
        let navText = isNight(UIColor.whiteColor(), UIColor.blackColor())
        let font = UIFont(name: "Avenir-Light", size: 17)!
        setTranslucentNavigation(false, color: navBackground, tintColor: tintColor, titleColor: navText, andFont: font)
    }
    
    // MARK: - Page View Controller Data Source
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        let index = viewList.indexOfObject(viewController)
        if index == viewList.count - 1 {
            return nil
        }
        
        self.index = self.index + 1
        return self.viewControllerAtIndex(self.index)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        let index = viewList.indexOfObject(viewController)
        if index == 0 {
            return nil
        }
        
        self.index = self.index - 1
        return self.viewControllerAtIndex(self.index)
    }
    
    func viewControllerAtIndex(index: Int) -> UIViewController! {
        switch index {
        case 0:
            return viewControllerOne
        case 1:
            return viewControllerTwo
        default:
            return nil
        }
    }
    
    // MARK: - Page View Controller Delegate
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if finished && completed {
            let viewController = pageViewController.viewControllers?.last
            segmentedControl.selectedSegmentIndex = viewList.indexOfObject(viewController!)
        }
    }
    
    // MARK: - Segmented control changes
    
    func didSwitchMenu(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            self.index = 0
            self.setViewControllers([viewControllerOne], direction: .Reverse, animated: true, completion: nil)
        case 1:
            self.index = 1
            self.setViewControllers([viewControllerTwo], direction: .Forward, animated: true, completion: nil)
        default:
            break
        }
    }
    
    // MARK: - Status Bar
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return isNight(.LightContent, .Default)
    }
}