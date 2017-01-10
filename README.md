
![FolioReader logo](https://raw.githubusercontent.com/FolioReader/FolioReaderKit/assets/folioreader.png)
FolioReaderKit is an ePub reader and parser framework for iOS written in Swift.

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
- [x] Vertical or/and Horizontal scrolling **<sup>NEW</sup>**
- [x] Share Custom Image Quotes **<sup>NEW</sup>**
- [ ] PDF support
- [ ] Book Search
- [ ] Add Notes to a Highlight

## Demo
##### Custom Fonts :smirk:
![Custom fonts](https://raw.githubusercontent.com/FolioReader/FolioReaderKit/assets/custom-fonts.gif)
##### Day and Night Mode :sunglasses:
![Day night mode](https://raw.githubusercontent.com/FolioReader/FolioReaderKit/assets/day-night.gif)
##### Text Highlighting :heart_eyes:
![Highlight](https://raw.githubusercontent.com/FolioReader/FolioReaderKit/assets/highlight.gif)
##### Reading Time Left :open_mouth:
![Time left](https://raw.githubusercontent.com/FolioReader/FolioReaderKit/assets/time-left.mov.gif)
##### Media Overlays 😭
![Time left](https://raw.githubusercontent.com/FolioReader/FolioReaderKit/assets/media-overlays.gif)

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
    pod 'FolioReaderKit', '~> 0.8'
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
- Xcode 8.2+

## Basic Usage

To get started, this is a simple usage sample of using the integrated view controller.

```swift
import FolioReaderKit

func open(sender: AnyObject) {
    let config = FolioReaderConfig()
    let bookPath = Bundle.main.path(forResource: "book", ofType: "epub")
    FolioReader.presentReader(parentViewController: self, withEpubPath: bookPath!, andConfig: config)
}
```

You can also use your own FolioReader View Controller like this.

```swift
let config = FolioReaderConfig()
let bookPath = Bundle.main.path(forResource: "book", ofType: "epub")
let epubVC = FolioReaderContainer(withConfig: config, epubPath: bookPath!, removeEpub: true)

// Present the epubVC view controller like every other UIViewController instance
present(epubVC, animated: true, completion: nil)
```

In your `AppDelegate` call `applicationWillResignActive` and `applicationWillTerminate`. This will save the reader state even if you kill the app.

```swift
import FolioReaderKit

func applicationWillResignActive(_ application: UIApplication) {
    FolioReader.applicationWillResignActive()
}

func applicationWillTerminate(_ application: UIApplication) {
    FolioReader.applicationWillTerminate()
}
```

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
For now the best documentation is the sample project. I ~~will write a better~~ am working to improve the code documentation, this is the current progress: [![CocoaPods](https://img.shields.io/cocoapods/metrics/doc-percent/FolioReaderKit.svg?maxAge=2592000)](http://cocoadocs.org/docsets/FolioReaderKit)

You have a problem that cannot be solved by having a look at the example project? No problem, let's talk:
[![Join the chat at https://gitter.im/FolioReader/FolioReaderKit](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/FolioReader/FolioReaderKit?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

### Author
[**Heberti Almeida**](https://github.com/hebertialmeida)

- Follow me on **Twitter**: [**@hebertialmeida**](https://twitter.com/hebertialmeida)
- Contact me on **LinkedIn**: [**hebertialmeida**](http://linkedin.com/in/hebertialmeida)

## Donations

**This project needs you!** If you would like to support this project's further development, the creator of this project or the continuous maintenance of this project, **feel free to donate**. Your donation is highly appreciated. Thank you!

**PayPal**

 - [**Donate 5 $**] (https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=hebertialmeida%40gmail%2ecom&lc=US&item_name=FolioReader%20Libraries&amount=5%2e00&currency_code=USD&bn=PP%2dDonationsBF%3abtn_donate_SM%2egif%3aNonHosted): Thank's for creating this project, here's a tea (or some juice) for you!
 - [**Donate 10 $**] (https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=hebertialmeida%40gmail%2ecom&lc=US&item_name=FolioReader%20Libraries&amount=10%2e00&currency_code=USD&bn=PP%2dDonationsBF%3abtn_donate_SM%2egif%3aNonHosted): Wow, I am stunned. Let me take you to the movies!
 - [**Donate 15 $**] (https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=hebertialmeida%40gmail%2ecom&lc=US&item_name=FolioReader%20Libraries&amount=15%2e00&currency_code=USD&bn=PP%2dDonationsBF%3abtn_donate_SM%2egif%3aNonHosted): I really appreciate your work, let's grab some lunch! 
 - [**Donate 25 $**] (https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=hebertialmeida%40gmail%2ecom&lc=US&item_name=FolioReader%20Libraries&amount=25%2e00&currency_code=USD&bn=PP%2dDonationsBF%3abtn_donate_SM%2egif%3aNonHosted): That's some awesome stuff you did right there, dinner is on me!
 - [**Donate 50 $**] (https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=hebertialmeida%40gmail%2ecom&lc=US&item_name=FolioReader%20Libraries&amount=50%2e00&currency_code=USD&bn=PP%2dDonationsBF%3abtn_donate_SM%2egif%3aNonHosted): I really really want to support this project, great job!
 - [**Donate 100 $**] (https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=hebertialmeida%40gmail%2ecom&lc=US&item_name=FolioReader%20Libraries&amount=100%2e00&currency_code=USD&bn=PP%2dDonationsBF%3abtn_donate_SM%2egif%3aNonHosted): You are the man! This project saved me hours (if not days) of struggle and hard work, simply awesome!
 - Of course, you can also [**choose what you want to donate**](https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=hebertialmeida%40gmail%2ecom&lc=US&item_name=FolioReader%20Libraries&currency_code=USD&bn=PP%2dDonationsBF%3abtn_donate_SM%2egif%3aNonHosted), all donations are awesome!

## License
FolioReaderKit is available under the BSD license. See the [LICENSE](https://github.com/FolioReader/FolioReaderKit/blob/master/LICENSE) file.
