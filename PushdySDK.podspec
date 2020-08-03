#
# Be sure to run `pod lib lint pushdy.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'PushdySDK'
  s.version          = '0.0.10'
  s.summary          = 'Pushdy SDK for iOS platform'
  
  # This description is used to generate tags and improve search results.
  #   * Think: What does it do? Why did you write it? What is the focus?
  #   * Try to keep it short, snappy and to the point.
  #   * Write the description between the DESC delimiters below.
  #   * Finally, don't worry about the indent, CocoaPods strips it!
  
  s.description      = <<-DESC
  TODO: Add long description of the pod here.
  DESC
  
  s.homepage         = 'https://github.com/Pushdy/ios-pushdy-sdk'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'quandt' => 'quandt@mobiletech.vn' }
  s.source           = { :git => 'https://github.com/Pushdy/ios-pushdy-sdk.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
  
  s.ios.deployment_target = '8.0'
  
  s.source_files = 'Pushdy/Classes/**/*.{h,m,swift}'
  
  # s.resource_bundles = {
  #   'pushdy' => ['pushdy/Assets/*.png']
  # }
  
  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  s.swift_versions = ['4.0', '4.2', '5.0']
  # s.vendored_frameworks = 'Pushdy/Frameworks/PushdyCore.framework'
  s.resources = "Pushdy/Classes/**/*.{png,xib,jpg}"
  s.xcconfig = { 'OTHER_LDFLAGS' => '-ObjC' }
end
