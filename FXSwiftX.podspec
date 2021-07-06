#
# Be sure to run `pod lib lint FXKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'FXSwiftX'
  s.version          = '0.2.0'
  s.summary          = 'tool'
  s.homepage         = 'https://github.com/feixue299/FXSwiftX'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'feixue299' => '1569485690@qq.com' }
  s.source           = { :git => 'https://github.com/feixue299/FXSwiftX.git', :tag => s.version.to_s }
  s.ios.deployment_target = '10.0'
  s.swift_version = '5.0'
  s.source_files = 'FXSwiftX/Classes/**/*{.swift}'
end
