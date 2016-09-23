//
//  FolioReaderWebView.swift
//  FolioReaderKit
//
//  Created by Hans Seiffert on 21.09.16.
//  Copyright (c) 2016 Folio Reader. All rights reserved.
//

import UIKit

class FolioReaderWebView: UIWebView {

	var isColors = false
	var isShare = false

	// MARK: - UIMenuController

	public override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {

		if(readerConfig == nil){
			return super.canPerformAction(action, withSender: sender)
		}

		// menu on existing highlight
		if isShare {
			if action == #selector(colors(_:)) || (action == #selector(share(_:)) && readerConfig.allowSharing) || action == #selector(remove(_:)) {
				return true
			}
			return false

			// menu for selecting highlight color
		} else if isColors {
			if action == #selector(setYellow(_:)) || action == #selector(setGreen(_:)) || action == #selector(setBlue(_:)) || action == #selector(setPink(_:)) || action == #selector(setUnderline(_:)) {
				return true
			}
			return false

			// default menu
		} else {
			var isOneWord = false
			if let result = js("getSelectedText()") where result.componentsSeparatedByString(" ").count == 1 {
				isOneWord = true
			}

			if action == #selector(highlight(_:))
				|| (action == #selector(define(_:)) && isOneWord)
				|| (action == #selector(play(_:)) && (book.hasAudio() || readerConfig.enableTTS))
				|| (action == #selector(share(_:)) && readerConfig.allowSharing)
				|| (action == #selector(NSObject.copy(_:)) && readerConfig.allowSharing) {
				return true
			}
			return false
		}
	}

	public override func canBecomeFirstResponder() -> Bool {
		return true
	}

	// MARK: - UIMenuController - Actions

	func share(sender: UIMenuController) {
		let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)

		let shareImage = UIAlertAction(title: readerConfig.localizedShareImageQuote, style: .Default, handler: { (action) -> Void in
			if self.isShare {
				if let textToShare = self.js("getHighlightContent()") {
					FolioReader.sharedInstance.readerCenter?.presentQuoteShare(textToShare)
				}
			} else {
				if let textToShare = self.js("getSelectedText()") {
					FolioReader.sharedInstance.readerCenter?.presentQuoteShare(textToShare)
					self.userInteractionEnabled = false
					self.userInteractionEnabled = true
				}
			}
			self.setMenuVisible(false)
		})

		let shareText = UIAlertAction(title: readerConfig.localizedShareTextQuote, style: .Default) { (action) -> Void in
			if self.isShare {
				if let textToShare = self.js("getHighlightContent()") {
					FolioReader.sharedInstance.readerCenter?.shareHighlight(textToShare, rect: sender.menuFrame)
				}
			} else {
				if let textToShare = self.js("getSelectedText()") {
					FolioReader.sharedInstance.readerCenter?.shareHighlight(textToShare, rect: sender.menuFrame)
				}
			}
			self.setMenuVisible(false)
		}

		let cancel = UIAlertAction(title: readerConfig.localizedCancel, style: .Cancel, handler: nil)

		alertController.addAction(shareImage)
		alertController.addAction(shareText)
		alertController.addAction(cancel)

		FolioReader.sharedInstance.readerCenter?.presentViewController(alertController, animated: true, completion: nil)
	}

	func colors(sender: UIMenuController?) {
		isColors = true
		createMenu(options: false)
		setMenuVisible(true)
	}

	func remove(sender: UIMenuController?) {
		if let removedId = js("removeThisHighlight()") {
			Highlight.removeById(removedId)
		}
		setMenuVisible(false)
	}

	func highlight(sender: UIMenuController?) {
		let highlightAndReturn = js("highlightString('\(HighlightStyle.classForStyle(FolioReader.currentHighlightStyle))')")
		let jsonData = highlightAndReturn?.dataUsingEncoding(NSUTF8StringEncoding)

		do {
			let json = try NSJSONSerialization.JSONObjectWithData(jsonData!, options: []) as! NSArray
			let dic = json.firstObject as! [String: String]
			let rect = CGRectFromString(dic["rect"]!)
			let startOffset = dic["startOffset"]!
			let endOffset = dic["endOffset"]!

			// Force remove text selection
			userInteractionEnabled = false
			userInteractionEnabled = true

			createMenu(options: true)
			setMenuVisible(true, andRect: rect)

			// Persist
			let html = js("getHTML()")
			if let highlight = Highlight.matchHighlight(html, andId: dic["id"]!, startOffset: startOffset, endOffset: endOffset) {
				highlight.persist()
			}
		} catch {
			print("Could not receive JSON")
		}
	}

	func define(sender: UIMenuController?) {
		let selectedText = js("getSelectedText()")

		setMenuVisible(false)
		userInteractionEnabled = false
		userInteractionEnabled = true

		let vc = UIReferenceLibraryViewController(term: selectedText! )
		vc.view.tintColor = readerConfig.tintColor
		FolioReader.sharedInstance.readerContainer.showViewController(vc, sender: nil)
	}

	func play(sender: UIMenuController?) {
		FolioReader.sharedInstance.readerAudioPlayer?.play()

		// Force remove text selection
		// @NOTE: this doesn't seem to always work
		userInteractionEnabled = false
		userInteractionEnabled = true
	}

	func setYellow(sender: UIMenuController?) {
		changeHighlightStyle(sender, style: .Yellow)
	}

	func setGreen(sender: UIMenuController?) {
		changeHighlightStyle(sender, style: .Green)
	}

	func setBlue(sender: UIMenuController?) {
		changeHighlightStyle(sender, style: .Blue)
	}

	func setPink(sender: UIMenuController?) {
		changeHighlightStyle(sender, style: .Pink)
	}

	func setUnderline(sender: UIMenuController?) {
		changeHighlightStyle(sender, style: .Underline)
	}

	func changeHighlightStyle(sender: UIMenuController?, style: HighlightStyle) {
		FolioReader.currentHighlightStyle = style.rawValue

		if let updateId = js("setHighlightStyle('\(HighlightStyle.classForStyle(style.rawValue))')") {
			Highlight.updateById(updateId, type: style)
		}
		colors(sender)
	}

	// MARK: - Create and show menu

	func createMenu(options options: Bool) {
		isShare = options

		let colors = UIImage(readerImageNamed: "colors-marker")
		let share = UIImage(readerImageNamed: "share-marker")
		let remove = UIImage(readerImageNamed: "no-marker")
		let yellow = UIImage(readerImageNamed: "yellow-marker")
		let green = UIImage(readerImageNamed: "green-marker")
		let blue = UIImage(readerImageNamed: "blue-marker")
		let pink = UIImage(readerImageNamed: "pink-marker")
		let underline = UIImage(readerImageNamed: "underline-marker")

		let highlightItem = UIMenuItem(title: readerConfig.localizedHighlightMenu, action: #selector(highlight(_:)))
		let playAudioItem = UIMenuItem(title: readerConfig.localizedPlayMenu, action: #selector(play(_:)))
		let defineItem = UIMenuItem(title: readerConfig.localizedDefineMenu, action: #selector(define(_:)))
		let colorsItem = UIMenuItem(title: "C", image: colors!, action: #selector(self.colors(_:)))
		let shareItem = UIMenuItem(title: "S", image: share!, action: #selector(self.share(_:)))
		let removeItem = UIMenuItem(title: "R", image: remove!, action: #selector(self.remove(_:)))
		let yellowItem = UIMenuItem(title: "Y", image: yellow!, action: #selector(setYellow(_:)))
		let greenItem = UIMenuItem(title: "G", image: green!, action: #selector(setGreen(_:)))
		let blueItem = UIMenuItem(title: "B", image: blue!, action: #selector(setBlue(_:)))
		let pinkItem = UIMenuItem(title: "P", image: pink!, action: #selector(setPink(_:)))
		let underlineItem = UIMenuItem(title: "U", image: underline!, action: #selector(setUnderline(_:)))

		let menuItems = [playAudioItem, highlightItem, defineItem, colorsItem, removeItem, yellowItem, greenItem, blueItem, pinkItem, underlineItem, shareItem]

		UIMenuController.sharedMenuController().menuItems = menuItems
	}

	func setMenuVisible(menuVisible: Bool, animated: Bool = true, andRect rect: CGRect = CGRectZero) {
		if !menuVisible && isShare || !menuVisible && isColors {
			isColors = false
			isShare = false
		}

		if menuVisible  {
			if !CGRectEqualToRect(rect, CGRectZero) {
				UIMenuController.sharedMenuController().setTargetRect(rect, inView: self)
			}
		}

		UIMenuController.sharedMenuController().setMenuVisible(menuVisible, animated: animated)
	}

	// MARK: - Java Script Bridge

	func js(script: String) -> String? {
		let callback = self.stringByEvaluatingJavaScriptFromString(script)
		if callback!.isEmpty { return nil }
		return callback
	}

	// MARK: WebView direction config

	func setupScrollDirection() {
		switch readerConfig.scrollDirection {
		case .vertical, .horizontalWithVerticalContent:
			scrollView.pagingEnabled = false
			paginationMode = .Unpaginated
			scrollView.bounces = true
			break
		case .horizontal:
			scrollView.pagingEnabled = true
			paginationMode = .LeftToRight
			paginationBreakingMode = .Page
			scrollView.bounces = false
			break
		}
	}
}
