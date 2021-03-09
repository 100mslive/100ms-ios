
platform :ios, '10.0'

target 'HMSVideo_Example' do
  pod 'HMSVideo'
  
  pod 'Firebase/Crashlytics'

  target 'HMSVideo_Tests' do
    inherit! :search_paths
  end
end

post_install do |installer|
  installer.pods_project.build_configurations.each do |config|
    config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
  end
end
