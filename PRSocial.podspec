Pod::Spec.new do |s|
  s.name                  = "PRSocial"
  s.version               = "0.1.14"
  s.summary               = "Share contents on social network."
  s.homepage              = "https://github.com/Elethom/PRSocial"
  s.license               = "MIT"
  s.author                = { "Elethom Hunter" => "elethomhunter@gmail.com" }
  s.social_media_url      = "https://twitter.com/ElethomHunter"
  s.source                = { :git => "https://github.com/steve21124/PRSocial.git" }
  s.source_files          = "Classes", "Classes/**/*", "Frameworks/*.h", "Frameworks/**/*.h"
  s.frameworks            = "Foundation", "UIKit", "CoreGraphics", "Social", "CoreTelephony"
  s.libraries             = "z", "sqlite3", "stdc++"
  s.vendored_libraries    = "Frameworks", "Frameworks/**/*.a"
  s.requires_arc          = true
  s.dependency            'MBProgressHUD', '~> 0.9'
  s.dependency            'SSKeychain', '~> 1.2.2'
  s.dependency            'Weibo', '~> 2.4.2'
end