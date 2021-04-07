#
# Be sure to run `pod lib lint HMSVideo.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'HMSVideo'
  s.version          = '0.10.2'
  s.summary          = 'HMSVideo Videoconferencing iOS SDK'

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/100mslive/100ms-ios/'
  s.license          = { :type => 'MIT'}
  s.author           = { 'Dmitry Fedoseyev' => 'dmitry@100ms.live' }
  s.source           = { :git => 'https://github.com/100mslive/100ms-ios.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'
  s.cocoapods_version = '>= 1.7.5'

  s.source_files = 'HMSVideo/HMSVideo.framework/Headers/*.h'
  s.public_header_files = 'HMSVideo/HMSVideo.framework/Headers/*.h'
  s.vendored_frameworks = 'HMSVideo/HMSVideo.framework'
  
  s.dependency 'GoogleWebRTC', '1.1.31999'
  s.pod_target_xcconfig = {
   'ENABLE_BITCODE' => 'NO'
  }

end
