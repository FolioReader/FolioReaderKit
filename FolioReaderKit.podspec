Pod::Spec.new do |s|
  s.name             = "FolioReaderKit"
  s.version          = "0.1.0"
  s.summary          = "A Swift ePub reader and parser framework for iOS."
  s.description  = <<-DESC
                   Written in Swift.
                   The Best Open Source ePub Reader.
                   DESC
  s.homepage         = "https://github.com/FolioReader/FolioReaderKit"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'GNU'
  s.author           = { "Heberti Almeida" => "hebertialmeida@gmail.com" }
  s.source           = { :git => "https://github.com/FolioReader/FolioReaderKit.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/hebertialmeida'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = [
    'Source/*.{h,swift}',
    'Source/**/*.swift',
    'Vendor/**/*.{swift,h,m}', # Temporary
  ]
  s.resources = [
    'Source/**/*.{js,css,xcdatamodeld}',
    'Source/Resources/Images/*.png', 
    'Source/Resources/Fonts/**/*.{otf,ttf}'
  ]
  s.preserve_paths = 'Source/**/*.xcdatamodeld'
  s.public_header_files = 'Source/*.h'

  s.libraries  = "z"
  s.frameworks = 'CoreData'
  s.dependency 'SSZipArchive'
  s.dependency 'UIMenuItem-CXAImageSupport'
  s.dependency 'ZFDragableModalTransition'
  s.dependency 'AEXML'
  s.dependency 'FontBlaster'
  s.dependency 'JSQWebViewController'
  s.dependency 'TGPControls'
  # s.dependency 'SMSegmentView'
end
