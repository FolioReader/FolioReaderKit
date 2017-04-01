# Migration Guide to version 1.2.0

## Introduction

--

## What changed?

### Class: FolioReader

### Class: Highlight

The following functions now need a FolioReaderConfig object as parameter:

public static func all(withConfiguration readerConfig: FolioReaderConfig) -> [Highlight]
public static func allByBookId(withConfiguration readerConfig: FolioReaderConfig, bookId: String, andPage page: NSNumber? = nil) -> [Highlight]
public static func updateById(withConfiguration readerConfig: FolioReaderConfig, highlightId: String, type: HighlightStyle)
public static func removeById(withConfiguration readerConfig: FolioReaderConfig, highlightId: String)
public func remove(withConfiguration readerConfig: FolioReaderConfig)
public func persist(withConfiguration readerConfig: FolioReaderConfig, completion: Completion? = nil)
@discardableResult public static func removeFromHTMLById(withinPage page: FolioReaderPage?, highlightId: String) -> String?

### Class: FREpubParser

The `parseCoverImage` function now takes an optional parameter indicating the unzip path.
Before it used the static shared instance. 
Default value is the Documents directory.

func parseCoverImage(_ epubPath: String, unzipPath: String? = nil) -> UIImage?

### Class: UIKit classes extensions

The following functions now need a FolioReaderConfig object as parameter:

UICollectionViewScrollDirection.direction(withConfiguration readerConfig: FolioReaderConfig) -> UICollectionViewScrollDirection
UICollectionViewScrollPosition.direction(withConfiguration readerConfig: FolioReaderConfig) -> UICollectionViewScrollPosition
CGPoint.forDirection(withConfiguration readerConfig: FolioReaderConfig) -> CGFloat
CGSize.forDirection(withConfiguration readerConfig: FolioReaderConfig) -> CGFloat
CGSize.forReverseDirection(withConfiguration readerConfig: FolioReaderConfig) -> CGFloat
CGRect.forDirection(withConfiguration readerConfig: FolioReaderConfig) -> CGFloat
ScrollDirection.negative(withConfiguration readerConfig: FolioReaderConfig) -> ScrollDirection
ScrollDirection.positive(withConfiguration readerConfig: FolioReaderConfig) -> ScrollDirection
UIImage.ignoreSystemTint(withConfiguration readerConfig: FolioReaderConfig) -> UIImage?
UIViewController.setCloseButton(withConfiguration readerConfig: FolioReaderConfig)