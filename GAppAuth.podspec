Pod::Spec.new do |s|
  s.name         = 'GAppAuth'
  s.version      = '1.2.0'
  s.summary      = 'Convenient Wrapper for AppAuth with Google Services written in Swift 4 (iOS).'
  s.homepage     = 'https://github.com/elsesiy/GAppAuth'
  s.license      = 'BSD-2-Clause'
  s.author             = 'Jonas-Taha El Sesiy'
  s.social_media_url   = 'http://twitter.com/elsesiy'
  s.source       = { :git => 'https://github.com/elsesiy/GAppAuth.git', :tag => s.version }
  s.source_files  = 'Sources/GAppAuth.swift'
  s.swift_version = '4.0'
  #s.tvos.deployment_target = '9.0'
  #s.osx.deployment_target = '10.9'
  s.ios.deployment_target = '8.0'
  s.dependency 'GTMAppAuth', '~> 0.7.0'
end
