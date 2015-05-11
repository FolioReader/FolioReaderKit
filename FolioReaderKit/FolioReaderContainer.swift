//
//  FolioReaderContainer.swift
//  FolioReaderKit
//
//  Created by Heberti Almeida on 15/04/15.
//  Copyright (c) 2015 Folio Reader. All rights reserved.
//

import UIKit
import QuartzCore

var readerConfig: FolioReaderConfig!
var epubPath: String?
var book: FRBook!

enum SlideOutState {
    case BothCollapsed
    case LeftPanelExpanded
    case Expanding
    
    init () {
        self = .BothCollapsed
    }
}

protocol FolioReaderContainerDelegate {
    /**
    Notifies that the menu was expanded.
    */
    func container(didExpandLeftPanel sidePanel: FolioReaderSidePanel)
    
    /**
    Notifies that the menu was closed.
    */
    func container(didCollapseLeftPanel sidePanel: FolioReaderSidePanel)
    
    /**
    Notifies when the user selected some item on menu.
    */
    func container(sidePanel: FolioReaderSidePanel, didSelectRowAtIndexPath indexPath: NSIndexPath, withTocReference reference: FRTocReference)
}

class FolioReaderContainer: UIViewController,  UIGestureRecognizerDelegate, FolioReaderSidePanelDelegate {
    var delegate: FolioReaderContainerDelegate!
    var centerNavigationController: UINavigationController!
    var centerViewController: FolioReaderCenter!
    var leftViewController: FolioReaderSidePanel!
    let centerPanelExpandedOffset: CGFloat = 70
    var currentState = SlideOutState()
    var currentSelectedIndex: NSIndexPath!
    
    // MARK: - Init
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(config configOrNil: FolioReaderConfig!, epubPath epubPathOrNil: String? = nil) {
        readerConfig = configOrNil
        epubPath = epubPathOrNil
        super.init(nibName: nil, bundle: kFrameworkBundle)
        
        // Init with empty book
        book = FRBook()
    }
    
    // MARK: - View life cicle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        centerViewController = FolioReaderCenter()
        centerViewController.folioReaderContainer = self
        centerNavigationController = UINavigationController(rootViewController: centerViewController)
        centerNavigationController.setNavigationBarHidden(true, animated: false)
        view.addSubview(centerNavigationController.view)
        addChildViewController(centerNavigationController)
        centerNavigationController.didMoveToParentViewController(self)
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "handlePanGesture:")
        centerNavigationController.view.addGestureRecognizer(panGestureRecognizer)

        // Read async book
        if (epubPath != nil) {
            let priority = DISPATCH_QUEUE_PRIORITY_HIGH
            dispatch_async(dispatch_get_global_queue(priority, 0), { () -> Void in
                book = FREpubParser().readEpub(epubPath: epubPath!)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.centerViewController.reloadData()
                })
            })
        } else {
            println("Epub path is nil.")
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        showShadowForCenterViewController(true)
    }
    
    // MARK: CenterViewController delegate methods
    
    func toggleLeftPanel() {
        let notAlreadyExpanded = (currentState != .LeftPanelExpanded)
        
        if notAlreadyExpanded {
            addLeftPanelViewController()
        }
        
        animateLeftPanel(shouldExpand: notAlreadyExpanded)
    }
    
    func collapseSidePanels() {
        switch (currentState) {
        case .LeftPanelExpanded:
            toggleLeftPanel()
        default:
            break
        }
    }
    
    func addLeftPanelViewController() {
        if (leftViewController == nil) {
            leftViewController = FolioReaderSidePanel()
            leftViewController.delegate = self
            addChildSidePanelController(leftViewController!)
        }
    }
    
    func addChildSidePanelController(sidePanelController: FolioReaderSidePanel) {
        view.insertSubview(sidePanelController.view, atIndex: 0)
        addChildViewController(sidePanelController)
        sidePanelController.didMoveToParentViewController(self)
    }
    
    func animateLeftPanel(#shouldExpand: Bool) {
        if (shouldExpand) {
            currentState = .LeftPanelExpanded
            delegate.container(didExpandLeftPanel: leftViewController)
            animateCenterPanelXPosition(targetPosition: CGRectGetWidth(centerNavigationController.view.frame) - centerPanelExpandedOffset)
            if currentSelectedIndex != nil {
                leftViewController.tableView.deselectRowAtIndexPath(currentSelectedIndex, animated: true)
            }
        } else {
            animateCenterPanelXPosition(targetPosition: 0) { finished in
                self.delegate.container(didCollapseLeftPanel: self.leftViewController)
                self.currentState = .BothCollapsed
            }
        }
    }
    
    func animateCenterPanelXPosition(#targetPosition: CGFloat, completion: ((Bool) -> Void)! = nil) {
        UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: {
            self.centerNavigationController.view.frame.origin.x = targetPosition
            }, completion: completion)
    }
    
    func showShadowForCenterViewController(shouldShowShadow: Bool) {
        if (shouldShowShadow) {
            centerNavigationController.view.layer.shadowOpacity = 0.2
            centerNavigationController.view.layer.shadowRadius = 6
            centerNavigationController.view.layer.shadowPath = UIBezierPath(rect: centerNavigationController.view.bounds).CGPath
            centerNavigationController.view.clipsToBounds = false
        } else {
            centerNavigationController.view.layer.shadowOpacity = 0
            centerNavigationController.view.layer.shadowRadius = 0
        }
    }
    
    // MARK: Gesture recognizer
    
    func handlePanGesture(recognizer: UIPanGestureRecognizer) {
        let gestureIsDraggingFromLeftToRight = (recognizer.velocityInView(view).x > 0)
        
        switch(recognizer.state) {
        case .Began:
            if currentState == .BothCollapsed && gestureIsDraggingFromLeftToRight {
                addLeftPanelViewController()
                currentState = .Expanding
            }
        case .Changed:
            if currentState == .LeftPanelExpanded || currentState == .Expanding && recognizer.view!.frame.origin.x >= 0 {
                recognizer.view!.center.x = recognizer.view!.center.x + recognizer.translationInView(view).x
                recognizer.setTranslation(CGPointZero, inView: view)
            }
        case .Ended:
            if leftViewController != nil {
                let gap = 20 as CGFloat
                let xPos = recognizer.view!.frame.origin.x
                let width = view.bounds.size.width
                var canFinishAnimation = gestureIsDraggingFromLeftToRight && xPos > gap ? true : false
                animateLeftPanel(shouldExpand: canFinishAnimation)
            }
        default:
            break
        }
    }
    
    // MARK: - Status Bar
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // MARK: - Side Panel delegate
    
    func sidePanel(sidePanel: FolioReaderSidePanel, didSelectRowAtIndexPath indexPath: NSIndexPath, withTocReference reference: FRTocReference) {
        currentSelectedIndex = indexPath
        collapseSidePanels()
        delegate.container(sidePanel, didSelectRowAtIndexPath: indexPath, withTocReference: reference)
    }
}
