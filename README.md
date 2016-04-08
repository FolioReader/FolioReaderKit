
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

In your AppDelegate call `applicationWillResignActive` and `applicationWillTerminate`. This will save the reader state even if you kill the app.

```swift
import FolioReaderKit

func applicationWillResignActive(application: UIApplication) {
    FolioReader.applicationWillResignActive()
}

func applicationWillTerminate(application: UIApplication) {
    FolioReader.applicationWillTerminate()
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
- [x] In-App Dictionary
- [x] Media Overlays (Sync text rendering with audio playback)
- [x] TTS - Text to Speech Support
- [x] Parse epub cover image
- [ ] PDF support
- [ ] Book Search
- [ ] Add Notes to a Highlight
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
##### Media Overlays 😭
![Time left](https://raw.githubusercontent.com/FolioReader/FolioReaderKit/assets/media-overlays.gif)

### Documentation
For now the documentation is the sample project, I will write a better documentation in the next weeks.

You have a problem that cannot be solved by having a look at the example project? No problem, let's talk:
[![Join the chat at https://gitter.im/FolioReader/FolioReaderKit](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/FolioReader/FolioReaderKit?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

### Author
[**Heberti Almeida**](https://github.com/hebertialmeida)

- Follow me on **Twitter**: [**@hebertialmeida**](https://twitter.com/hebertialmeida)
- Contact me on **LinkedIn**: [**hebertialmeida**](http://linkedin.com/in/hebertialmeida)

### Donations

**This project needs you!** If you would like to support this project's further development, the creator of this project or the continuous maintenance of this project, **feel free to donate**. Your donation is highly appreciated. Thank you!

**PayPal**

 - [**Donate 5 $**] (https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=hebertialmeida%40gmail%2ecom&lc=US&item_name=FolioReader%20Libraries&amount=5%2e00&currency_code=USD&bn=PP%2dDonationsBF%3abtn_donate_SM%2egif%3aNonHosted): Thank's for creating this project, here's a tea (or some juice) for you!
 - [**Donate 10 $**] (https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=hebertialmeida%40gmail%2ecom&lc=US&item_name=FolioReader%20Libraries&amount=10%2e00&currency_code=USD&bn=PP%2dDonationsBF%3abtn_donate_SM%2egif%3aNonHosted): Wow, I am stunned. Let me take you to the movies!
 - [**Donate 15 $**] (https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=hebertialmeida%40gmail%2ecom&lc=US&item_name=FolioReader%20Libraries&amount=15%2e00&currency_code=USD&bn=PP%2dDonationsBF%3abtn_donate_SM%2egif%3aNonHosted): I really appreciate your work, let's grab some lunch! 
 - [**Donate 25 $**] (https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=hebertialmeida%40gmail%2ecom&lc=US&item_name=FolioReader%20Libraries&amount=25%2e00&currency_code=USD&bn=PP%2dDonationsBF%3abtn_donate_SM%2egif%3aNonHosted): That's some awesome stuff you did right there, dinner is on me!
 - [**Donate 50 $**] (https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=hebertialmeida%40gmail%2ecom&lc=US&item_name=FolioReader%20Libraries&amount=50%2e00&currency_code=USD&bn=PP%2dDonationsBF%3abtn_donate_SM%2egif%3aNonHosted): I really really want to support this project, great job!
 - [**Donate 100 $**] (https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=hebertialmeida%40gmail%2ecom&lc=US&item_name=FolioReader%20Libraries&amount=100%2e00&currency_code=USD&bn=PP%2dDonationsBF%3abtn_donate_SM%2egif%3aNonHosted): You are the man! This project saved me hours (if not days) of struggle and hard work, simply awesome!
 - Of course, you can also [**choose what you want to donate**](https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=hebertialmeida%40gmail%2ecom&lc=US&item_name=FolioReader%20Libraries&currency_code=USD&bn=PP%2dDonationsBF%3abtn_donate_SM%2egif%3aNonHosted), all donations are awesome!

### License
FolioReaderKit is available under the BSD license. See the [LICENSE file](https://github.com/FolioReader/FolioReaderKit/blob/master/LICENSE).
