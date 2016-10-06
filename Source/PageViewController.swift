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
    var index = FolioReader.defaults.integer(forKey: kCurrentTOCMenu)
    
    // MARK: Init
    
    override init(transitionStyle style: UIPageViewControllerTransitionStyle, navigationOrientation: UIPageViewControllerNavigationOrientation, options: [String : Any]?) {
        super.init(transitionStyle: style, navigationOrientation: navigationOrientation, options: options)
        
        self.edgesForExtendedLayout = UIRectEdge()
        self.extendedLayoutIncludesOpaqueBars = true
    }

    required init?(coder: NSCoder) {
        fatalError("storyboards are incompatible with truth and beauty")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        segmentedControl = UISegmentedControl(items: segmentedControlItems)
        segmentedControl.addTarget(self, action: #selector(PageViewController.didSwitchMenu(_:)), for: UIControlEvents.valueChanged)
        segmentedControl.selectedSegmentIndex = index
        segmentedControl.setWidth(100, forSegmentAt: 0)
        segmentedControl.setWidth(100, forSegmentAt: 1)
        self.navigationItem.titleView = segmentedControl
        
        viewList = [viewControllerOne, viewControllerTwo]
        
        viewControllerOne.didMove(toParentViewController: self)
        viewControllerTwo.didMove(toParentViewController: self)
        
        self.delegate = self
        self.dataSource = self
        
        self.view.backgroundColor = UIColor.white
        self.setViewControllers([viewList[index]], direction: .forward, animated: false, completion: nil)
        
        // FIXME: This disable scroll because of highlight swipe to delete, if you can fix this would be awesome
        for view in self.view.subviews {
            if view is UIScrollView {
                let scroll = view as! UIScrollView
                scroll.bounces = false
            }
        }
        
        setCloseButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavBar()
    }
    
    func configureNavBar() {
        let navBackground = isNight(readerConfig.nightModeMenuBackground, UIColor.white)
        let tintColor = readerConfig.tintColor
        let navText = isNight(UIColor.white, UIColor.black)
        let font = UIFont(name: "Avenir-Light", size: 17)!
        setTranslucentNavigation(false, color: navBackground, tintColor: tintColor, titleColor: navText, andFont: font)
    }
    
    // MARK: - Segmented control changes
    
    func didSwitchMenu(_ sender: UISegmentedControl) {
        index = sender.selectedSegmentIndex
        let direction: UIPageViewControllerNavigationDirection = index == 0 ? .reverse : .forward
        setViewControllers([viewList[index]], direction: direction, animated: true, completion: nil)
        FolioReader.defaults.set(index, forKey: kCurrentTOCMenu)
    }
    
    // MARK: - Status Bar
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return isNight(.lightContent, .default)
    }
}

// MARK: UIPageViewControllerDelegate

extension PageViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if finished && completed {
            let viewController = pageViewController.viewControllers?.last
            segmentedControl.selectedSegmentIndex = viewList.index(of: viewController!)!
        }
    }
}

// MARK: UIPageViewControllerDataSource

extension PageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        let index = viewList.index(of: viewController)!
        if index == viewList.count - 1 {
            return nil
        }
        
        self.index = self.index + 1
        return viewList[self.index]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        let index = viewList.index(of: viewController)!
        if index == 0 {
            return nil
        }
        
        self.index = self.index - 1
        return viewList[self.index]
    }
}

