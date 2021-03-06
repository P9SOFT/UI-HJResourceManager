Pod::Spec.new do |s|

  s.name         = "UI+HJResourceManager"
  s.version      = "1.3.3"
  s.summary      = "Asynchronous image downloader with cache support as a UIImageView/UIButton category, based on Hydra framework."
  s.homepage     = "https://github.com/P9SOFT/UI-HJResourceManager"
  s.license      = { :type => 'MIT' }
  s.author       = { "Tae Hyun Na" => "taehyun.na@gmail.com" }

  s.ios.deployment_target = '8.0'
  s.requires_arc = true

  s.source       = { :git => "https://github.com/P9SOFT/UI-HJResourceManager.git", :tag => "1.3.3" }
  s.source_files  = "Sources/*.{h,m}"
  s.public_header_files = "Sources/*.h"

  s.dependency 'HJResourceManager', '~> 2.0.3'

end
