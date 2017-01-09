//
//  FolioReaderWebView.swift
//  FolioReaderKit
//
//  Created by Hans Seiffert on 21.09.16.
//  Copyright (c) 2016 Folio Reader. All rights reserved.
//

import UIKit

open class FolioReaderWebView: UIWebView {

	var isColors = false
	var isShare = false
    var isOneWord = false

	// MARK: - UIMenuController

	open override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
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

	// MARK: - UIMenuController - Actions

	func share(_ sender: UIMenuController) {
		let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

		let shareImage = UIAlertAction(title: readerConfig.localizedShareImageQuote, style: .default, handler: { (action) -> Void in
			if self.isShare {
				if let textToShare = self.js("getHighlightContent()") {
					FolioReader.shared.readerCenter?.presentQuoteShare(textToShare)
				}
			} else {
				if let textToShare = self.js("getSelectedText()") {
					FolioReader.shared.readerCenter?.presentQuoteShare(textToShare)

					self.clearTextSelection()
				}
			}
			self.setMenuVisible(false)
		})

		let shareText = UIAlertAction(title: readerConfig.localizedShareTextQuote, style: .default) { (action) -> Void in
			if self.isShare {
				if let textToShare = self.js("getHighlightContent()") {
					FolioReader.shared.readerCenter?.shareHighlight(textToShare, rect: sender.menuFrame)
				}
			} else {
				if let textToShare = self.js("getSelectedText()") {
					FolioReader.shared.readerCenter?.shareHighlight(textToShare, rect: sender.menuFrame)
				}
			}
			self.setMenuVisible(false)
		}

		let cancel = UIAlertAction(title: readerConfig.localizedCancel, style: .cancel, handler: nil)

		alertController.addAction(shareImage)
		alertController.addAction(shareText)
		alertController.addAction(cancel)

        if let alert = alertController.popoverPresentationController {
            alert.sourceView = FolioReader.shared.readerCenter?.currentPage
            alert.sourceRect = sender.menuFrame
        }
        
		FolioReader.shared.readerCenter?.present(alertController, animated: true, completion: nil)
	}

	func colors(_ sender: UIMenuController?) {
		isColors = true
		createMenu(options: false)
		setMenuVisible(true)
	}

	func remove(_ sender: UIMenuController?) {
		if let removedId = js("removeThisHighlight()") {
			Highlight.removeById(removedId)
		}
		setMenuVisible(false)
	}

	func highlight(_ sender: UIMenuController?) {
		let highlightAndReturn = js("highlightString('\(HighlightStyle.classForStyle(FolioReader.currentHighlightStyle))')")
		let jsonData = highlightAndReturn?.data(using: String.Encoding.utf8)

		do {
			let json = try JSONSerialization.jsonObject(with: jsonData!, options: []) as! NSArray
			let dic = json.firstObject as! [String: String]
			let rect = CGRectFromString(dic["rect"]!)
			let startOffset = dic["startOffset"]!
			let endOffset = dic["endOffset"]!

			self.clearTextSelection()

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

	func define(_ sender: UIMenuController?) {
		let selectedText = js("getSelectedText()")

		setMenuVisible(false)

		self.clearTextSelection()

		let vc = UIReferenceLibraryViewController(term: selectedText! )
		vc.view.tintColor = readerConfig.tintColor
		FolioReader.shared.readerContainer.show(vc, sender: nil)
	}

	func play(_ sender: UIMenuController?) {
		FolioReader.shared.readerAudioPlayer?.play()

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
		FolioReader.currentHighlightStyle = style.rawValue

		if let updateId = js("setHighlightStyle('\(HighlightStyle.classForStyle(style.rawValue))')") {
			Highlight.updateById(updateId, type: style)
		}
		colors(sender)
	}

	// MARK: - Create and show menu

	func createMenu(options: Bool) {
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

        let menuController = UIMenuController.shared
        
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
                menuItems.insert(playAudioItem, at: 0)
            }
            
            if !readerConfig.allowSharing {
                menuItems.removeLast()
            }
        }
        
        menuController.menuItems = menuItems
	}

	func setMenuVisible(_ menuVisible: Bool, animated: Bool = true, andRect rect: CGRect = CGRect.zero) {
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

	@discardableResult func js(_ script: String) -> String? {
		let callback = self.stringByEvaluatingJavaScript(from: script)
		if callback!.isEmpty { return nil }
		return callback
	}

	// MARK: WebView

	func clearTextSelection() {
		// Forces text selection clearing
		// @NOTE: this doesn't seem to always work

		self.isUserInteractionEnabled = false
		self.isUserInteractionEnabled = true
	}

	func setupScrollDirection() {
		switch readerConfig.scrollDirection {
		case .vertical, .defaultVertical, .horizontalWithVerticalContent:
			scrollView.isPagingEnabled = false
			paginationMode = .unpaginated
			scrollView.bounces = true
			break
		case .horizontal:
			scrollView.isPagingEnabled = true
			paginationMode = .leftToRight
			paginationBreakingMode = .page
			scrollView.bounces = false
			break
		}
	}
}
