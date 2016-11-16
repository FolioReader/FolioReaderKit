# Change Log

## [Unreleased](https://github.com/FolioReader/FolioReaderKit/tree/HEAD)

[Full Changelog](https://github.com/FolioReader/FolioReaderKit/compare/1.0.0...HEAD)

**Fixed bugs:**

- Unable to integrate using carthage  [\#98](https://github.com/FolioReader/FolioReaderKit/issues/98)

## [1.0.0](https://github.com/FolioReader/FolioReaderKit/tree/1.0.0) (2016-10-07)
[Full Changelog](https://github.com/FolioReader/FolioReaderKit/compare/0.9.4...1.0.0)

**Closed issues:**

- Swift 3 migration [\#148](https://github.com/FolioReader/FolioReaderKit/issues/148)

**Merged pull requests:**

- Swift3 [\#162](https://github.com/FolioReader/FolioReaderKit/pull/162) ([hebertialmeida](https://github.com/hebertialmeida))

## [0.9.4](https://github.com/FolioReader/FolioReaderKit/tree/0.9.4) (2016-10-06)
[Full Changelog](https://github.com/FolioReader/FolioReaderKit/compare/0.9.3...0.9.4)

**Merged pull requests:**

- Swift23 [\#161](https://github.com/FolioReader/FolioReaderKit/pull/161) ([hebertialmeida](https://github.com/hebertialmeida))

## [0.9.3](https://github.com/FolioReader/FolioReaderKit/tree/0.9.3) (2016-10-06)
[Full Changelog](https://github.com/FolioReader/FolioReaderKit/compare/0.9.2...0.9.3)

**Implemented enhancements:**

- Extend flexibility. Use folio reader kit with vc which frame's is smaller than the screen size. [\#119](https://github.com/FolioReader/FolioReaderKit/issues/119)
- Replace UIMenuItem-CXAImageSupport for MenuItemKit [\#41](https://github.com/FolioReader/FolioReaderKit/issues/41)
- Provide a config which disables the readers `UIMenuController` [\#154](https://github.com/FolioReader/FolioReaderKit/pull/154) ([tschob](https://github.com/tschob))

**Fixed bugs:**

- UIMenuItem White Color [\#158](https://github.com/FolioReader/FolioReaderKit/issues/158)
- Page content disappear sometimes [\#152](https://github.com/FolioReader/FolioReaderKit/issues/152)
- Crash on SSZipArchive [\#83](https://github.com/FolioReader/FolioReaderKit/issues/83)

**Closed issues:**

- Scroll to a specific page and specific page number [\#130](https://github.com/FolioReader/FolioReaderKit/issues/130)
- Build on XCode 8  [\#129](https://github.com/FolioReader/FolioReaderKit/issues/129)

**Merged pull requests:**

- 🎉 Fix and closes issue \#158 and \#41 [\#159](https://github.com/FolioReader/FolioReaderKit/pull/159) ([hebertialmeida](https://github.com/hebertialmeida))
- Prevent the default click behavior and the passing to other elements … [\#157](https://github.com/FolioReader/FolioReaderKit/pull/157) ([tschob](https://github.com/tschob))
- Add `pageWillLoad\(\)` delegate method [\#156](https://github.com/FolioReader/FolioReaderKit/pull/156) ([tschob](https://github.com/tschob))
-  Provide a way to perform java script code in a readers page from external code [\#155](https://github.com/FolioReader/FolioReaderKit/pull/155) ([tschob](https://github.com/tschob))
- Add `pageDidLoad\(\)` method to the reader center delegate [\#153](https://github.com/FolioReader/FolioReaderKit/pull/153) ([tschob](https://github.com/tschob))
- Prevent to always unzip the ePub, performance improvement 📈 [\#151](https://github.com/FolioReader/FolioReaderKit/pull/151) ([hebertialmeida](https://github.com/hebertialmeida))
- Feature/html content adjustments [\#150](https://github.com/FolioReader/FolioReaderKit/pull/150) ([tschob](https://github.com/tschob))
- Provide touch point for class based on click listeners - improves Issue/132 [\#149](https://github.com/FolioReader/FolioReaderKit/pull/149) ([tschob](https://github.com/tschob))

## [0.9.2](https://github.com/FolioReader/FolioReaderKit/tree/0.9.2) (2016-09-20)
[Full Changelog](https://github.com/FolioReader/FolioReaderKit/compare/0.9.1...0.9.2)

**Implemented enhancements:**

- Make settings from the font menu accessable to external code  [\#133](https://github.com/FolioReader/FolioReaderKit/issues/133)

**Fixed bugs:**

- Crash [\#146](https://github.com/FolioReader/FolioReaderKit/issues/146)
- Crash at file open [\#144](https://github.com/FolioReader/FolioReaderKit/issues/144)
- Swift 2.3 [\#143](https://github.com/FolioReader/FolioReaderKit/issues/143)

**Merged pull requests:**

- Use SSZipArchive version 1.5 [\#147](https://github.com/FolioReader/FolioReaderKit/pull/147) ([tschob](https://github.com/tschob))
- Fix class based listeners on click closure parameter naming [\#145](https://github.com/FolioReader/FolioReaderKit/pull/145) ([tschob](https://github.com/tschob))

## [0.9.1](https://github.com/FolioReader/FolioReaderKit/tree/0.9.1) (2016-09-16)
[Full Changelog](https://github.com/FolioReader/FolioReaderKit/compare/0.9.0...0.9.1)

## [0.9.0](https://github.com/FolioReader/FolioReaderKit/tree/0.9.0) (2016-09-16)
[Full Changelog](https://github.com/FolioReader/FolioReaderKit/compare/0.8.6...0.9.0)

**Implemented enhancements:**

- Provide a way to block the user from leaving a specific `FolioReaderPage` [\#134](https://github.com/FolioReader/FolioReaderKit/issues/134)
- Ability to share image quotes [\#109](https://github.com/FolioReader/FolioReaderKit/issues/109)
- Make UI Classes Public and add method of presenting custom Subclasses [\#71](https://github.com/FolioReader/FolioReaderKit/issues/71)
- Request: Improved Objective-C compatibility [\#51](https://github.com/FolioReader/FolioReaderKit/issues/51)
- Make the changePage and scrollTo functionality accesable to the public [\#128](https://github.com/FolioReader/FolioReaderKit/pull/128) ([tschob](https://github.com/tschob))
- Feature/share image quotes, closes \#109 [\#125](https://github.com/FolioReader/FolioReaderKit/pull/125) ([hebertialmeida](https://github.com/hebertialmeida))

**Closed issues:**

- Perform a custom block if a link with specified class + parameter name is tapped. [\#132](https://github.com/FolioReader/FolioReaderKit/issues/132)
- Play menu item for text is enable even if TTS is disabled [\#123](https://github.com/FolioReader/FolioReaderKit/issues/123)

**Merged pull requests:**

- Expose `pageDidLoad` method to external code [\#139](https://github.com/FolioReader/FolioReaderKit/pull/139) ([tschob](https://github.com/tschob))
- Expose font settings - closes \#33 [\#138](https://github.com/FolioReader/FolioReaderKit/pull/138) ([tschob](https://github.com/tschob))
- Custom click listener - closes \#132 [\#137](https://github.com/FolioReader/FolioReaderKit/pull/137) ([tschob](https://github.com/tschob))
- Add option to en-/disable the scrolling between chapters - \#134 [\#136](https://github.com/FolioReader/FolioReaderKit/pull/136) ([tschob](https://github.com/tschob))
- Now the project is portable with storyboard. With no functionality \(n… [\#121](https://github.com/FolioReader/FolioReaderKit/pull/121) ([PanajotisMaroungas](https://github.com/PanajotisMaroungas))
- Refine localization [\#120](https://github.com/FolioReader/FolioReaderKit/pull/120) ([KyonLi](https://github.com/KyonLi))

## [0.8.6](https://github.com/FolioReader/FolioReaderKit/tree/0.8.6) (2016-08-17)
[Full Changelog](https://github.com/FolioReader/FolioReaderKit/compare/0.8.5...0.8.6)

## [0.8.5](https://github.com/FolioReader/FolioReaderKit/tree/0.8.5) (2016-08-17)
[Full Changelog](https://github.com/FolioReader/FolioReaderKit/compare/0.8.4...0.8.5)

**Fixed bugs:**

- Crash at reader audio player [\#115](https://github.com/FolioReader/FolioReaderKit/issues/115)

**Closed issues:**

- Steps to Build Example From Clean Clone? [\#118](https://github.com/FolioReader/FolioReaderKit/issues/118)

## [0.8.4](https://github.com/FolioReader/FolioReaderKit/tree/0.8.4) (2016-08-16)
[Full Changelog](https://github.com/FolioReader/FolioReaderKit/compare/0.8.3...0.8.4)

**Implemented enhancements:**

- variable hideBars, scroll to navigate through paragraphs and scroll to read the content are added, README.md is updated [\#107](https://github.com/FolioReader/FolioReaderKit/pull/107) ([PanajotisMaroungas](https://github.com/PanajotisMaroungas))

**Fixed bugs:**

- Audio stops playing after clicking a toolbar icon [\#112](https://github.com/FolioReader/FolioReaderKit/issues/112)
- Layout bug after change the orientation [\#111](https://github.com/FolioReader/FolioReaderKit/issues/111)

**Closed issues:**

- Make all required NSCoder initializers `fatalError\(\)` [\#75](https://github.com/FolioReader/FolioReaderKit/issues/75)

**Merged pull requests:**

- Added a bugfix to UIWebViews canPerformAction category [\#116](https://github.com/FolioReader/FolioReaderKit/pull/116) ([barteljan](https://github.com/barteljan))
- Fix minor bug when orientation changes for mode sectionHorizontalContentVertical [\#114](https://github.com/FolioReader/FolioReaderKit/pull/114) ([PanajotisMaroungas](https://github.com/PanajotisMaroungas))
- Make all required NSCoder initialisers fatalError\(\) [\#110](https://github.com/FolioReader/FolioReaderKit/pull/110) ([hebertialmeida](https://github.com/hebertialmeida))

## [0.8.3](https://github.com/FolioReader/FolioReaderKit/tree/0.8.3) (2016-08-11)
[Full Changelog](https://github.com/FolioReader/FolioReaderKit/compare/0.8.2...0.8.3)

**Implemented enhancements:**

- ePubs deep linking to iOS apps should function [\#52](https://github.com/FolioReader/FolioReaderKit/issues/52)

**Fixed bugs:**

- Sometimes the scroll bar gets stuck [\#50](https://github.com/FolioReader/FolioReaderKit/issues/50)

**Merged pull requests:**

- Added URL scheme support \#52 [\#108](https://github.com/FolioReader/FolioReaderKit/pull/108) ([hebertialmeida](https://github.com/hebertialmeida))

## [0.8.2](https://github.com/FolioReader/FolioReaderKit/tree/0.8.2) (2016-08-09)
[Full Changelog](https://github.com/FolioReader/FolioReaderKit/compare/0.8.1...0.8.2)

**Implemented enhancements:**

- Add support for ePub 3.0 books [\#17](https://github.com/FolioReader/FolioReaderKit/issues/17)
- Epub3 parser closes \#17 [\#106](https://github.com/FolioReader/FolioReaderKit/pull/106) ([hebertialmeida](https://github.com/hebertialmeida))

## [0.8.1](https://github.com/FolioReader/FolioReaderKit/tree/0.8.1) (2016-08-03)
[Full Changelog](https://github.com/FolioReader/FolioReaderKit/compare/0.8.0...0.8.1)

**Implemented enhancements:**

- Page Progression Direction - RTL Support [\#104](https://github.com/FolioReader/FolioReaderKit/issues/104)

**Fixed bugs:**

- Arabic Table Content [\#101](https://github.com/FolioReader/FolioReaderKit/issues/101)

**Merged pull requests:**

- Rtl support closes \#104 [\#105](https://github.com/FolioReader/FolioReaderKit/pull/105) ([hebertialmeida](https://github.com/hebertialmeida))

## [0.8.0](https://github.com/FolioReader/FolioReaderKit/tree/0.8.0) (2016-07-28)
[Full Changelog](https://github.com/FolioReader/FolioReaderKit/compare/0.7.0...0.8.0)

**Implemented enhancements:**

- Migrate coredata to Realm [\#94](https://github.com/FolioReader/FolioReaderKit/issues/94)
- Change scroll direction \(horizontal or vertical\) from fonts menu. [\#90](https://github.com/FolioReader/FolioReaderKit/issues/90)
- Unified Navigation Bar to improve UX [\#88](https://github.com/FolioReader/FolioReaderKit/issues/88)
- Fix TTS voice language to match book language [\#87](https://github.com/FolioReader/FolioReaderKit/issues/87)
- Change scroll from menu \#90 [\#102](https://github.com/FolioReader/FolioReaderKit/pull/102) ([hebertialmeida](https://github.com/hebertialmeida))
- Feature/unified navigation bar closes \#88 [\#99](https://github.com/FolioReader/FolioReaderKit/pull/99) ([hebertialmeida](https://github.com/hebertialmeida))
- Closes \#87 TTS voice language [\#93](https://github.com/FolioReader/FolioReaderKit/pull/93) ([hebertialmeida](https://github.com/hebertialmeida))

**Fixed bugs:**

- Fixed crash in UIWebView extension [\#76](https://github.com/FolioReader/FolioReaderKit/pull/76) ([alexpopov](https://github.com/alexpopov))

**Closed issues:**

- How can I install another library in this Kit? [\#81](https://github.com/FolioReader/FolioReaderKit/issues/81)
- Carthage CXAImageSupport timeout [\#79](https://github.com/FolioReader/FolioReaderKit/issues/79)
- Crash on `resetScrollDelta` after dismissing reader [\#72](https://github.com/FolioReader/FolioReaderKit/issues/72)
- Multiline menu titles [\#69](https://github.com/FolioReader/FolioReaderKit/issues/69)
- arabic character [\#59](https://github.com/FolioReader/FolioReaderKit/issues/59)
- Add horizontal scrolling option [\#22](https://github.com/FolioReader/FolioReaderKit/issues/22)

**Merged pull requests:**

- Updated sample icons [\#96](https://github.com/FolioReader/FolioReaderKit/pull/96) ([hebertialmeida](https://github.com/hebertialmeida))
- Issue \[\#94\] migrate to realm [\#95](https://github.com/FolioReader/FolioReaderKit/pull/95) ([tarigancana](https://github.com/tarigancana))
- Expose highlight [\#92](https://github.com/FolioReader/FolioReaderKit/pull/92) ([hebertialmeida](https://github.com/hebertialmeida))
- Closes \#22 Horizontal scroll [\#91](https://github.com/FolioReader/FolioReaderKit/pull/91) ([hebertialmeida](https://github.com/hebertialmeida))
- Fix audio 'scroll to element' for horizontal [\#86](https://github.com/FolioReader/FolioReaderKit/pull/86) ([kjantzer](https://github.com/kjantzer))
- Handle multiple scroll directions [\#85](https://github.com/FolioReader/FolioReaderKit/pull/85) ([hebertialmeida](https://github.com/hebertialmeida))
- WIP Horizontal scrolling [\#84](https://github.com/FolioReader/FolioReaderKit/pull/84) ([hebertialmeida](https://github.com/hebertialmeida))

## [0.7.0](https://github.com/FolioReader/FolioReaderKit/tree/0.7.0) (2016-06-08)
[Full Changelog](https://github.com/FolioReader/FolioReaderKit/compare/0.6.6...0.7.0)

**Closed issues:**

- Table of Contents Uncaught Exception [\#73](https://github.com/FolioReader/FolioReaderKit/issues/73)
- How to run the Example [\#70](https://github.com/FolioReader/FolioReaderKit/issues/70)
- Carthage support [\#56](https://github.com/FolioReader/FolioReaderKit/issues/56)

**Merged pull requests:**

- Carthage Support [\#74](https://github.com/FolioReader/FolioReaderKit/pull/74) ([alexpopov](https://github.com/alexpopov))

## [0.6.6](https://github.com/FolioReader/FolioReaderKit/tree/0.6.6) (2016-05-05)
[Full Changelog](https://github.com/FolioReader/FolioReaderKit/compare/0.6.5...0.6.6)

**Merged pull requests:**

- Updated protocols [\#68](https://github.com/FolioReader/FolioReaderKit/pull/68) ([hebertialmeida](https://github.com/hebertialmeida))
- Fix retain cycles [\#67](https://github.com/FolioReader/FolioReaderKit/pull/67) ([turbokuzmich](https://github.com/turbokuzmich))

## [0.6.5](https://github.com/FolioReader/FolioReaderKit/tree/0.6.5) (2016-05-03)
[Full Changelog](https://github.com/FolioReader/FolioReaderKit/compare/0.6.4...0.6.5)

**Fixed bugs:**

- Nil while unwrapping an Optional value [\#64](https://github.com/FolioReader/FolioReaderKit/issues/64)

**Merged pull requests:**

- Night Mode Bugfix [\#65](https://github.com/FolioReader/FolioReaderKit/pull/65) ([afornes](https://github.com/afornes))

## [0.6.4](https://github.com/FolioReader/FolioReaderKit/tree/0.6.4) (2016-05-02)
[Full Changelog](https://github.com/FolioReader/FolioReaderKit/compare/0.6.3...0.6.4)

## [0.6.3](https://github.com/FolioReader/FolioReaderKit/tree/0.6.3) (2016-04-25)
[Full Changelog](https://github.com/FolioReader/FolioReaderKit/compare/0.6.2...0.6.3)

**Implemented enhancements:**

- Adding tests [\#46](https://github.com/FolioReader/FolioReaderKit/issues/46)

**Fixed bugs:**

- Crash in readTOCReference [\#63](https://github.com/FolioReader/FolioReaderKit/issues/63)

**Closed issues:**

- Font size doesn't change for some ePubs [\#62](https://github.com/FolioReader/FolioReaderKit/issues/62)
- Text to Speech support [\#53](https://github.com/FolioReader/FolioReaderKit/issues/53)

## [0.6.2](https://github.com/FolioReader/FolioReaderKit/tree/0.6.2) (2016-04-08)
[Full Changelog](https://github.com/FolioReader/FolioReaderKit/compare/0.6.1...0.6.2)

**Implemented enhancements:**

- Add option to delete or keep original book.epub [\#20](https://github.com/FolioReader/FolioReaderKit/issues/20)

**Fixed bugs:**

- Sample app does not work [\#61](https://github.com/FolioReader/FolioReaderKit/issues/61)
- Add option to delete or keep original book.epub [\#20](https://github.com/FolioReader/FolioReaderKit/issues/20)

## [0.6.1](https://github.com/FolioReader/FolioReaderKit/tree/0.6.1) (2016-04-08)
[Full Changelog](https://github.com/FolioReader/FolioReaderKit/compare/0.6.0...0.6.1)

**Merged pull requests:**

- Text-to-Speech-support-\#53 [\#60](https://github.com/FolioReader/FolioReaderKit/pull/60) ([hunght](https://github.com/hunght))

## [0.6.0](https://github.com/FolioReader/FolioReaderKit/tree/0.6.0) (2016-04-01)
[Full Changelog](https://github.com/FolioReader/FolioReaderKit/compare/0.5.0...0.6.0)

**Closed issues:**

- tvOS support? [\#55](https://github.com/FolioReader/FolioReaderKit/issues/55)

**Merged pull requests:**

- Added a method to get a Cover Image Preview [\#58](https://github.com/FolioReader/FolioReaderKit/pull/58) ([neowinston](https://github.com/neowinston))

## [0.5.0](https://github.com/FolioReader/FolioReaderKit/tree/0.5.0) (2016-01-27)
[Full Changelog](https://github.com/FolioReader/FolioReaderKit/compare/0.4.1...0.5.0)

**Implemented enhancements:**

- Let user choose the audio synced highlight style [\#34](https://github.com/FolioReader/FolioReaderKit/issues/34)

**Merged pull requests:**

- Feature/34 media overlay style choices [\#49](https://github.com/FolioReader/FolioReaderKit/pull/49) ([kjantzer](https://github.com/kjantzer))
- Sharing provider tests [\#48](https://github.com/FolioReader/FolioReaderKit/pull/48) ([bkobilansky](https://github.com/bkobilansky))
- Add target and pods for testing, initial simple test [\#47](https://github.com/FolioReader/FolioReaderKit/pull/47) ([bkobilansky](https://github.com/bkobilansky))

## [0.4.1](https://github.com/FolioReader/FolioReaderKit/tree/0.4.1) (2016-01-25)
[Full Changelog](https://github.com/FolioReader/FolioReaderKit/compare/0.4.0...0.4.1)

## [0.4.0](https://github.com/FolioReader/FolioReaderKit/tree/0.4.0) (2016-01-25)
[Full Changelog](https://github.com/FolioReader/FolioReaderKit/compare/0.3.9...0.4.0)

**Implemented enhancements:**

- Show loading state while loading book [\#45](https://github.com/FolioReader/FolioReaderKit/issues/45)

**Fixed bugs:**

- The bug of  delete and copy a epubfile [\#44](https://github.com/FolioReader/FolioReaderKit/issues/44)

## [0.3.9](https://github.com/FolioReader/FolioReaderKit/tree/0.3.9) (2016-01-20)
[Full Changelog](https://github.com/FolioReader/FolioReaderKit/compare/0.3.8...0.3.9)

**Implemented enhancements:**

- Disable screen dimming when playing audio [\#29](https://github.com/FolioReader/FolioReaderKit/issues/29)
- Add "now playing" info to lock screen for audio synced epubs [\#27](https://github.com/FolioReader/FolioReaderKit/issues/27)

**Merged pull requests:**

- Use dark color theme in FolioReaderHighlightList when in night mode [\#42](https://github.com/FolioReader/FolioReaderKit/pull/42) ([hkalexling](https://github.com/hkalexling))
- Highlighter uses last used style [\#38](https://github.com/FolioReader/FolioReaderKit/pull/38) ([kjantzer](https://github.com/kjantzer))
- Fixing now playing info elapsed time and current chapter [\#36](https://github.com/FolioReader/FolioReaderKit/pull/36) ([kjantzer](https://github.com/kjantzer))

## [0.3.8](https://github.com/FolioReader/FolioReaderKit/tree/0.3.8) (2016-01-14)
[Full Changelog](https://github.com/FolioReader/FolioReaderKit/compare/0.3.7...0.3.8)

**Implemented enhancements:**

- Add support for ePub 3.0 "Media Overlays" [\#11](https://github.com/FolioReader/FolioReaderKit/issues/11)
- In-App Dictionary [\#9](https://github.com/FolioReader/FolioReaderKit/issues/9)
- ePub 3.0 media overlays can be played and example updated to demonstrate [\#23](https://github.com/FolioReader/FolioReaderKit/pull/23) ([kjantzer](https://github.com/kjantzer))

**Closed issues:**

- `updateCurrentPage` has some issues [\#30](https://github.com/FolioReader/FolioReaderKit/issues/30)
- Add vertical scrubber to quickly jump pages in current chapter [\#21](https://github.com/FolioReader/FolioReaderKit/issues/21)

**Merged pull requests:**

- Adding a tintColor variable to config [\#33](https://github.com/FolioReader/FolioReaderKit/pull/33) ([kjantzer](https://github.com/kjantzer))
- Added in-app dictionary \#9 [\#31](https://github.com/FolioReader/FolioReaderKit/pull/31) ([kjantzer](https://github.com/kjantzer))
- Fixing audio sync highlight in night mode \#11 [\#28](https://github.com/FolioReader/FolioReaderKit/pull/28) ([kjantzer](https://github.com/kjantzer))
- Feature: Chapter scroll scrubber [\#24](https://github.com/FolioReader/FolioReaderKit/pull/24) ([kjantzer](https://github.com/kjantzer))

## [0.3.7](https://github.com/FolioReader/FolioReaderKit/tree/0.3.7) (2016-01-07)
[Full Changelog](https://github.com/FolioReader/FolioReaderKit/compare/0.3.6...0.3.7)

**Merged pull requests:**

- Adding app icon for FolioReader demo :tada: [\#18](https://github.com/FolioReader/FolioReaderKit/pull/18) ([kjantzer](https://github.com/kjantzer))

## [0.3.6](https://github.com/FolioReader/FolioReaderKit/tree/0.3.6) (2016-01-05)
[Full Changelog](https://github.com/FolioReader/FolioReaderKit/compare/0.3.5...0.3.6)

## [0.3.5](https://github.com/FolioReader/FolioReaderKit/tree/0.3.5) (2016-01-04)
[Full Changelog](https://github.com/FolioReader/FolioReaderKit/compare/0.3.4...0.3.5)

**Fixed bugs:**

- fatal error: unexpectedly found nil while unwrapping an Optional value [\#15](https://github.com/FolioReader/FolioReaderKit/issues/15)

## [0.3.4](https://github.com/FolioReader/FolioReaderKit/tree/0.3.4) (2016-01-04)
[Full Changelog](https://github.com/FolioReader/FolioReaderKit/compare/0.3.3...0.3.4)

**Fixed bugs:**

- Bug: deleting visible highlight from tableview crashes if trying to delete again from text view [\#14](https://github.com/FolioReader/FolioReaderKit/issues/14)
- Bug: shouldHideNavigationOnTap=true doesn't appear to work [\#12](https://github.com/FolioReader/FolioReaderKit/issues/12)

**Merged pull requests:**

- Fixing \#12 - `shouldHideNavigationOnTap=true` was not working [\#13](https://github.com/FolioReader/FolioReaderKit/pull/13) ([kjantzer](https://github.com/kjantzer))

## [0.3.3](https://github.com/FolioReader/FolioReaderKit/tree/0.3.3) (2015-12-08)
[Full Changelog](https://github.com/FolioReader/FolioReaderKit/compare/0.3.2...0.3.3)

**Fixed bugs:**

- Reader crashes if rotate while parsing large books [\#7](https://github.com/FolioReader/FolioReaderKit/issues/7)

## [0.3.2](https://github.com/FolioReader/FolioReaderKit/tree/0.3.2) (2015-12-04)
[Full Changelog](https://github.com/FolioReader/FolioReaderKit/compare/0.3.1...0.3.2)

## [0.3.1](https://github.com/FolioReader/FolioReaderKit/tree/0.3.1) (2015-12-03)
[Full Changelog](https://github.com/FolioReader/FolioReaderKit/compare/0.3.0...0.3.1)

**Closed issues:**

- Great for stimulator. Problem with iPhone 6 Plus [\#6](https://github.com/FolioReader/FolioReaderKit/issues/6)

## [0.3.0](https://github.com/FolioReader/FolioReaderKit/tree/0.3.0) (2015-12-03)
[Full Changelog](https://github.com/FolioReader/FolioReaderKit/compare/0.2.0...0.3.0)

## [0.2.0](https://github.com/FolioReader/FolioReaderKit/tree/0.2.0) (2015-12-02)
[Full Changelog](https://github.com/FolioReader/FolioReaderKit/compare/0.1.0...0.2.0)

## [0.1.0](https://github.com/FolioReader/FolioReaderKit/tree/0.1.0) (2015-12-02)
**Implemented enhancements:**

- Please update to Swift 2.0 [\#4](https://github.com/FolioReader/FolioReaderKit/issues/4)

**Merged pull requests:**

- Cocoapods implementation [\#5](https://github.com/FolioReader/FolioReaderKit/pull/5) ([hebertialmeida](https://github.com/hebertialmeida))
- fixed nil currentPage when swipe left for menu at cover page [\#3](https://github.com/FolioReader/FolioReaderKit/pull/3) ([katopz](https://github.com/katopz))
- fixed nil currentPage when swipe left for menu at cover page [\#2](https://github.com/FolioReader/FolioReaderKit/pull/2) ([katopz](https://github.com/katopz))



\* *This Change Log was automatically generated by [github_changelog_generator](https://github.com/skywinder/Github-Changelog-Generator)*