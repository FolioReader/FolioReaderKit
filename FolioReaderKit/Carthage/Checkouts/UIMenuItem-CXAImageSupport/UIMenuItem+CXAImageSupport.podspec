Pod::Spec.new do |s|
  s.name         = "UIMenuItem+CXAImageSupport"
  s.version      = "1.1.0"
  s.summary      = "UIMenuItem with Image Support"
  s.description  = <<-DESC
					UIMenuItem uses UILabel to display its title, that means we can swizzle -drawTextInRect: to support image.
					UIMenuItem+CXAImageSupport is a dirty hack but should be safe in most cases. Contains no any private APIs and should be safe for App Store.
                   DESC
  s.author       = "CHEN Xian’an <xianan.chen@gmail.com>"
  s.homepage     = "https://github.com/cxa/UIMenuItem-CXAImageSupport"
  s.license      = 'MIT'
  s.source       = { :git => 'https://github.com/cxa/UIMenuItem-CXAImageSupport.git', :tag => s.version.to_s }
  s.platform     = :ios, '6.1'
  s.source_files = 'UIMenuItem+CXAImageSupport.{h,m}'
  s.requires_arc = true
  s.frameworks   = 'UIKit'
end
