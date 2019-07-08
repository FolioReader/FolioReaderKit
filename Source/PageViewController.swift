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
    var index: Int
    fileprivate var readerConfig: FolioReaderConfig
    fileprivate var folioReader: FolioReader

    // MARK: Init

    init(folioReader: FolioReader, readerConfig: FolioReaderConfig) {
        self.folioReader = folioReader
        self.readerConfig = readerConfig
        self.index = self.folioReader.currentMenuIndex
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)

        self.edgesForExtendedLayout = UIRectEdge()
        self.extendedLayoutIncludesOpaqueBars = true
    }

    required init?(coder: NSCoder) {
        fatalError("storyboards are incompatible with truth and beauty")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        segmentedControl = UISegmentedControl(items: segmentedControlItems)
        segmentedControl.addTarget(self, action: #selector(PageViewController.didSwitchMenu(_:)), for: UIControl.Event.valueChanged)
        segmentedControl.selectedSegmentIndex = index
        segmentedControl.setWidth(100, forSegmentAt: 0)
        segmentedControl.setWidth(100, forSegmentAt: 1)
        self.navigationItem.titleView = segmentedControl

        viewList = [viewControllerOne, viewControllerTwo]

        viewControllerOne.didMove(toParent: self)
        viewControllerTwo.didMove(toParent: self)

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

        self.setCloseButton(withConfiguration: self.readerConfig)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavBar()
    }

    func configureNavBar() {
        let navBackground = self.folioReader.isNight(self.readerConfig.nightModeMenuBackground,self.readerConfig.daysModeNavBackground)
        let tintColor = self.readerConfig.tintColor
        let navText = self.folioReader.isNight(UIColor.white, UIColor.black)
        let font = UIFont(name: "Avenir-Light", size: 17)!
        setTranslucentNavigation(false, color: navBackground, tintColor: tintColor, titleColor: navText, andFont: font)
    }

    // MARK: - Segmented control changes

    @objc func didSwitchMenu(_ sender: UISegmentedControl) {
        self.index = sender.selectedSegmentIndex
        let direction: UIPageViewController.NavigationDirection = (index == 0 ? .reverse : .forward)
        setViewControllers([viewList[index]], direction: direction, animated: true, completion: nil)
        self.folioReader.currentMenuIndex = index
    }

    // MARK: - Status Bar

    override var preferredStatusBarStyle : UIStatusBarStyle {
        return self.folioReader.isNight(.lightContent, .default)
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

