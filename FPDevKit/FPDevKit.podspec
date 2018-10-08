Pod::Spec.new do |s|

 s.name         = "FPDevKit"
 s.version      = "1.0.1"
 s.summary      = "A short description of DemoFramework."
 s.description  = "A short description of DemoFramework"

 s.homepage     = "https://github.com/Puli4262/FPDemoKit.git"
 s.license      = "MIT"

 s.author       = { "Pullaiah C" => "puli@artdexandcognoscis.com" }


 s.platform     = :ios, "9.0"


 s.source        = { :git => 'https://github.com/Puli4262/FPDemoKit.git',:tag => "1.0.1" }
 s.swift_version = "4.0"
 s.source_files = 'FPDevKit/**/*.{h,m,swift}'
 
 s.resources = ['FPDevKit/**/*.{xcassets,storyboard,png,jpg}']
 
 s.dependency 'Alamofire', '~> 4.7'
 s.dependency 'SwiftyJSON', '~> 4.2'
 s.dependency 'SkyFloatingLabelTextField', '~> 3.0'
end
