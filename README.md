
![FolioReader logo](https://raw.githubusercontent.com/FolioReader/FolioReaderKit/assets/folioreader.png)
FolioReaderKit is an ePub reader and parser framework for iOS written in Swift.

### Installation

**FolioReaderKit** is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following lines to your Podfile:

```ruby
use_frameworks!
pod 'FolioReaderKit'
```

### Requirements

- iOS 8.0+
- Xcode 7.1+

### Basic Usage

To get started, this is a simple usage sample.

```swift
import FolioReaderKit

func open(sender: AnyObject) {
    let config = FolioReaderConfig()
    let bookPath = NSBundle.mainBundle().pathForResource("book", ofType: "epub")
    FolioReader.presentReader(parentViewController: self, withEpubPath: bookPath!, andConfig: config)
}
```

### Features

- [x] Custom Fonts
- [x] Custom Text Size
- [x] Text Highlighting
- [x] List / Edit / Delete Highlights
- [x] Themes / Day mode / Night mode
- [x] Handle Internal and External Links
- [x] Portrait / Landscape
- [x] Reading Time Left / Pages left
- [x] Unzip and parse ePub files
- [ ] Book Search
- [ ] Add Notes to a Highlight
- [ ] Write Some Tests
- [ ] Better Documentation

### Demo
##### Custom Fonts :smirk:
![Custom fonts](https://raw.githubusercontent.com/FolioReader/FolioReaderKit/assets/custom-fonts.gif)
##### Day and Night Mode :sunglasses:
![Day night mode](https://raw.githubusercontent.com/FolioReader/FolioReaderKit/assets/day-night.gif)
##### Text Highlighting :heart_eyes:
![Highlight](https://raw.githubusercontent.com/FolioReader/FolioReaderKit/assets/highlight.gif)
##### Reading Time Left :open_mouth:
![Time left](https://raw.githubusercontent.com/FolioReader/FolioReaderKit/assets/time-left.mov.gif)

### Documentation
For now the documentation is the sample project, I will write a better documentation in the next weeks.

You have a problem that cannot be solved by having a look at the example project? No problem, let's talk:
[![Join the chat at https://gitter.im/FolioReader/FolioReaderKit](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/FolioReader/FolioReaderKit?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

### License

FolioReaderKit is available under the GNU General Public license. See the LICENSE file for more info.
