//
//  PageViewController.swift
//  FolioReaderKit
//
//  Created by Heberti Almeida on 14/07/16.
//  Copyright © 2016 FolioReader. All rights reserved.
//

import UIKit

class PageViewController: UIPageViewController {
    
    var segmentedControl: UISegmentedControl!
    var viewList = [UIViewController]()
    var segmentedControlItems = [String]()
    var viewControllerOne: UIViewController!
    var viewControllerTwo: UIViewController!
    var index = FolioReader.defaults.integerForKey(kCurrentTOCMenu)
    
    // MARK: Init
    
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
        segmentedControl.selectedSegmentIndex = index
        segmentedControl.setWidth(100, forSegmentAtIndex: 0)
        segmentedControl.setWidth(100, forSegmentAtIndex: 1)
        self.navigationItem.titleView = segmentedControl
        
        viewList = [viewControllerOne, viewControllerTwo]
        
        viewControllerOne.didMoveToParentViewController(self)
        viewControllerTwo.didMoveToParentViewController(self)
        
        self.delegate = self
        self.dataSource = self
        
        self.view.backgroundColor = UIColor.whiteColor()
        self.setViewControllers([viewList[index]], direction: .Forward, animated: false, completion: nil)
        
        // FIXME: This disable scroll because of highlight swipe to delete, if you can fix this would be awesome
        for view in self.view.subviews {
            if view is UIScrollView {
                let scroll = view as! UIScrollView
                scroll.bounces = false
            }
        }
        
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
    
    // MARK: - Segmented control changes
    
    func didSwitchMenu(sender: UISegmentedControl) {
        index = sender.selectedSegmentIndex
        let direction: UIPageViewControllerNavigationDirection = index == 0 ? .Reverse : .Forward
        setViewControllers([viewList[index]], direction: direction, animated: true, completion: nil)
        FolioReader.defaults.setInteger(index, forKey: kCurrentTOCMenu)
    }
    
    // MARK: - Status Bar
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return isNight(.LightContent, .Default)
    }
}

// MARK: UIPageViewControllerDelegate

extension PageViewController: UIPageViewControllerDelegate {
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if finished && completed {
            let viewController = pageViewController.viewControllers?.last
            segmentedControl.selectedSegmentIndex = viewList.indexOf(viewController!)!
        }
    }
}

// MARK: UIPageViewControllerDataSource

extension PageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        let index = viewList.indexOf(viewController)!
        if index == viewList.count - 1 {
            return nil
        }
        
        self.index = self.index + 1
        return viewList[self.index]
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        let index = viewList.indexOf(viewController)!
        if index == 0 {
            return nil
        }
        
        self.index = self.index - 1
        return viewList[self.index]
    }
}

