Pod::Spec.new do |s|
  s.name = 'SMF-Alamofire'
  s.module_name = 'Alamofire'
  s.version = '4.7.3'
  s.license = 'MIT'
  s.summary = 'Static build of Alamofire'
  s.homepage = 'https://github.com/smartmobilefactory/SMF-Alamofire'
  s.social_media_url = 'http://twitter.com/AlamofireSF'
  s.authors = { 'Alamofire Software Foundation' => 'info@alamofire.org' }
  s.source = { :git => 'https://github.com/smartmobilefactory/SMF-Alamofire.git', :tag => "releases/#{s.version}" }

  s.ios.deployment_target = '8.0'
  s.ios.vendored_frameworks = 'StaticFrameworks/iOS/Alamofire.framework'

  s.osx.deployment_target = '10.10'
  s.osx.vendored_frameworks = 'StaticFrameworks/macOS/Alamofire.framework'

  s.tvos.deployment_target = '9.0'
  s.tvos.vendored_frameworks = 'StaticFrameworks/tvOS/Alamofire.framework'

  s.watchos.deployment_target = '2.0'
  s.watchos.vendored_frameworks = 'StaticFrameworks/watchOS/Alamofire.framework'

end
