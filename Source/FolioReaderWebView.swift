//
//  FolioReaderWebView.swift
//  FolioReaderKit
//
//  Created by Hans Seiffert on 21.09.16.
//  Copyright (c) 2016 Folio Reader. All rights reserved.
//

import UIKit

public class FolioReaderWebView: UIWebView {

	var isColors = false
	var isShare = false
    var isOneWord = false

	// MARK: - UIMenuController

	public override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
		guard readerConfig != nil && readerConfig.useReaderMenuController == true else {
			return super.canPerformAction(action, withSender: sender)
		}
        
		if isShare {
			return false
		} else if isColors {
			return false
		} else {
			if action == #selector(highlight(_:))
				|| (action == #selector(define(_:)) && isOneWord)
                || (action == #selector(play(_:)) && (book.hasAudio() || readerConfig.enableTTS))
				|| (action == #selector(share(_:)) && readerConfig.allowSharing)
				|| (action == #selector(copy(_:)) && readerConfig.allowSharing) {
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

        if let alert = alertController.popoverPresentationController {
            alert.sourceView = FolioReader.sharedInstance.readerCenter?.currentPage
            alert.sourceRect = sender.menuFrame
        }
        
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
		guard readerConfig.useReaderMenuController else {
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

        let menuController = UIMenuController.sharedMenuController()
        
		let highlightItem = UIMenuItem(title: readerConfig.localizedHighlightMenu, action: #selector(highlight(_:)))
		let playAudioItem = UIMenuItem(title: readerConfig.localizedPlayMenu, action: #selector(play(_:)))
		let defineItem = UIMenuItem(title: readerConfig.localizedDefineMenu, action: #selector(define(_:)))
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
        
        var menuItems = [shareItem]
        
        // menu on existing highlight
        if isShare {
            menuItems = [colorsItem, removeItem]
            if readerConfig.allowSharing {
                menuItems.append(shareItem)
            }
        } else if isColors {
            // menu for selecting highlight color
            menuItems = [yellowItem, greenItem, blueItem, pinkItem, underlineItem]
        } else {
            // default menu
            menuItems = [highlightItem, defineItem, shareItem]
            
            if book.hasAudio() || readerConfig.enableTTS {
                menuItems.insert(playAudioItem, atIndex: 0)
            }
            
            if !readerConfig.allowSharing {
                menuItems.removeLast()
            }
        }
        
        menuController.menuItems = menuItems
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
