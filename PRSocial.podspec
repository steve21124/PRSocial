Pod::Spec.new do |s|
  s.name                  = "PRSocial"
  s.version               = "0.1.14"
  s.summary               = "Share contents on social network."
  s.homepage              = "https://github.com/Elethom/PRSocial"
  s.license               = { :type => "MIT", :file => "LICENSE" }
  s.author                = { "Elethom Hunter" => "elethomhunter@gmail.com" }
  s.social_media_url      = "https://twitter.com/ElethomHunter"
  s.platform              = :ios
  s.ios.deployment_target = "6.0"
  s.source                = { :git => "https://github.com/Elethom/PRSocial.git", :tag => "0.1.14" }
  s.source_files          = "Classes", "Classes/**/*", "Frameworks/*.h", "Frameworks/**/*.h"
  s.frameworks            = "Foundation", "UIKit", "CoreGraphics", "Social", "CoreTelephony"
  s.libraries             = "z", "sqlite3", "stdc++"
  s.vendored_libraries    = "Frameworks", "Frameworks/**/*.a"
  s.requires_arc          = true
  s.dependency            'MBProgressHUD', '~> 0.8'
  s.dependency            'SSKeychain', '~> 1.2.2'
  s.dependency            'TencentOpenApiSDK', '~> 2.3.0'
  s.dependency            'Weibo', '~> 2.4.2'
  s.xcconfig              = { "FRAMEWORK_SEARCH_PATHS" => '"$(PODS_ROOT)/TencentOpenApiSDK"' }
end
