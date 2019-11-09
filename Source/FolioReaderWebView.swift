//
//  FolioReaderWebView.swift
//  FolioReaderKit
//
//  Created by Hans Seiffert on 21.09.16.
//  Copyright (c) 2016 Folio Reader. All rights reserved.
//

import UIKit
import WebKit

/// The custom WebView used in each page
open class FolioReaderWebView: WKWebView {
    var isColors = false
    var isShare = false
    var isOneWord = false
    
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
    
    public override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        fatalError("use init(frame:readerConfig:book:) instead.")
    }
    
    init(frame: CGRect, readerContainer: FolioReaderContainer) {
        self.readerContainer = readerContainer
        let config = WKWebViewConfiguration()
        let controller = WKUserContentController()
        config.dataDetectorTypes = .link
        
        if let script = FolioReaderWebView.insertViewportScript() { controller.addUserScript(script) }
        if let script = FolioReaderWebView.injectCSSScript() { controller.addUserScript(script) }
        if let script = FolioReaderWebView.injectJSScript() { controller.addUserScript(script) }
        if let script = FolioReaderWebView.injectHTMLClasses(container: readerContainer) { controller.addUserScript(script) }
        if let script = FolioReaderWebView.injectColorsScript(container: readerContainer) { controller.addUserScript(script) }
        
        config.userContentController = controller
        super.init(frame: frame, configuration: config)
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
        let shareImage = UIAlertAction(title: readerConfig.localizedShareImageQuote, style: .default, handler: { [weak self] (action) -> Void in
            guard let weakSelf = self else { return }
            if weakSelf.isShare {
                let script = "getHighlightContent()"
                weakSelf.js(script, completion: { value in
                    guard let textToShare = value as? String else { return }
                    weakSelf.folioReader.readerCenter?.presentQuoteShare(textToShare)
                })
            } else {
                let script = "getSelectedText()"
                weakSelf.js(script, completion: { value in
                    guard let textToShare = value as? String else { return }
                    weakSelf.folioReader.readerCenter?.presentQuoteShare(textToShare)
                    weakSelf.clearTextSelection()
                })
            }
            weakSelf.setMenuVisible(false)
        })
        
        let shareText = UIAlertAction(title: self.readerConfig.localizedShareTextQuote, style: .default) { [weak self] (action) -> Void in
            guard let weakSelf = self else { return }
            if weakSelf.isShare {
                let script = "getHighlightContent()"
                weakSelf.js(script, completion: { value in
                    guard let textToShare = value as? String else { return }
                    weakSelf.folioReader.readerCenter?.shareHighlight(textToShare, rect: sender.menuFrame)
                })
            } else {
                let script = "getSelectedText()"
                weakSelf.js(script, completion: { value in
                    guard let textToShare = value as? String else { return }
                    weakSelf.folioReader.readerCenter?.shareHighlight(textToShare, rect: sender.menuFrame)
                    weakSelf.setMenuVisible(false)
                })
            }
        }
        
        let cancel = UIAlertAction(title: self.readerConfig.localizedCancel, style: .cancel, handler: nil)
        alertController.addAction(shareImage)
        alertController.addAction(shareText)
        alertController.addAction(cancel)
        
        if let alert = alertController.popoverPresentationController {
            alert.sourceView = folioReader.readerCenter?.currentPage
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
        let script = "getSelectedText()"
        js(script, completion: { [weak self] removedId in
            guard let weakSelf = self, let removedId = removedId as? String else { return }
            Highlight.removeById(withConfiguration: weakSelf.readerConfig, highlightId: removedId)
            weakSelf.setMenuVisible(false)
        })
    }
    
    @objc func highlight(_ sender: UIMenuController?) {
        
        let script = "highlightString('\(HighlightStyle.classForStyle(self.folioReader.currentHighlightStyle))')"
        js(script, completion: { [weak self] highlight in
            
            guard let weakSelf = self,
                let highlight = highlight as? String,
                let jsonData = highlight.data(using: String.Encoding.utf8) else {
                    return
            }
            
            let json:NSArray
            do {
                json = try JSONSerialization.jsonObject(with: jsonData, options: []) as! NSArray
            } catch {
                return
            }
            
            let dic = json.firstObject as! [String: String]
            let rect = NSCoder.cgRect(for: dic["rect"]!)
            guard let startOffset = dic["startOffset"],
                let endOffset = dic["endOffset"] else {
                    return
            }
            
            weakSelf.createMenu(options: true)
            weakSelf.setMenuVisible(true, andRect: rect)
            
            guard let identifier = dic["id"],
                let bookId = (weakSelf.book.name as? NSString)?.deletingPathExtension else {
                    return
            }
            
            let script = "getHTML()"
            weakSelf.js(script, completion: { [weak self] value in
                guard let weakSelf = self, let html = value as? String else { return }
                let pageNumber = weakSelf.folioReader.readerCenter?.currentPageNumber ?? 0
                let match = Highlight.MatchingHighlight(text: html, id: identifier, startOffset: startOffset, endOffset: endOffset, bookId: bookId, currentPage: pageNumber)
                let highlight = Highlight.matchHighlight(match)
                highlight?.persist(withConfiguration: weakSelf.readerConfig)
            })
        })
    }
    
    @objc func highlightWithNote(_ sender: UIMenuController?) {
        
        let script = "highlightStringWithNote('\(HighlightStyle.classForStyle(self.folioReader.currentHighlightStyle))')"
        js(script, completion: { [weak self] highlight in
            
            guard let weakSelf = self,
                let highlight = highlight as? String,
                let jsonData = highlight.data(using: String.Encoding.utf8) else {
                    return
            }
            
            let json:NSArray
            do {
                json = try JSONSerialization.jsonObject(with: jsonData, options: []) as! NSArray
            } catch {
                return
            }
            
            let dic = json.firstObject as! [String: String]
            let rect = NSCoder.cgRect(for: dic["rect"]!)
            guard let startOffset = dic["startOffset"],
                let endOffset = dic["endOffset"] else {
                    return
            }
            
            weakSelf.clearTextSelection()
            guard let identifier = dic["id"],
                let bookId = (weakSelf.book.name as? NSString)?.deletingPathExtension else {
                    return
            }
            
            let script = "getHTML()"
            weakSelf.js(script, completion: { [weak self] value in
                guard let weakSelf = self, let html = value as? String else { return }
                let pageNumber = weakSelf.folioReader.readerCenter?.currentPageNumber ?? 0
                let match = Highlight.MatchingHighlight(text: html, id: identifier, startOffset: startOffset, endOffset: endOffset, bookId: bookId, currentPage: pageNumber)
                if let highlight = Highlight.matchHighlight(match) {
                    weakSelf.folioReader.readerCenter?.presentAddHighlightNote(highlight, edit: false)
                }
            })
        })
    }
    
    @objc func updateHighlightNote (_ sender: UIMenuController?) {
        let script = "getHighlightId()"
        js(script, completion: { [weak self] value in
            guard let weakSelf = self,
                let highlightId = value as? String,
                let highlightNote = Highlight.getById(withConfiguration: weakSelf.readerConfig, highlightId: highlightId) else {
                    return
            }
            weakSelf.folioReader.readerCenter?.presentAddHighlightNote(highlightNote, edit: true)
        })
    }
    
    @objc func define(_ sender: UIMenuController?) {
        let script = "getSelectedText()"
        js(script, completion: { [weak self] value in
            guard let weakSelf = self, let selectedText = value as? String else { return }
            weakSelf.setMenuVisible(false)
            weakSelf.clearTextSelection()
            let vc = UIReferenceLibraryViewController(term: selectedText)
            vc.view.tintColor = weakSelf.readerConfig.tintColor
            if let readerContainer = weakSelf.readerContainer { readerContainer.show(vc, sender: nil) }
        })
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
        folioReader.currentHighlightStyle = style.rawValue
        let script = "setHighlightStyle('\(HighlightStyle.classForStyle(style.rawValue))')"
        js(script, completion: { [weak self] value in
            guard let weakSelf = self, let updateId = value as? String else { return }
            Highlight.updateById(withConfiguration: weakSelf.readerConfig, highlightId: updateId, type: style)
            weakSelf.setMenuVisible(false)
        })
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
            
            if readerConfig.shouldAllowHighlight {
                menuItems.append(highlightItem)
                menuItems.append(highlightNoteItem)
            }
            
            menuItems.append(defineItem)
            if self.book.hasAudio || self.readerConfig.enableTTS {
                menuItems.insert(playAudioItem, at: 0)
            }
            
            if readerConfig.allowSharing {
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
    @discardableResult open func js(_ script: String, completion:@escaping ((_ value:Any?) -> Void)) {
        evaluateJavaScript(script) { (value, error) in
            completion(value)
        }
    }
    
    func clearTextSelection() {
        // Forces text selection clearing
        // @NOTE: this doesn't seem to always work
        
        isUserInteractionEnabled = false
        isUserInteractionEnabled = true
    }
    
    // Warning: - Fix this
    func setupScrollDirection() {
        switch readerConfig.scrollDirection {
        case .vertical, .defaultVertical, .horizontalWithVerticalContent:
            scrollView.isPagingEnabled = false
            //            paginationMode = .unpaginated
            scrollView.bounces = true
            break
        case .horizontal:
            scrollView.isPagingEnabled = true
            //            paginationMode = .leftToRight
            //            paginationBreakingMode = .page
            scrollView.bounces = false
            break
        }
    }
}


extension FolioReaderWebView {
    
    static func insertViewportScript() -> WKUserScript? {
        let source =  """
        var meta = document.createElement('meta');
        meta.setAttribute('name', 'viewport');
        meta.setAttribute('content', 'width=device-width');
        document.getElementsByTagName('head')[0].appendChild(meta);
        """
        let script = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        return script
    }
    
    static func injectCSSScript() -> WKUserScript? {
        
        guard let path = Bundle.frameworkBundle().path(forResource: "Style", ofType: "css") else {
            return nil
        }
        
        let source = """
        var style = document.createElement("link");
        style.type = "text/css";
        style.rel = "stylesheet";
        style.href = "\(path)";
        document.head.appendChild(style);
        """
        
        let script = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        return script
    }
    
    static func injectJSScript() -> WKUserScript? {
        
        guard let path = Bundle.frameworkBundle().path(forResource: "Bridge", ofType: "js") else { return nil }
        let source = """
        var script = document.createElement("script");
        script.type = "text/javascript";
        script.src = "\(path)";
        document.head.appendChild(script);
        """
        
        let script = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        return script
    }
    
    static func injectColorsScript(container:FolioReaderContainer) -> WKUserScript? {
        
        var mediaOverlayStyleColors = "\"\(container.readerConfig.mediaOverlayColor.hexString(false))\""
        mediaOverlayStyleColors += ", "
        mediaOverlayStyleColors += "\"\(container.readerConfig.mediaOverlayColor.highlightColor().hexString(false))\""
        
        let source = """
        var jsScript = document.createElement('script');
        jsScript.innerHTML = 'setMediaOverlayStyleColors(\(mediaOverlayStyleColors))';
        document.head.appendChild(jsScript);
        """
        
        let script = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        return script
    }
    
    static func injectHTMLClasses(container:FolioReaderContainer) -> WKUserScript? {
        var classes = container.folioReader.currentFont.cssIdentifier
        classes += " " + container.folioReader.currentMediaOverlayStyle.className()
        classes += container.folioReader.nightMode ? " nightMode" : ""
        classes += " \(container.folioReader.currentFontSize.cssIdentifier)"
        
        let source = """
        var root = document.documentElement;
        root.className += '\(classes)';
        """
        
        let script = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        return script
    }
}
