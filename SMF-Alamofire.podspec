Pod::Spec.new do |s|
  s.name = 'SMF-Alamofire'
  s.module_name = 'Alamofire'
  s.version = '4.7.3'
  s.license = 'MIT'
  s.summary = 'Static build of Alamofire'
  s.homepage = 'https://github.com/smartmobilefactory/SMF-Alamofire'
  s.authors = { 'Alamofire Software Foundation' => 'info@alamofire.org' }
  s.source = { :git => 'https://github.com/smartmobilefactory/SMF-Alamofire.git', :tag => "releases/#{s.version}" }

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.10'
  s.tvos.deployment_target = '9.0'
  s.watchos.deployment_target = '2.0'

  s.ios.vendored_frameworks = 'Releases/iOS/Alamofire.framework'
  s.osx.vendored_frameworks = 'Releases/Mac/Alamofire.framework'
  s.tvos.vendored_frameworks = 'Releases/tvOS/Alamofire.framework'
  s.watchos.vendored_frameworks = 'Releases/watchOS/Alamofire.framework'

  s.static_framework = true

end
