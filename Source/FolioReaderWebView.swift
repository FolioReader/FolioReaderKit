//
//  FolioReaderWebView.swift
//  FolioReaderKit
//
//  Created by Hans Seiffert on 21.09.16.
//  Copyright (c) 2016 Folio Reader. All rights reserved.
//

import WebKit

public typealias JSCallback = (String?) ->()

/// The custom WebView used in each page
open class FolioReaderWebView: WKWebView {
    var isColors = false
    var isShare = false
    var isOneWord = false
    
    fileprivate(set) var cssOverflowProperty = "scroll" {
        didSet {
            FolioReaderScript.cssInjection(overflow: cssOverflowProperty).addIfNeeded(to: self)
        }
    }

    fileprivate weak var readerContainer: FolioReaderContainer?

    fileprivate var readerConfig: FolioReaderConfig {
        guard let readerContainer = readerContainer else { return FolioReaderConfig() }
        return readerContainer.readerConfig
    }

    fileprivate var book: FRBook {
        guard let readerContainer = readerContainer else { return FRBook() }
        return readerContainer.book
    }

    fileprivate var folioReader: FolioReader {
        guard let readerContainer = readerContainer else { return FolioReader() }
        return readerContainer.folioReader
    }

    init(frame: CGRect, readerContainer: FolioReaderContainer) {
        self.readerContainer = readerContainer

        let configuration = WKWebViewConfiguration()
        configuration.dataDetectorTypes = .link
        super.init(frame: frame, configuration: configuration)
        FolioReaderScript.cssInjection.addIfNeeded(to: self)
        FolioReaderScript.bridgeJS.addIfNeeded(to: self)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UIMenuController

    open override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        guard readerConfig.useReaderMenuController else {
            return super.canPerformAction(action, withSender: sender)
        }

        if isShare {
            return false
        } else if isColors {
            return false
        } else {
            if action == #selector(highlight(_:))
                || action == #selector(highlightWithNote(_:))
                || action == #selector(updateHighlightNote(_:))
                || (action == #selector(define(_:)) && isOneWord)
                || (action == #selector(play(_:)) && (book.hasAudio || readerConfig.enableTTS))
                || (action == #selector(share(_:)) && readerConfig.allowSharing)
                || (action == #selector(copy(_:)) && readerConfig.allowSharing) {
                return true
            }
            return false
        }
    }

    // MARK: - UIMenuController - Actions

    @objc func share(_ sender: UIMenuController) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let shareImage = UIAlertAction(title: self.readerConfig.localizedShareImageQuote, style: .default, handler: { (action) -> Void in
            if self.isShare {
                self.js("getHighlightContent()") { textToShare in
                    guard let textToShare = textToShare else { return }
                    self.folioReader.readerCenter?.presentQuoteShare(textToShare)
                }
            } else {
                self.js("getSelectedText()") { textToShare in
                    guard let textToShare = textToShare else { return }
                    self.folioReader.readerCenter?.presentQuoteShare(textToShare)

                    self.clearTextSelection()
                }
            }
            self.setMenuVisible(false)
        })

        let shareText = UIAlertAction(title: self.readerConfig.localizedShareTextQuote, style: .default) { (action) -> Void in
            if self.isShare {
                self.js("getHighlightContent()") { textToShare in
                    guard let textToShare = textToShare else { return }
                    self.folioReader.readerCenter?.shareHighlight(textToShare, rect: sender.menuFrame)
                }
            } else {
                self.js("getSelectedText()") { textToShare in
                    guard let textToShare = textToShare else { return }
                    self.folioReader.readerCenter?.shareHighlight(textToShare, rect: sender.menuFrame)
                }
            }
            self.setMenuVisible(false)
        }

        let cancel = UIAlertAction(title: self.readerConfig.localizedCancel, style: .cancel, handler: nil)

        alertController.addAction(shareImage)
        alertController.addAction(shareText)
        alertController.addAction(cancel)

        if let alert = alertController.popoverPresentationController {
            alert.sourceView = self.folioReader.readerCenter?.currentPage
            alert.sourceRect = sender.menuFrame
        }

        self.folioReader.readerCenter?.present(alertController, animated: true, completion: nil)
    }

    func colors(_ sender: UIMenuController?) {
        isColors = true
        createMenu(options: false)
        setMenuVisible(true)
    }

    func remove(_ sender: UIMenuController?) {
        js("removeThisHighlight()") { removedId in
            guard let removedId = removedId else { return }
            Highlight.removeById(withConfiguration: self.readerConfig, highlightId: removedId)
        }
        setMenuVisible(false)
    }

    @objc func highlight(_ sender: UIMenuController?) {
        js("highlightString('\(HighlightStyle.classForStyle(self.folioReader.currentHighlightStyle))')") { highlightAndReturn in
            let jsonData = highlightAndReturn?.data(using: String.Encoding.utf8)

            do {
                let json = try JSONSerialization.jsonObject(with: jsonData!, options: []) as! NSArray
                let dic = json.firstObject as! [String: String]
                let rect = NSCoder.cgRect(for: dic["rect"]!)
                guard let startOffset = dic["startOffset"] else {
                    return
                }
                guard let endOffset = dic["endOffset"] else {
                    return
                }

                self.createMenu(options: true)
                self.setMenuVisible(true, andRect: rect)

                // Persist
                self.js("getHTML()") { html in
                    
                    guard let html = html, let identifier = dic["id"], let bookId = (self.book.name as NSString?)?.deletingPathExtension
                        else {
                            return
                    }
                    let pageNumber = self.folioReader.readerCenter?.currentPageNumber ?? 0
                    let match = Highlight.MatchingHighlight(text: html, id: identifier, startOffset: startOffset, endOffset: endOffset, bookId: bookId, currentPage: pageNumber)
                    let highlight = Highlight.matchHighlight(match)
                    highlight?.persist(withConfiguration: self.readerConfig)
                }
                
            } catch {
                print("Could not receive JSON:", error)
            }
        }
    }
    
    @objc func highlightWithNote(_ sender: UIMenuController?) {
        js("highlightStringWithNote('\(HighlightStyle.classForStyle(self.folioReader.currentHighlightStyle))')") { highlightAndReturn in
            let jsonData = highlightAndReturn?.data(using: String.Encoding.utf8)
        
            do {
                let json = try JSONSerialization.jsonObject(with: jsonData!, options: []) as! NSArray
                let dic = json.firstObject as! [String: String]
                guard let startOffset = dic["startOffset"] else { return }
                guard let endOffset = dic["endOffset"] else { return }
            
                self.clearTextSelection()
            
                self.js("getHTML()") { html in
                    guard
                        let html = html, let identifier = dic["id"],
                        let bookId = (self.book.name as NSString?)?.deletingPathExtension else
                    {
                        return
                    }
                    
                    let pageNumber = self.folioReader.readerCenter?.currentPageNumber ?? 0
                    let match = Highlight.MatchingHighlight(text: html, id: identifier, startOffset: startOffset, endOffset: endOffset, bookId: bookId, currentPage: pageNumber)
                    if let highlight = Highlight.matchHighlight(match) {
                        self.folioReader.readerCenter?.presentAddHighlightNote(highlight, edit: false)
                    }
                }
            } catch {
                print("Could not receive JSON:", error)
            }
        }
    }
    
    @objc func updateHighlightNote (_ sender: UIMenuController?) {
        js("getHighlightId()") { highlightId in
            guard
                let highlightId = highlightId,
                let highlightNote = Highlight.getById(withConfiguration: self.readerConfig, highlightId: highlightId) else { return }
            self.folioReader.readerCenter?.presentAddHighlightNote(highlightNote, edit: true)
        }
    }

    @objc func define(_ sender: UIMenuController?) {
        js("getSelectedText()") { selectedText in
            guard let selectedText = selectedText else { return }

            self.setMenuVisible(false)
            self.clearTextSelection()

            let vc = UIReferenceLibraryViewController(term: selectedText)
            vc.view.tintColor = self.readerConfig.tintColor
            guard let readerContainer = self.readerContainer else { return }
            readerContainer.show(vc, sender: nil)
        }
    }

    @objc func play(_ sender: UIMenuController?) {
        self.folioReader.readerAudioPlayer?.play()

        self.clearTextSelection()
    }

    func setYellow(_ sender: UIMenuController?) {
        changeHighlightStyle(sender, style: .yellow)
    }

    func setGreen(_ sender: UIMenuController?) {
        changeHighlightStyle(sender, style: .green)
    }

    func setBlue(_ sender: UIMenuController?) {
        changeHighlightStyle(sender, style: .blue)
    }

    func setPink(_ sender: UIMenuController?) {
        changeHighlightStyle(sender, style: .pink)
    }

    func setUnderline(_ sender: UIMenuController?) {
        changeHighlightStyle(sender, style: .underline)
    }

    func changeHighlightStyle(_ sender: UIMenuController?, style: HighlightStyle) {
        self.folioReader.currentHighlightStyle = style.rawValue

        js("setHighlightStyle('\(HighlightStyle.classForStyle(style.rawValue))')") { updateId in
            guard let updateId = updateId else { return }
            Highlight.updateById(withConfiguration: self.readerConfig, highlightId: updateId, type: style)
        }
        
        //FIX: https://github.com/FolioReader/FolioReaderKit/issues/316
        setMenuVisible(false)
    }

    // MARK: - Create and show menu

    func createMenu(options: Bool) {
        guard (self.readerConfig.useReaderMenuController == true) else {
            return
        }

        isShare = options

        let colors = UIImage(readerImageNamed: "colors-marker")
        let share = UIImage(readerImageNamed: "share-marker")
        let remove = UIImage(readerImageNamed: "no-marker")
        let yellow = UIImage(readerImageNamed: "yellow-marker")
        let green = UIImage(readerImageNamed: "green-marker")
        let blue = UIImage(readerImageNamed: "blue-marker")
        let pink = UIImage(readerImageNamed: "pink-marker")
        let underline = UIImage(readerImageNamed: "underline-marker")

        let menuController = UIMenuController.shared

        let highlightItem = UIMenuItem(title: self.readerConfig.localizedHighlightMenu, action: #selector(highlight(_:)))
        let highlightNoteItem = UIMenuItem(title: self.readerConfig.localizedHighlightNote, action: #selector(highlightWithNote(_:)))
        let editNoteItem = UIMenuItem(title: self.readerConfig.localizedHighlightNote, action: #selector(updateHighlightNote(_:)))
        let playAudioItem = UIMenuItem(title: self.readerConfig.localizedPlayMenu, action: #selector(play(_:)))
        let defineItem = UIMenuItem(title: self.readerConfig.localizedDefineMenu, action: #selector(define(_:)))
        let colorsItem = UIMenuItem(title: "C", image: colors) { [weak self] _ in
            self?.colors(menuController)
        }
        let shareItem = UIMenuItem(title: "S", image: share) { [weak self] _ in
            self?.share(menuController)
        }
        let removeItem = UIMenuItem(title: "R", image: remove) { [weak self] _ in
            self?.remove(menuController)
        }
        let yellowItem = UIMenuItem(title: "Y", image: yellow) { [weak self] _ in
            self?.setYellow(menuController)
        }
        let greenItem = UIMenuItem(title: "G", image: green) { [weak self] _ in
            self?.setGreen(menuController)
        }
        let blueItem = UIMenuItem(title: "B", image: blue) { [weak self] _ in
            self?.setBlue(menuController)
        }
        let pinkItem = UIMenuItem(title: "P", image: pink) { [weak self] _ in
            self?.setPink(menuController)
        }
        let underlineItem = UIMenuItem(title: "U", image: underline) { [weak self] _ in
            self?.setUnderline(menuController)
        }

        var menuItems: [UIMenuItem] = []

        // menu on existing highlight
        if isShare {
            menuItems = [colorsItem, editNoteItem, removeItem]
            
            if (self.readerConfig.allowSharing == true) {
                menuItems.append(shareItem)
            }
            
            isShare = false
        } else if isColors {
            // menu for selecting highlight color
            menuItems = [yellowItem, greenItem, blueItem, pinkItem, underlineItem]
        } else {
            // default menu
            menuItems = [highlightItem, defineItem, highlightNoteItem]

            if self.book.hasAudio || self.readerConfig.enableTTS {
                menuItems.insert(playAudioItem, at: 0)
            }

            if (self.readerConfig.allowSharing == true) {
                menuItems.append(shareItem)
            }
        }
        
        menuController.menuItems = menuItems
    }
    
    open func setMenuVisible(_ menuVisible: Bool, animated: Bool = true, andRect rect: CGRect = CGRect.zero) {
        if !menuVisible && isShare || !menuVisible && isColors {
            isColors = false
            isShare = false
        }
        
        if menuVisible  {
            if !rect.equalTo(CGRect.zero) {
                UIMenuController.shared.setTargetRect(rect, in: self)
            }
        }
        
        UIMenuController.shared.setMenuVisible(menuVisible, animated: animated)
    }
    
    // MARK: - Java Script Bridge
    
    open func js(_ script: String, completion: JSCallback? = nil) {
        evaluateJavaScript(script) { result, error in
            let output: String?
            if let result = result {
                let stringResult = "\(result)"
                if stringResult.isEmpty {
                    output = nil
                } else {
                    output = stringResult
                }
            } else {
                output = nil
            }
            if  let nsError = error as? NSError,
                let url = nsError.userInfo["WKJavaScriptExceptionSourceURL"] as? NSURL,
                url.absoluteString == "undefined"
            {
                // skip debugPrint - html hasn't loaded yet
            } else if let error = error {
                debugPrint("evaluateJavaScript(\(script)) returned an error:", error)
            }
            completion?(output)
        }
    }
    
    // MARK: WebView
    
    func clearTextSelection() {
        // Forces text selection clearing
        // @NOTE: this doesn't seem to always work
        
        self.isUserInteractionEnabled = false
        self.isUserInteractionEnabled = true
    }
    
    func setupScrollDirection() {
        switch self.readerConfig.scrollDirection {
        case .vertical, .defaultVertical, .horizontalWithVerticalContent:
            scrollView.isPagingEnabled = false
            cssOverflowProperty = "scroll"
            scrollView.bounces = true
            break
        case .horizontal:
            scrollView.isPagingEnabled = true
            cssOverflowProperty = "-webkit-paged-x"
            scrollView.bounces = false
            break
        }
    }
}
