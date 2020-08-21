#
#  Be sure to run `pod spec lint RemoteParameters.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  spec.name         = "RemoteParameters"
  spec.version		= "0.1.6"
  spec.summary      = "Swift Framework for parameterization of app values."

  spec.homepage     = "https://github.com/avi-c/RemoteParameters"

  spec.license = { :type => "MIT", :file => "LICENSE" }
  spec.author             = { "Avi Cieplinski" => "avi@avic.co" }
  spec.social_media_url   = "https://twitter.com/sf_avi"

  spec.platform     = :ios, "9.0"
  spec.source = { :git => "https://github.com/avi-c/RemoteParameters.git", :tag => "#{spec.version}" }
  spec.source_files  = "RemoteParameters/*.{swift,h}", 
                       "RemoteParameters/**/*.{swift}", 
                       "Parameters/*.{swift,h}",

  spec.framework  = "MultipeerConnectivity"
  spec.dependency 'RxSwift', '~> 4.0'
  spec.dependency 'RxCocoa', '~> 4.0'
  spec.dependency 'RxOptional', '~> 3.6'

  spec.requires_arc = true  
  spec.swift_version = "4.2"

end
