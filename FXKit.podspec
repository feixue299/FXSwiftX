#
# Be sure to run `pod lib lint FXKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'FXKit'
  s.version          = '0.1.0'
  s.summary          = 'tool'
  s.homepage         = 'https://github.com/feixue299/FXKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'feixue299' => '1569485690@qq.com' }
  s.source           = { :git => 'https://github.com/feixue299/FXKit.git', :tag => s.version.to_s }
  s.ios.deployment_target = '11.0'
  s.source_files = 'FXKit/Classes/**/*'
end
