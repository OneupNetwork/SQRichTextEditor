#
# Be sure to run `pod lib lint SQRichTextEditor.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SQRichTextEditor'
  s.version          = '0.3.0'
  s.summary          = 'A rich text WYSIWYG editor for iOS base on Squire.'
  s.description      = "A rich text WYSIWYG editor for iOS, which is based on Squire using HTML5 and javascript."
  s.homepage         = 'https://github.com/OneupNetwork/SQRichTextEditor'
  
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Yuwei Lin' => 'jesse@gamer.com.tw' }
  s.source           = { :git => 'https://github.com/OneupNetwork/SQRichTextEditor.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'

  s.ios.source_files = 'SQRichTextEditor/Classes/*'
  
  s.ios.resources = "SQRichTextEditor/Assets/Editor/*"
  
  #s.ios.resource_bundles = { 'imageResource' => ['SQRichTextEditor/Assets/*.xcassets'] }

  s.ios.frameworks = 'UIKit', 'WebKit'
  
  s.swift_version = '5.1'
end
