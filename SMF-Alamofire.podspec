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

  s.subspec "Static" do |subspec|
    s.source_files = 'StaticFrameworks/StaticFrameworks.swift'

    subspec.ios.deployment_target = '8.0'
    subspec.ios.vendored_frameworks = 'StaticFrameworks/Static/iOS/Alamofire.framework'
    subspec.osx.deployment_target = '10.10'
    subspec.osx.vendored_frameworks = 'StaticFrameworks/Static/Mac/Alamofire.framework'
    subspec.tvos.deployment_target = '9.0'
    subspec.tvos.vendored_frameworks = 'StaticFrameworks/Static/tvOS/Alamofire.framework'
    subspec.watchos.deployment_target = '2.0'
    subspec.watchos.vendored_frameworks = 'StaticFrameworks/Static/watchOS/Alamofire.framework'
  end

  s.subspec "Dynamic" do |subspec|
    subspec.ios.deployment_target = '8.0'
    subspec.ios.vendored_frameworks = 'StaticFrameworks/Dynamic/iOS/Alamofire.framework'
    subspec.osx.deployment_target = '10.10'
    subspec.osx.vendored_frameworks = 'StaticFrameworks/Dynamic/Mac/Alamofire.framework'
    subspec.tvos.deployment_target = '9.0'
    subspec.tvos.vendored_frameworks = 'StaticFrameworks/Dynamic/tvOS/Alamofire.framework'
    subspec.watchos.deployment_target = '2.0'
    subspec.watchos.vendored_frameworks = 'StaticFrameworks/Dynamic/watchOS/Alamofire.framework'
  end

end
