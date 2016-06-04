Pod::Spec.new do |s|
s.name = 'AEXML'
s.version = '3.0.0'
s.license = { :type => 'MIT', :file => 'LICENSE' }
s.summary = 'Simple and lightweight XML parser written in Swift'

s.homepage = 'https://github.com/tadija/AEXML'
s.author = { 'tadija' => 'tadija@me.com' }
s.social_media_url = 'http://twitter.com/tadija'

s.source = { :git => 'https://github.com/tadija/AEXML.git', :tag => s.version }
s.source_files = 'Sources/*.swift'

s.ios.deployment_target = '8.0'
s.osx.deployment_target = '10.10'
s.tvos.deployment_target = '9.0'
s.watchos.deployment_target = '2.0'
end