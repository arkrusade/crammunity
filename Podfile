# Uncomment this line to define a global platform for your project
platform :ios, '9.0'
source 'https://github.com/CocoaPods/Specs'
#source 'https://github.com/twilio/cocoapod-specs'
source 'https://github.com/Alamofire/Alamofire.git'

target 'crammunity' do
  # Comment this line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
#
#pod 'Bond', '4.0.0'
#pod 'ConvenienceKit'
  pod 'DateTools'
  pod 'Firebase'
  pod 'Firebase/Database'
  pod 'Firebase/Core'
  # pod 'Firebase/AdMob'
  pod 'Firebase/Messaging'
  pod 'Firebase/Database'
  #pod 'Firebase/Invites'
  pod 'Firebase/DynamicLinks'
  pod 'Firebase/Crash'
  pod 'Firebase/RemoteConfig'
  pod 'Firebase/Auth'
  pod 'Firebase/AppIndexing'
  pod 'Firebase/Storage'
  #pod 'Alamofire', '~> 3.4.1'
  #pod 'AlamofireImage'
  
end

post_install do |installer|
	installer.pods_project.targets.each do |target|
		target.build_configurations.each do |config|
			config.build_settings['ENABLE_BITCODE'] = 'NO'
		end
	end
end
