# JSQWebViewController

[![Build Status](https://secure.travis-ci.org/jessesquires/JSQWebViewController.svg)](http://travis-ci.org/jessesquires/JSQWebViewController) [![Version Status](https://img.shields.io/cocoapods/v/JSQWebViewController.svg)][podLink] [![license MIT](https://img.shields.io/cocoapods/l/JSQWebViewController.svg)][mitLink] [![codecov.io](https://img.shields.io/codecov/c/github/jessesquires/JSQWebViewController.svg)](http://codecov.io/github/jessesquires/JSQWebViewController) [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) [![Platform](https://img.shields.io/cocoapods/p/JSQWebViewController.svg)][docsLink]

*A lightweight Swift WebKit view controller for iOS*

![screenshot](https://raw.githubusercontent.com/jessesquires/JSQWebViewController/develop/Screenshots/screenshot_0.png)
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
![screenshot](https://raw.githubusercontent.com/jessesquires/JSQWebViewController/develop/Screenshots/screenshot_1.png)

> **NOTE:** As of iOS 9, this library is no longer necessary. 
>
> You should probably use [`SFSafariViewController`](https://developer.apple.com/library/prerelease/ios/documentation/SafariServices/Reference/SFSafariViewController_Ref/index.html) instead.

## Requirements

* iOS 8+
* Swift 2.2+

## Installation

#### [CocoaPods](http://cocoapods.org) (recommended)

````ruby
use_frameworks!

# For latest release in cocoapods
pod 'JSQWebViewController'

# Feeling adventurous? Get the latest on develop
pod 'JSQWebViewController', :git => 'https://github.com/jessesquires/JSQWebViewController.git', :branch => 'develop'
````

#### [Carthage](https://github.com/Carthage/Carthage)

````bash
github "jessesquires/JSQWebViewController"
````

## Documentation

Read the [docs][docsLink]. Generated with [jazzy](https://github.com/realm/jazzy). Hosted by [GitHub Pages](https://pages.github.com). More information on the [`gh-pages`](https://github.com/jessesquires/JSQWebViewController/tree/gh-pages) branch.

## Getting Started

````swift
import JSQWebViewController

let controller = WebViewController(url: NSURL(string: "http://jessesquires.com")!)
let nav = UINavigationController(rootViewController: controller)
presentViewController(nav, animated: true, completion: nil)
````

See the included example app, open `JSQWebViewController.xcworkspace`.

## Contribute

Please follow these sweet [contribution guidelines](https://github.com/jessesquires/HowToContribute).

## Credits

Created and maintained by [**@jesse_squires**](https://twitter.com/jesse_squires).

## License

`JSQWebViewController` is released under an [MIT License][mitLink]. See `LICENSE` for details.

>**Copyright &copy; 2015 Jesse Squires.**

*Please provide attribution, it is greatly appreciated.*

[mitLink]:http://opensource.org/licenses/MIT
[docsLink]:http://www.jessesquires.com/JSQWebViewController
[podLink]:https://cocoapods.org/pods/JSQWebViewController
