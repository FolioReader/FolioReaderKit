//
//  FolioReaderContainer.swift
//  FolioReaderKit
//
//  Created by Heberti Almeida on 15/04/15.
//  Copyright (c) 2015 Folio Reader. All rights reserved.
//

import UIKit
import FontBlaster

// TODO_SMF: remove static variables
var readerConfig: FolioReaderConfig!
var book: FRBook!

/// Reader container
open class FolioReaderContainer		: UIViewController {

	// TODO_SMF: remove `!`
    var centerNavigationController	: UINavigationController!
	var centerViewController		: FolioReaderCenter!
    var audioPlayer					: FolioReaderAudioPlayer?
    var shouldHideStatusBar 		= true
    var shouldRemoveEpub 			= true
    var epubPath					: String!

	fileprivate var folioReader		: FolioReader?
    fileprivate var errorOnLoad 	= false

    // MARK: - Init
    
    /**
     Init a Container
     
     - parameter config:     A instance of `FolioReaderConfig`
     - parameter path:       The ePub path on system
     - parameter removeEpub: Should delete the original file after unzip? Default to `true` so the ePub will be unziped only once.
     
     - returns: `self`, initialized using the `FolioReaderConfig`.
     */
	public init(withConfig config: FolioReaderConfig, folioReader: FolioReader, epubPath path: String, removeEpub: Bool = true) {
        super.init(nibName: nil, bundle: Bundle.frameworkBundle())
        
        readerConfig = config
		self.folioReader = folioReader
        self.epubPath = path
        self.shouldRemoveEpub = removeEpub
        
		self.initialization()
    }
    
    required public init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
        
        self.initialization()
    }
    
    /**
     Common Initialization
     */
    fileprivate func initialization() {
        book = FRBook()
        
        // Register custom fonts
        FontBlaster.blast(bundle: Bundle.frameworkBundle())

        // Register initial defaults
        FolioReader.defaults.register(defaults: [
            kCurrentFontFamily: FolioReaderFont.andada.rawValue,
            kNightMode: false,
            kCurrentFontSize: 2,
            kCurrentAudioRate: 1,
            kCurrentHighlightStyle: 0,
            kCurrentTOCMenu: 0,
            kCurrentMediaOverlayStyle: MediaOverlayStyle.default.rawValue,
            kCurrentScrollDirection: FolioReaderScrollDirection.defaultVertical.rawValue
		])
    }
    
    /**
     Set the `FolioReaderConfig` and epubPath.
     
     - parameter config:     A instance of `FolioReaderConfig`
     - parameter path:       The ePub path on system
     - parameter removeEpub: Should delete the original file after unzip? Default to `true` so the ePub will be unziped only once.
     */
    open func setupConfig(_ config: FolioReaderConfig, folioReader: FolioReader, epubPath path: String, removeEpub: Bool = true) {
        readerConfig = config
		self.folioReader = folioReader
        self.epubPath = path
        self.shouldRemoveEpub = removeEpub
    }
    
    // MARK: - View life cicle
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        readerConfig.canChangeScrollDirection = isDirection(readerConfig.canChangeScrollDirection, readerConfig.canChangeScrollDirection, false)
        
        // If user can change scroll direction use the last saved
        if readerConfig.canChangeScrollDirection {
            var scrollDirection = (FolioReaderScrollDirection(rawValue: (self.folioReader?.currentScrollDirection ?? 0)) ?? .vertical)

            if (scrollDirection == .defaultVertical && readerConfig.scrollDirection != .defaultVertical) {
                scrollDirection = readerConfig.scrollDirection
            }

            readerConfig.scrollDirection = scrollDirection
        }

		readerConfig.shouldHideNavigationOnTap = ((readerConfig.hideBars == true) ? true : readerConfig.shouldHideNavigationOnTap)

        self.centerViewController = FolioReaderCenter()
        self.folioReader?.readerCenter = self.centerViewController
        
        self.centerNavigationController = UINavigationController(rootViewController: self.centerViewController)
        self.centerNavigationController.setNavigationBarHidden(readerConfig.shouldHideNavigationOnTap, animated: false)
        self.view.addSubview(self.centerNavigationController.view)
        self.addChildViewController(self.centerNavigationController)
        self.centerNavigationController.didMove(toParentViewController: self)

		if (readerConfig.hideBars == true) {
			readerConfig.shouldHideNavigationOnTap = false
			self.navigationController?.navigationBar.isHidden = true
			self.centerViewController.pageIndicatorHeight = 0
		}

        // Read async book
        guard (self.epubPath.isEmpty == false) else {
            print("Epub path is nil.")
            self.errorOnLoad = true
            return
        }

        DispatchQueue.global(qos: .userInitiated).async {
            if let parsedBook = FREpubParser().readEpub(epubPath: self.epubPath, removeEpub: self.shouldRemoveEpub) {
                book = parsedBook
            } else {
                self.errorOnLoad = true
            }
            
            guard !self.errorOnLoad else { return }
            
            self.folioReader?.isReaderOpen = true
            
            // Reload data
            DispatchQueue.main.async(execute: {
                
                // Add audio player if needed
                if book.hasAudio() || readerConfig.enableTTS {
                    self.addAudioPlayer()
                }
                
                self.centerViewController.reloadData()
                
                self.folioReader?.isReaderReady = true

				guard let reader = self.folioReader else {
					return
				}

				reader.delegate?.folioReader?(reader, didFinishedLoading: book)
            })
        }
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if (self.errorOnLoad == true) {
            self.dismiss()
        }
    }
    
    /**
     Initialize the media player
     */
    func addAudioPlayer() {
        self.audioPlayer = FolioReaderAudioPlayer()
        self.folioReader?.readerAudioPlayer = audioPlayer
    }
    
    // MARK: - Status Bar
    
    override open var prefersStatusBarHidden: Bool {
        return (readerConfig.shouldHideNavigationOnTap == false ? false : shouldHideStatusBar)
    }
    
    override open var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return UIStatusBarAnimation.slide
    }
    
    override open var preferredStatusBarStyle: UIStatusBarStyle {
        return isNight(.lightContent, .default)
    }
}
