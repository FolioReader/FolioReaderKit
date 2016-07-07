//
//  FolioReaderContainer.swift
//  FolioReaderKit
//
//  Created by Heberti Almeida on 15/04/15.
//  Copyright (c) 2015 Folio Reader. All rights reserved.
//

import UIKit
import FontBlaster

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

protocol FolioReaderContainerDelegate: class {
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

class FolioReaderContainer: UIViewController, FolioReaderSidePanelDelegate {
    weak var delegate: FolioReaderContainerDelegate!
    var centerNavigationController: UINavigationController!
    var centerViewController: FolioReaderCenter!
    var leftViewController: FolioReaderSidePanel!
    var audioPlayer: FolioReaderAudioPlayer!
    var centerPanelExpandedOffset: CGFloat = 70
    var currentState = SlideOutState()
    var shouldHideStatusBar = true
    private var errorOnLoad = false
    private var shouldRemoveEpub = true
    
    // MARK: - Init
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(config configOrNil: FolioReaderConfig!, epubPath epubPathOrNil: String? = nil, removeEpub: Bool) {
        readerConfig = configOrNil
        epubPath = epubPathOrNil
        shouldRemoveEpub = removeEpub
        super.init(nibName: nil, bundle: NSBundle.frameworkBundle())
        
        // Init with empty book
        book = FRBook()
        
        // Register custom fonts
        FontBlaster.blast(NSBundle.frameworkBundle())
        
        // Register initial defaults
        FolioReader.defaults.registerDefaults([
            kCurrentFontFamily: 0,
            kNightMode: false,
            kCurrentFontSize: 2,
            kCurrentAudioRate: 1,
            kCurrentHighlightStyle: 0,
            kCurrentMediaOverlayStyle: MediaOverlayStyle.Default.rawValue
        ])
    }
    
    // MARK: - View life cicle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        centerViewController = FolioReaderCenter()
        centerViewController.folioReaderContainer = self
        FolioReader.sharedInstance.readerCenter = centerViewController
        
        centerNavigationController = UINavigationController(rootViewController: centerViewController)
        centerNavigationController.setNavigationBarHidden(readerConfig.shouldHideNavigationOnTap, animated: false)
        view.addSubview(centerNavigationController.view)
        addChildViewController(centerNavigationController)
        centerNavigationController.didMoveToParentViewController(self)
        
        // Add gestures
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(FolioReaderContainer.handleTapGesture(_:)))
        tapGestureRecognizer.numberOfTapsRequired = 1
        centerNavigationController.view.addGestureRecognizer(tapGestureRecognizer)
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(FolioReaderContainer.handlePanGesture(_:)))
        centerNavigationController.view.addGestureRecognizer(panGestureRecognizer)

        // Read async book
        if (epubPath != nil) {
            let priority = DISPATCH_QUEUE_PRIORITY_HIGH
            dispatch_async(dispatch_get_global_queue(priority, 0), { () -> Void in
                
                var isDir: ObjCBool = false
                let fileManager = NSFileManager.defaultManager()
                
                if fileManager.fileExistsAtPath(epubPath!, isDirectory:&isDir) {
                    if isDir {
                        book = FREpubParser().readEpub(filePath: epubPath!)
                    } else {
                        book = FREpubParser().readEpub(epubPath: epubPath!, removeEpub: self.shouldRemoveEpub)
                    }
                }
                else {
                    print("Epub file does not exist.")
                    self.errorOnLoad = true
                }
                
                FolioReader.sharedInstance.isReaderOpen = true
                
                if !self.errorOnLoad {
                    // Reload data
                    dispatch_async(dispatch_get_main_queue(), {
                        self.centerViewController.reloadData()
                        self.addLeftPanelViewController()
                        self.addAudioPlayer()
                        
                        // Open panel if does not have a saved point
                        if FolioReader.defaults.valueForKey(kBookId) == nil {
                            self.toggleLeftPanel()
                        }
                        
                        FolioReader.sharedInstance.isReaderReady = true
                    })
                }
            })
        } else {
            print("Epub path is nil.")
            errorOnLoad = true
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        showShadowForCenterViewController(true)
        
        if errorOnLoad {
            dismissViewControllerAnimated(true, completion: nil)
        }
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
            
            FolioReader.sharedInstance.readerSidePanel = leftViewController
        }
    }
    
    func addChildSidePanelController(sidePanelController: FolioReaderSidePanel) {
        view.insertSubview(sidePanelController.view, atIndex: 0)
        addChildViewController(sidePanelController)
        sidePanelController.didMoveToParentViewController(self)
    }
    
    func animateLeftPanel(shouldExpand shouldExpand: Bool) {
        if (shouldExpand) {
            
            if let width = pageWidth {
                if isPad {
                    centerPanelExpandedOffset = width-400
                } else {
                    // Always get the device width
                    let w = UIInterfaceOrientationIsPortrait(UIApplication.sharedApplication().statusBarOrientation) ? UIScreen.mainScreen().bounds.size.width : UIScreen.mainScreen().bounds.size.height
                    
                    centerPanelExpandedOffset = width-(w-70)
                }
            }
            
            currentState = .LeftPanelExpanded
            delegate.container(didExpandLeftPanel: leftViewController)
            animateCenterPanelXPosition(targetPosition: CGRectGetWidth(centerNavigationController.view.frame) - centerPanelExpandedOffset)
            
            // Reload to update current reading chapter
            leftViewController.tableView.reloadData()
        } else {
            animateCenterPanelXPosition(targetPosition: 0) { finished in
                self.delegate.container(didCollapseLeftPanel: self.leftViewController)
                self.currentState = .BothCollapsed
            }
        }
    }
    
    func animateCenterPanelXPosition(targetPosition targetPosition: CGFloat, completion: ((Bool) -> Void)! = nil) {
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
    
    func addAudioPlayer(){
        // @NOTE: should the audio player only be initialized if the epub has audio smil?
        audioPlayer = FolioReaderAudioPlayer()

        FolioReader.sharedInstance.readerAudioPlayer = audioPlayer;
    }

    // MARK: Gesture recognizer
    
    func handleTapGesture(recognizer: UITapGestureRecognizer) {
        if currentState == .LeftPanelExpanded {
            toggleLeftPanel()
        }
    }
    
    func handlePanGesture(recognizer: UIPanGestureRecognizer) {
        guard readerConfig.scrollDirection == .vertical else { return }
        
        let gestureIsDraggingFromLeftToRight = (recognizer.velocityInView(view).x > 0)
        
        switch(recognizer.state) {
        case .Began:
            if currentState == .BothCollapsed && gestureIsDraggingFromLeftToRight {
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
                let canFinishAnimation = gestureIsDraggingFromLeftToRight && xPos > gap ? true : false
                animateLeftPanel(shouldExpand: canFinishAnimation)
            }
        default:
            break
        }
    }
    
    // MARK: - Status Bar
    
    override func prefersStatusBarHidden() -> Bool {
        return readerConfig.shouldHideNavigationOnTap == false ? false : shouldHideStatusBar
    }
    
    override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        return UIStatusBarAnimation.Slide
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return isNight(.LightContent, .Default)
    }
    
    
    
    // MARK: - Side Panel delegate
    
    func sidePanel(sidePanel: FolioReaderSidePanel, didSelectRowAtIndexPath indexPath: NSIndexPath, withTocReference reference: FRTocReference) {
        collapseSidePanels()
        delegate.container(sidePanel, didSelectRowAtIndexPath: indexPath, withTocReference: reference)
    }
}
