// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "FolioReaderKit",
    
    products: [
        .library(name: "FolioReaderKit", targets: ["FolioReaderKit"]),
    ],
    
    dependencies: [
        .package(url: "https://github.com/ZipArchive/ZipArchive.git", .exact("2.1.1")),
        .package(url: "https://github.com/cxa/MenuItemKit.git", .exact("3.1.3")),
        .package(url: "https://github.com/zoonooz/ZFDragableModalTransition.git", .exact("0.6.0")),
        .package(url: "https://github.com/tadija/AEXML.git", .exact("4.4.0")),
        .package(url: "https://github.com/ArtSabintsev/FontBlaster.git", .exact("4.1.0")),
        .package(url: "https://github.com/realm/realm-cocoa.git", .exact("3.17.3"))
    ],
    
    targets: [
        .target(name: "FolioReaderKit", dependencies: []),
        .testTarget(name: "FolioReaderKitTests", dependencies: ["FolioReaderKit"]),
    ]
)
