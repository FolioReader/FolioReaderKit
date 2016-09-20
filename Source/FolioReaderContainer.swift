//
//  FolioReaderContainer.swift
//  FolioReaderKit
//
//  Created by Heberti Almeida on 15/04/15.
//  Copyright (c) 2015 Folio Reader. All rights reserved.
//

import UIKit

var readerConfig: FolioReaderConfig!
var book: FRBook!

/// Reader container
public class FolioReaderContainer: UIViewController {
    var centerNavigationController: UINavigationController!
	var centerViewController: FolioReaderCenter!
    var audioPlayer: FolioReaderAudioPlayer!
    var shouldHideStatusBar = true
    var shouldRemoveEpub = true
    var epubPath: String!
    private var errorOnLoad = false

    // MARK: - Init
    
    /**
     Init a Container
     
     - parameter config:     A instance of `FolioReaderConfig`
     - parameter path:       The ePub path on system
     - parameter removeEpub: Should delete the original file after unzip? Default to `true` so the ePub will be unziped only once.
     
     - returns: `self`, initialized using the `FolioReaderConfig`.
     */
    public init(withConfig config: FolioReaderConfig, epubPath path: String, removeEpub: Bool = true) {
        super.init(nibName: nil, bundle: NSBundle.frameworkBundle())
        
        readerConfig = config
        epubPath = path
        shouldRemoveEpub = removeEpub
        
		initialization()
    }
    
    required public init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
        
        initialization()
    }
    
    /**
     Common Initialization
     */
    private func initialization() {
        FolioReader.sharedInstance.readerContainer = self
        
        book = FRBook()
        
        // Register custom fonts
        FontBlaster.blast(NSBundle.frameworkBundle())

        // Register initial defaults
        FolioReader.defaults.registerDefaults([
            kCurrentFontFamily: FolioReaderFont.Andada.rawValue,
            kNightMode: false,
            kCurrentFontSize: 2,
            kCurrentAudioRate: 1,
            kCurrentHighlightStyle: 0,
            kCurrentTOCMenu: 0,
            kCurrentMediaOverlayStyle: MediaOverlayStyle.Default.rawValue,
            kCurrentScrollDirection: FolioReaderScrollDirection.vertical.rawValue
            ])
    }
    
    /**
     Set the `FolioReaderConfig` and epubPath.
     
     - parameter config:     A instance of `FolioReaderConfig`
     - parameter path:       The ePub path on system
     - parameter removeEpub: Should delete the original file after unzip? Default to `true` so the ePub will be unziped only once.
     */
    public func setupConfig(config: FolioReaderConfig, epubPath path: String, removeEpub: Bool = true) {
        readerConfig = config
        epubPath = path
        shouldRemoveEpub = removeEpub
    }
    
    // MARK: - View life cicle
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        readerConfig.canChangeScrollDirection = isDirection(readerConfig.canChangeScrollDirection, readerConfig.canChangeScrollDirection, false)
        
        // If user can change scroll direction use the last saved
        if readerConfig.canChangeScrollDirection {
            let direction = FolioReaderScrollDirection(rawValue: FolioReader.currentScrollDirection) ?? .vertical
            readerConfig.scrollDirection = direction
        }

		readerConfig.shouldHideNavigationOnTap = ((readerConfig.hideBars == true) ? true : readerConfig.shouldHideNavigationOnTap)

        centerViewController = FolioReaderCenter()
        FolioReader.sharedInstance.readerCenter = centerViewController
        
        centerNavigationController = UINavigationController(rootViewController: centerViewController)
        centerNavigationController.setNavigationBarHidden(readerConfig.shouldHideNavigationOnTap, animated: false)
        view.addSubview(centerNavigationController.view)
        addChildViewController(centerNavigationController)
        centerNavigationController.didMoveToParentViewController(self)

		if (readerConfig.hideBars == true) {
			readerConfig.shouldHideNavigationOnTap = false
			self.navigationController?.navigationBar.hidden = true
			self.centerViewController.pageIndicatorHeight = 0
		}

        // Read async book
        guard !epubPath.isEmpty else {
            print("Epub path is nil.")
            errorOnLoad = true
            return
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), { () -> Void in
            
            if let parsedBook = FREpubParser().readEpub(epubPath: self.epubPath, removeEpub: self.shouldRemoveEpub) {
                book = parsedBook
            } else {
                self.errorOnLoad = true
            }
            
            guard !self.errorOnLoad else { return }
            
            FolioReader.isReaderOpen = true
            
            // Reload data
            dispatch_async(dispatch_get_main_queue(), {
                
                // Add audio player if needed
                if book.hasAudio() || readerConfig.enableTTS {
                    self.addAudioPlayer()
                }
                
                self.centerViewController.reloadData()
                
                FolioReader.isReaderReady = true
                FolioReader.sharedInstance.delegate?.folioReader?(FolioReader.sharedInstance, didFinishedLoading: book)
            })
        })
    }
    
    override public func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if errorOnLoad {
            dismiss()
        }
    }
    
    /**
     Initialize the media player
     */
    func addAudioPlayer() {
        audioPlayer = FolioReaderAudioPlayer()
        FolioReader.sharedInstance.readerAudioPlayer = audioPlayer;
    }
    
    // MARK: - Status Bar
    
    override public func prefersStatusBarHidden() -> Bool {
        return readerConfig.shouldHideNavigationOnTap == false ? false : shouldHideStatusBar
    }
    
    override public func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        return UIStatusBarAnimation.Slide
    }
    
    override public func preferredStatusBarStyle() -> UIStatusBarStyle {
        return isNight(.LightContent, .Default)
    }
}
