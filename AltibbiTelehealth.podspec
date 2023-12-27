#
# Be sure to run `pod lib lint AltibbiTelehealth.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AltibbiTelehealth'
  s.version          = '0.1.0'
  s.summary          = 'React native SDK provides integration for the Altibbi services, including video consultation, text consultation, push Welcome to the React Native SDK for Altibbi services, your comprehensive solution for integrating health consultation services into your React Native applications. This SDK enables video and text consultations, push notifications, and many other features to provide a seamless healthcare experience.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
React native SDK provides integration for the Altibbi services, including video consultation, text consultation, push Welcome to the React Native SDK for Altibbi services, your comprehensive solution for integrating health consultation services into your React Native applications. This SDK enables video and text consultations, push notifications, and many other features to provide a seamless healthcare experience.
                       DESC

  s.homepage         = 'https://github.com/altibbi-com/altibbi-ios-sdk'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Altibbi Tech team' => 'mobile@altibbi.com' }
  s.source           = { :git => 'https://github.com/altibbi-com/altibbi-ios-sdk.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '13.0'

  s.source_files = 'AltibbiTelehealth/Classes/**/*'

  # s.resource_bundles = {
  #   'AltibbiTelehealth' => ['AltibbiTelehealth/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'AFNetworking', '~> 4.0'
  s.dependency 'PusherSwift', '~> 10.1.1'
  s.dependency 'SendbirdChatSDK'
  s.dependency 'OTXCFramework','2.26.1'
  s.static_framework = true

end
