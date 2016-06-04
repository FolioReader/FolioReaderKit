Pod::Spec.new do |s|
   s.name = 'JSQWebViewController'
   s.version = '3.0.0'
   s.license = 'MIT'

   s.summary = 'A lightweight Swift WebKit view controller for iOS'
   s.homepage = 'https://github.com/jessesquires/JSQWebViewController'
   s.documentation_url = 'http://jessesquires.com/JSQWebViewController'

   s.social_media_url = 'https://twitter.com/jesse_squires'
   s.authors = 'Jesse Squires'

   s.source = { :git => 'https://github.com/jessesquires/JSQWebViewController.git', :tag => s.version }
   s.source_files = 'Source/*.swift'

   s.platform = :ios, '8.0'

   s.frameworks = 'WebKit'
   s.requires_arc = true
end
