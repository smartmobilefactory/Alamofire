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

  s.static_framework = true

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.10'
  s.tvos.deployment_target = '9.0'
  s.watchos.deployment_target = '2.0'

  s.source_files = 'Frameworks/Frameworks.swift'

  s.subspec "Static" do |subspec|
    subspec.ios.vendored_frameworks = 'Frameworks/Static/iOS/Alamofire.framework'
    subspec.osx.vendored_frameworks = 'Frameworks/Static/Mac/Alamofire.framework'
    subspec.tvos.vendored_frameworks = 'Frameworks/Static/tvOS/Alamofire.framework'
    subspec.watchos.vendored_frameworks = 'Frameworks/Static/watchOS/Alamofire.framework'
  end

  s.subspec "Dynamic" do |subspec|
    subspec.ios.vendored_frameworks = 'Frameworks/Dynamic/iOS/Alamofire.framework'
    subspec.osx.vendored_frameworks = 'Frameworks/Dynamic/Mac/Alamofire.framework'
    subspec.tvos.vendored_frameworks = 'Frameworks/Dynamic/tvOS/Alamofire.framework'
    subspec.watchos.vendored_frameworks = 'Frameworks/Dynamic/watchOS/Alamofire.framework'
  end

end
