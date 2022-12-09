Pod::Spec.new do |s|
  s.name         = "AlivcVpaas"
  s.version      = "3.0.0.20221207001"
  s.summary      = "AlivcVpaas."
  s.description  = <<-DESC
                   It's an SDK for aliyun interactive live, which implement by Objective-C.
                   DESC
  s.homepage     = "https://github.com/aliyun/alibabacloud-AliIMPInteractiveLive-iOS-SDK"
  s.license      = { :type => "MIT", :text => "LICENSE" }
  s.author       = { 'aliyunvideo' => 'videosdk@service.aliyun.com' }
  s.platform     = :ios, "10.0"
  s.source       = { :http => "https://paas-sdk.oss-cn-shanghai.aliyuncs.com/paas/imp/ios/release-pod-sdk/#{s.version}.zip"}
  s.pod_target_xcconfig = {
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'
  }
  s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }	

  s.default_subspecs = 'UI_Base_AliVCSDK_PremiumLive'
  s.dependency 'Masonry'

  s.subspec 'UI_Base_AliVCSDK_PremiumLive' do |ss|
    ss.vendored_frameworks = "#{s.version}/AliStandardLiveRoomBundle.framework", "#{s.version}/AliVCSDK_PremiumLive/*.framework"
    ss.resource = "#{s.version}/AliStandardLiveRoomResource.bundle",  "#{s.version}/AliVCSDK_Resources/AliInteractiveFaceBeautyCoreResource.bundle"
    ss.dependency 'AliVCSDK_PremiumLive', '1.6.0'
  end

  s.subspec 'UI_Base_AliVCSDK_Premium' do |ss|
    ss.vendored_frameworks = "#{s.version}/AliStandardLiveRoomBundle.framework", "#{s.version}/AliVCSDK_Premium/*.framework"
    ss.resources = "#{s.version}/AliStandardLiveRoomResource.bundle",  "#{s.version}/AliVCSDK_Resources/AliInteractiveFaceBeautyCoreResource.bundle"
    ss.dependency 'AliVCSDK_Premium', '1.6.0'
  end

  s.subspec 'All_Base_AliVCSDK_PremiumLive' do |ss|
    ss.vendored_frameworks = "#{s.version}/AliStandardLiveRoomBundle.framework", "#{s.version}/AliVCSDK_PremiumLive/*.framework", "#{s.version}/RTC/AliVCSDK_PremiumLive/*.framework"
    ss.resource = "#{s.version}/AliStandardLiveRoomResource.bundle",  "#{s.version}/AliVCSDK_Resources/AliInteractiveFaceBeautyCoreResource.bundle"
    ss.dependency 'AliVCSDK_PremiumLive', '1.6.0'
  end

  s.subspec 'All_Base_AliVCSDK_Premium' do |ss|
    ss.vendored_frameworks = "#{s.version}/AliStandardLiveRoomBundle.framework", "#{s.version}/AliVCSDK_Premium/*.framework", "#{s.version}/RTC/AliVCSDK_Premium/*.framework"
    ss.resources = "#{s.version}/AliStandardLiveRoomResource.bundle",  "#{s.version}/AliVCSDK_Resources/AliInteractiveFaceBeautyCoreResource.bundle"
    ss.dependency 'AliVCSDK_Premium', '1.6.0'
  end


  s.subspec 'Standard_Base_AliVCSDK_PremiumLive' do |ss|
    ss.vendored_frameworks = "#{s.version}/AliVCSDK_PremiumLive/*.framework"
    ss.resources = "#{s.version}/AliVCSDK_Resources/AliInteractiveFaceBeautyCoreResource.bundle"
    ss.dependency 'AliVCSDK_PremiumLive', '1.6.0'
  end

  s.subspec 'Standard_Base_AliVCSDK_Premium' do |ss|
    ss.vendored_frameworks = "#{s.version}/AliVCSDK_Premium/*.framework"
    ss.resources = "#{s.version}/AliVCSDK_Resources/AliInteractiveFaceBeautyCoreResource.bundle"
    ss.dependency 'AliVCSDK_Premium', '1.6.0'
  end
  
end
