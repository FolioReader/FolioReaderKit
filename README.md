
![FolioReader logo](https://raw.githubusercontent.com/FolioReader/FolioReaderKit/assets/folioreader.png)
FolioReaderKit is an ePub reader and parser framework for iOS written in Swift.

![Version](https://img.shields.io/cocoapods/v/FolioReaderKit.svg)
![Downloads](https://img.shields.io/cocoapods/dt/FolioReaderKit.svg)
![Apps using](https://img.shields.io/cocoapods/at/FolioReaderKit.svg)
![License](https://img.shields.io/cocoapods/l/FolioReaderKit.svg)

## Features

- [x] ePub 2 and ePub 3 support
- [x] Custom Fonts
- [x] Custom Text Size
- [x] Text Highlighting
- [x] List / Edit / Delete Highlights
- [x] Themes / Day mode / Night mode
- [x] Handle Internal and External Links
- [x] Portrait / Landscape
- [x] Reading Time Left / Pages left
- [x] In-App Dictionary
- [x] Media Overlays (Sync text rendering with audio playback)
- [x] TTS - Text to Speech Support
- [x] Parse epub cover image
- [x] RTL Support
- [x] Vertical or/and Horizontal scrolling
- [x] Share Custom Image Quotes **<sup>NEW</sup>**
- [x] Support multiple instances at same time, like parallel reading **<sup>NEW</sup>**
- [ ] Book Search
- [ ] Add Notes to a Highlight

## Demo

**Custom Fonts :smirk:**   |  **Text Highlighting :heart_eyes:**
:-------------------------:|:-------------------------:
![Custom fonts](https://raw.githubusercontent.com/FolioReader/FolioReaderKit/assets/custom-fonts.gif)  |  ![Highlight](https://raw.githubusercontent.com/FolioReader/FolioReaderKit/assets/highlight.gif)

**Reading Time Left :open_mouth:**   |  **Media Overlays 😭**
:-------------------------:|:-------------------------:
![Time left](https://raw.githubusercontent.com/FolioReader/FolioReaderKit/assets/time-left.mov.gif)  |  ![Media Overlays](https://raw.githubusercontent.com/FolioReader/FolioReaderKit/assets/media-overlays.gif)

## Installation

**FolioReaderKit** is available through [CocoaPods](http://cocoapods.org) and [Carthage](https://github.com/Carthage/Carthage). 

### Cocoapods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

To integrate FolioReaderKit into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!

target '<Your Target Name>' do
    pod 'FolioReaderKit'
end
```

Then, run the following command:

```bash
$ pod install
```

Alternatively to give it a test run, run the command:

```bash
$ pod try FolioReaderKit
```

### Carthage

Add the following to your [Cartfile](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#cartfile)

```ruby
github "FolioReader/FolioReaderKit"
```

Run the following command:

```bash
$ carthage update --platform iOS --no-use-binaries
```

Then, follow the steps as described in Carthage's [README](https://github.com/Carthage/Carthage#adding-frameworks-to-an-application).

## Requirements

- iOS 8.0+
- Xcode 9+

## Basic Usage

To get started, this is a simple usage sample of using the integrated view controller.

```swift
import FolioReaderKit

func open(sender: AnyObject) {
    let config = FolioReaderConfig()
    let bookPath = Bundle.main.path(forResource: "book", ofType: "epub")
    let folioReader = FolioReader()
    folioReader.presentReader(parentViewController: self, withEpubPath: bookPath!, andConfig: config)
}
```

For more usage examples check the [Example](/Example) folder.

## Storyboard

To get started, here is a simple example how to use the integrated view controller with storyboards.

```swift
import FolioReaderKit

class StoryboardFolioReaderContrainer: FolioReaderContainer {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let config = FolioReaderConfig()
        config.scrollDirection = .horizontalWithVerticalContent
        
        guard let bookPath = Bundle.main.path(forResource: "The Silver Chair", ofType: "epub") else { return }
        setupConfig(config, epubPath: bookPath)
    }
}
```

Go to your storyboard file, choose or create the view controller that should present the epub reader. In the identity inspector set StoryboardFolioReaderContrainer as class.

## Documentation
Checkout [Example](/Example) and [API Documentation](http://cocoadocs.org/docsets/FolioReaderKit)

You can always use the header-doc. (use **alt+click** in Xcode)

<img src="https://raw.githubusercontent.com/FolioReader/FolioReaderKit/assets/header-doc.png" width="521px"/>

### Migration
If you are migrating to a newer version check out [MIGRATION](/MIGRATION.md) and [CHANGELOG](/CHANGELOG.md).

## Author
[**Heberti Almeida**](https://github.com/hebertialmeida)

- Follow me on **Twitter**: [**@hebertialmeida**](https://twitter.com/hebertialmeida)
- Contact me on **LinkedIn**: [**hebertialmeida**](http://linkedin.com/in/hebertialmeida)

## License
FolioReaderKit is available under the BSD license. See the [LICENSE](/LICENSE) file.
