#
# Be sure to run `pod lib lint ZHTCommonMethods.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ZHTCommonMethods'
  s.version          = '1.0.0'
  s.summary          = '通用方法私有组件'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = "组件用于iOS通用方法集合封装，使用方法为类方法直接调用，主要包含数据格式转换、数据保存、时间获取与比较等"

  s.homepage         = 'https://github.com/zouhetai/ZHTCommonMethods'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '1452327617@qq.com' => 'zouhetai@csii.com.cn' }
  s.source           = { :git => 'https://github.com/zouhetai/ZHTCommonMethods.git', :tag => "#{s.version}" }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.source_files = 'ZHTCommonMethods/Classes/*.{h,m,md}'
  
  # s.resource_bundles = {
  #   'ZHTCommonMethods' => ['ZHTCommonMethods/Assets/*.png']
  # }

  s.public_header_files = 'Pod/Classes/TienUtils.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
