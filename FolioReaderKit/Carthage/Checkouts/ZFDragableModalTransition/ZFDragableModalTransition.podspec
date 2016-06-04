#
# Be sure to run `pod lib lint NAME.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = "ZFDragableModalTransition"
  s.version          = "0.6"
  s.summary          = "Custom animation transition for present modal view controller"
  s.homepage         = "https://github.com/zoonooz/ZFDragableModalTransition"
  s.license          = 'MIT'
  s.author           = { "Amornchai Kanokpullwad" => "amornchai.zoon@gmail.com" }
  s.source           = { :git => "https://github.com/zoonooz/ZFDragableModalTransition.git", :tag => s.version.to_s }
  s.platform         = :ios, '7.1'
  s.requires_arc     = true
  s.source_files     = 'ZFDragableModalTransition'
  s.ios.deployment_target = '7.1'
end
