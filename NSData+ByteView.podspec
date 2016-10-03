#
#  Be sure to run `pod spec lint NSData+ByteView.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
  s.name         = "NSData+ByteView"
  s.version      = "0.4.0"
  s.summary      = "NSData extension that lets you easily work with Byte, Word, DoubleWord, Long and HexString"
  s.description  = <<-DESC
  NSData+ByteView is a extension on NSData that lets you easily work with Byte, Word, Double and Longs stored in a NSData object.
  It also let you convert a NSData object to and from a hexadecimal string representation.
                   DESC
  s.homepage     = "https://github.com/michaelradtke/NSData-ByteView"
  s.license      = { :type => "MIT"}
  s.author             = { "Michael Radtke" => "mradtke@abigale.de" }
  s.osx.deployment_target = "10.10"
  s.source       = { :git => "https://github.com/michaelradtke/NSData-ByteView.git", :tag => s.version.to_s }

  s.source_files  = "NSData+ByteView/*.swift"

end
