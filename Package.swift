import PackageDescription

let package = Package(
	name: "FolioReaderKit",
	dependencies: [
		.Package(url: "https://github.com/ZipArchive/ZipArchive.git", majorVersion: 1, minor: 4),
		.Package(url: "https://github.com/cxa/UIMenuItem-CXAImageSupport.git", majorVersion: 0, minor: 0),
		.Package(url: "https://github.com/zoonooz/ZFDragableModalTransition.git", majorVersion: 0, minor: 6),
		.Package(url: "https://github.com/tadija/AEXML.git", majorVersion: 3, minor: 0),
		.Package(url: "https://github.com/ArtSabintsev/FontBlaster.git", majorVersion: 2, minor: 1),
		.Package(url: "https://github.com/jessesquires/JSQWebViewController.git", majorVersion: 3, minor: 0),
		.Package(url: "https://github.com/realm/realm-cocoa.git", majorVersion: 1, minor: 0),
	]
)
