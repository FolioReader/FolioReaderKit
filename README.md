
![FolioReader](https://raw.githubusercontent.com/FolioReader/FolioReaderKit/assets/folioreader.png)
FolioReaderKit is an ePub reader and parser framework for iOS written in Swift.

### Features

- [x] Custom Fonts
- [x] Custom Text Size
- [x] Text Highlight
- [x] List / Edit / Delete Highlights
- [x] Themes / Day mode / Night mode
- [x] Handle Internal and External Links
- [x] Portrait / Landscape
- [x] Reading Time Left / Pages left
- [x] Unzip and parse ePub files
- [ ] Book Search
- [ ] Write Some Tests
- [ ] Better Documentation

### Requirements

- iOS 8.0+
- Xcode 7.1+

### Installation

**FolioReaderKit** is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following lines to your Podfile:

```ruby
use_frameworks!
pod 'FolioReaderKit'
```

### Basic Usage

To get started, let's introduce MaterialView, a lightweight UIView Object that has flexibility in mind. Common controls have been added to make things easier. For example, let's make a circle view that has a shadow, border, and image.

```swift
import FolioReaderKit

func open(sender: AnyObject) {
    let config = FolioReaderConfig()
    let bookPath = NSBundle.mainBundle().pathForResource("book", ofType: "epub")
    FolioReader.presentReader(parentViewController: self, withEpubPath: bookPath!, andConfig: config)
}
```

### License

FolioReaderKit is available under the MIT license. See the LICENSE file for more info.
