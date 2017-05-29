//
//  FolioReaderContainer.swift
//  FolioReaderKit
//
//  Created by Heberti Almeida on 15/04/15.
//  Copyright (c) 2015 Folio Reader. All rights reserved.
//

import UIKit
import FontBlaster

/// Reader container
open class FolioReaderContainer: UIViewController {
    var centerNavigationController: UINavigationController?
    var centerViewController: FolioReaderCenter?
    var audioPlayer: FolioReaderAudioPlayer?
    var shouldHideStatusBar = true
    var shouldRemoveEpub = true
    var epubPath: String
    var book: FRBook

    // Mark those property as public so they can accessed from other classes/subclasses.
    public var readerConfig: FolioReaderConfig
    public var folioReader: FolioReader

    fileprivate var errorOnLoad = false

    // MARK: - Init

    /// Init a Folio Reader Container
    ///
    /// - Parameters:
    ///   - config: Current Folio Reader configuration
    ///   - folioReader: Current instance of the FolioReader kit.
    ///   - path: The ePub path on system. Must not be nil nor empty string.
    ///   - removeEpub:  Should delete the original file after unzip? Default to `true` so the ePub will be unziped only once.
    public init(withConfig config: FolioReaderConfig, folioReader: FolioReader, epubPath path: String, removeEpub: Bool = true) {
        self.readerConfig = config
        self.folioReader = folioReader
        self.epubPath = path
        self.shouldRemoveEpub = removeEpub
        self.book = FRBook()

        super.init(nibName: nil, bundle: Bundle.frameworkBundle())

        // Configure the folio reader.
        self.folioReader.readerContainer = self

        // Initialize the default reader options.
        if self.epubPath != "" {
            self.initialization()
        }
    }

    required public init?(coder aDecoder: NSCoder) {
        // When a FolioReaderContainer object is instantiated from the storyboard this function is called before.
        // At this moment, we need to initialize all non-optional objects with default values.
        // The function `setupConfig(config:epubPath:removeEpub:)` MUST be called afterward.
        // See the ExampleFolioReaderContainer.swift for more information?
        self.readerConfig = FolioReaderConfig()
        self.folioReader = FolioReader()
        self.epubPath = ""
        self.shouldRemoveEpub = false
        self.book = FRBook()

        super.init(coder: aDecoder)

        // Configure the folio reader.
        self.folioReader.readerContainer = self

        // Set the shared instance to support old version.
        FolioReader.shared = self.folioReader
    }

    /// Common Initialization
    fileprivate func initialization() {
        // Register custom fonts
        FontBlaster.blast(bundle: Bundle.frameworkBundle())

        // Register initial defaults
        self.folioReader.register(defaults: [
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

    /// Set the `FolioReaderConfig` and epubPath.
    ///
    /// - Parameters:
    ///   - config: Current Folio Reader configuration
    ///   - path: The ePub path on system. Must not be nil nor empty string.
    ///   - removeEpub: Should delete the original file after unzip? Default to `true` so the ePub will be unziped only once.
    open func setupConfig(_ config: FolioReaderConfig, epubPath path: String, removeEpub: Bool = true) {
        self.readerConfig = config
        self.folioReader = FolioReader()
        self.folioReader.readerContainer = self
        self.epubPath = path
        self.shouldRemoveEpub = removeEpub

        // Set the shared instance to support old version.
        FolioReader.shared = self.folioReader
    }

    // MARK: - View life cicle

    override open func viewDidLoad() {
        super.viewDidLoad()

        let canChangeScrollDirection = self.readerConfig.canChangeScrollDirection
        self.readerConfig.canChangeScrollDirection = self.readerConfig.isDirection(canChangeScrollDirection, canChangeScrollDirection, false)

        // If user can change scroll direction use the last saved
        if self.readerConfig.canChangeScrollDirection == true {
            var scrollDirection = FolioReaderScrollDirection(rawValue: self.folioReader.currentScrollDirection) ?? .vertical
            if (scrollDirection == .defaultVertical && self.readerConfig.scrollDirection != .defaultVertical) {
                scrollDirection = self.readerConfig.scrollDirection
            }

            self.readerConfig.scrollDirection = scrollDirection
        }

        let hideBars = (self.readerConfig.hideBars ?? false)
        self.readerConfig.shouldHideNavigationOnTap = ((hideBars == true) ? true : self.readerConfig.shouldHideNavigationOnTap)

        self.centerViewController = FolioReaderCenter(withContainer: self)

        if let rootViewController = self.centerViewController {
            self.centerNavigationController = UINavigationController(rootViewController: rootViewController)
        }

        self.centerNavigationController?.setNavigationBarHidden(self.readerConfig.shouldHideNavigationOnTap, animated: false)
        if let _centerNavigationController = self.centerNavigationController {
            self.view.addSubview(_centerNavigationController.view)
            self.addChildViewController(_centerNavigationController)
        }
        self.centerNavigationController?.didMove(toParentViewController: self)

        if (self.readerConfig.hideBars == true) {
            self.readerConfig.shouldHideNavigationOnTap = false
            self.navigationController?.navigationBar.isHidden = true
            self.centerViewController?.pageIndicatorHeight = 0
        }

        // Read async book
        guard (self.epubPath.isEmpty == false) else {
            print("Epub path is nil.")
            self.errorOnLoad = true
            return
        }

        DispatchQueue.global(qos: .userInitiated).async {

            do {
                guard let parsedBook = try FREpubParser().readEpub(epubPath: self.epubPath, removeEpub: self.shouldRemoveEpub) else {
                    self.errorOnLoad = true
                    return
                }

                self.book = parsedBook
                self.folioReader.isReaderOpen = true

                // Reload data
                DispatchQueue.main.async(execute: {

                    // Add audio player if needed
                    if (self.book.hasAudio() == true || self.readerConfig.enableTTS == true) {
                        self.addAudioPlayer()
                    }
                    self.centerViewController?.reloadData()
                    self.folioReader.isReaderReady = true
                    self.folioReader.delegate?.folioReader?(self.folioReader, didFinishedLoading: self.book)
                })
            } catch let e as FolioReaderError {
                self.alert(message: e.localizedDescription)
            } catch {
                self.alert(message: "Unknown Error")
            }
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
        self.audioPlayer = FolioReaderAudioPlayer(withFolioReader: self.folioReader, book: self.book)
        self.folioReader.readerAudioPlayer = audioPlayer
    }

    // MARK: - Status Bar

    override open var prefersStatusBarHidden: Bool {
        return (self.readerConfig.shouldHideNavigationOnTap == false ? false : self.shouldHideStatusBar)
    }

    override open var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return UIStatusBarAnimation.slide
    }

    override open var preferredStatusBarStyle: UIStatusBarStyle {
        return self.folioReader.isNight(.lightContent, .default)
    }
}

extension FolioReaderContainer {
    func alert(message: String) {
        let alertController = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: UIAlertControllerStyle.alert
        )
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel) { [weak self]
            (result : UIAlertAction) -> Void in
            self?.dismiss()
        }
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }
}
