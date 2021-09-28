#
# Be sure to run `pod lib lint CJSkin.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'CJSkin'
  s.version          = '1.0.2'
  s.summary          = 'CJSkin动态换肤框架，支持图片、颜色、字体等元素的动态切换以及皮肤包在线更新'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  CJSkin动态换肤框架，支持图片、颜色、字体等元素的动态切换以及皮肤包在线更新.
                       DESC

  s.homepage         = 'https://github.com/lele8446/CJSkin'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'lele8446' => 'lele8446@foxmail.com' }
  s.source           = { :git => 'https://github.com/lele8446/CJSkin.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.source_files = 'CJSkin/Classes/**/*'
  s.public_header_files = 'CJSkin/Classes/**/*.h'
  # s.resource_bundles = {
  #   'CJSkin' => ['CJSkin/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'SSZipArchive'
  s.dependency 'CJFileDownloader'
end
