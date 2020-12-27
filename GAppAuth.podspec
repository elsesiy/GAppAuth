Pod::Spec.new do |s|
  s.name = 'GAppAuth'
  s.version = '1.6.0'
  s.summary = 'Convenient Wrapper for AppAuth with Google Services written in Swift >= 4 (iOS).'
  s.homepage = 'https://github.com/elsesiy/GAppAuth'
  s.license = 'BSD-2-Clause'
  s.author = 'Jonas-Taha El Sesiy'
  s.social_media_url = 'https://twitter.com/elsesiy'
  s.platforms = { ios: '9.0', osx: '10.11' }
  s.source = { git: 'https://github.com/elsesiy/GAppAuth.git', tag: s.version }
  s.swift_version = '5.0'

  # MacOS
  s.osx.deployment_target = '10.11'
  s.osx.source_files = 'Sources/macOS/GAppAuth.swift'

  # iOS
  s.ios.deployment_target = '9.0'
  s.ios.source_files = 'Sources/iOS/GAppAuth.swift'

  s.dependency 'GTMAppAuth', '1.1.0'
  s.dependency 'AppAuth', '1.4.0'
end
