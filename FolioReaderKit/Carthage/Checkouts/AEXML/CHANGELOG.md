# Changelog

## Version 3.0.0

- Fixed deprecation warnings in Xcode 7.3 (7D175)
- Improved error handling logic (now returns empty element with `error` property)
- Replaced `escapedStringValue` property with `xmlEscaped` property (String extension)
- Added escaping of attribute values
- Added `xmlStringCompact` property
- Added support for Swift Package Manager
- Added ability to create and configure `NSXMLParserOptions` from another package
- Removed inheritance from NSObject (in AEXMLElement)
- Created separate example project (AEXMLDemo)
- Fixed several reported issues
- Documentation improvements

## Version 2.1.0

- Fixed deprecation warnings in Xcode 7.3 Beta (Swift 2.2)
- Added possibility to configure options for NSXMLParser
- Added Changelog :)

## Version 2.0.1

- Added support for Carthage
- Added support for watchOS and tvOS

## Version 2.0.0

- API changes
- Fixed build errors and warnings in Xcode 7.0
- Bumped deployment target to iOS 8.0
- Added error throwing instead of NSError & nil
- Added support for OSX

## Version 1.3.1

- Moved documentation from README.md to code

## Version 1.3.0

- Fixed memory leak
- Added option to remove element from parent
- Some more unit tests

## Version 1.2.1

- Released to CocoaPods

## Version 0.0.1

- Initial version