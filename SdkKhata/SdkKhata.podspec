Pod::Spec.new do |s|

 s.name         = "SdkKhata"
 s.version      = "0.0.2"
 s.summary      = "A short description of DemoFramework."
 s.description  = "A short description of DemoFramework"

 s.homepage     = "https://github.com/hpatni/fg-lending"
 s.license      = "MIT"

 s.author       = { "Pullaiah C" => "puli@artdexandcognoscis.com" }


 s.platform     = :ios, "9.0"


 s.source        = { :git => 'https://github.com/hpatni/fg-lending.git',:tag => "0.0.2", :branch => "ios_development" }
 s.swift_version = "4.0"
 s.source_files = 'SdkKhata/**/*.{h,m,swift,plist}'
 s.ios.vendored_frameworks = 'PayU_iOS_CoreSDKE.framework'
 s.resources = ['SdkKhata/**/*.{xcassets,storyboard,png,jpg,ttf}']
 s.static_framework = true
 
 
 s.dependency 'Alamofire', '~> 4.7'
 s.dependency 'SwiftyJSON', '~> 4.2'
 s.dependency 'SkyFloatingLabelTextField', '~> 3.0'
 s.dependency 'IGRPhotoTweaks', '~> 1.0.0'
 s.dependency 'Firebase/Core'
 s.dependency 'Firebase/MLVision'
 s.dependency 'SWXMLHash', '~> 4.7.0'
 s.dependency 'DropDown', '2.3.2'
 s.dependency 'CropViewController'
 s.dependency 'SwiftKeychainWrapper'
 
 
end
