# Migration Guide to version 1.2.0

## Introduction

That new version introduce a new feature that allows you to have multiple instances of a `FolioReader` at the same time in your app.
All instances now have their own stored informations and nothing is shared between them.

Before, the library used a global static `FolioReader` that contained all relevant objects (`ReaderContainer`, `ReaderConfig`, `AudioPlayer`, etc).
Even though this class is still used internaly, all of its static functions have been deprecated.

You must now use the (same) functions of a local instance (from your code) instead.

## What changed?

Here is the list of changes made to the `public` functions.

### Class: FolioReader

The function `getCoverImage` now has an extra parameter indicating the unzip path for the epub.

```
class func getCoverImage(_ epubPath: String, unzipPath: String? = nil) -> UIImage?
```

#### AppDelegate

The functions to be called within the AppDelegate methods have been deprecated.
Before you needed to save the reader state on `applicationWillResignActive` and `applicationWillTerminate`, now it is internally handled and simplify the integration.

#### Deprecated static functions

All class/static functions have been deprecated and replaced by instance functions. Nor the static functions or the shared instances should be used anymore.

List of all deprecated `FolioReader` static attributes and functions:

```
open static var shared : FolioReader
static var currentMediaOverlayStyle: MediaOverlayStyle
open class var nightMode: Bool
open class var currentFont: FolioReaderFont
open class var currentFontSize: FolioReaderFontSize
open class var currentScrollDirection: Int
open class var currentAudioRate: Int
open class var isReaderReady : Bool
open class func saveReaderState()
open class func close()
open class var currentHighlightStyle: Int
open class var needsRTLChange: Bool
```

It is possible to access all this attributes throught the instance object:
```swift
let folioReader = FolioReader()
folioReader.nightMode
``` 

### Class: FolioReaderContainer

The public `init` function now takes an extra `FolioReader` instance as parameter.

```
public init(withConfig config: FolioReaderConfig, folioReader: FolioReader, epubPath path: String, removeEpub: Bool = true)
```

### Class: FolioReaderDelegate

The function `folioReaderDidClosed` has been renamed `folioReaderDidClose`.
It also has a new `FolioReader` parameter.

```
func folioReaderDidClose(_ folioReader: FolioReader)
```

### Class: Highlight

The following functions now need a `FolioReaderConfig` object as parameter:

```
public static func all(withConfiguration readerConfig: FolioReaderConfig) -> [Highlight]
public static func allByBookId(withConfiguration readerConfig: FolioReaderConfig, bookId: String, andPage page: NSNumber? = nil) -> [Highlight]
public static func updateById(withConfiguration readerConfig: FolioReaderConfig, highlightId: String, type: HighlightStyle)
public static func removeById(withConfiguration readerConfig: FolioReaderConfig, highlightId: String)
public func remove(withConfiguration readerConfig: FolioReaderConfig)
public func persist(withConfiguration readerConfig: FolioReaderConfig, completion: Completion? = nil)
@discardableResult public static func removeFromHTMLById(withinPage page: FolioReaderPage?, highlightId: String) -> String?
```

### Class: FREpubParser

The `parseCoverImage` function now takes an optional parameter indicating the unzip path.
Before it used the static shared instance. 
Default value is the Documents directory.

```
func parseCoverImage(_ epubPath: String, unzipPath: String? = nil) -> UIImage?
```

### Class: UIKit classes extensions

The following functions now need a `FolioReaderConfig` object as parameter:

```
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
```

### Class: none

The following functions have been deprecated and replaced by functions within the `FolioReader` and the `FolioReaderConfig` classes.

```
func isNight<T> (_ f: T, _ l: T) -> T
func isDirection<T> (_ vertical: T, _ horizontal: T, _ horizontalContentVertical: T? = nil) -> T
```
