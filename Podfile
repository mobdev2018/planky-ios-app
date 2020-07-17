source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'

use_frameworks!

# ignore all warnings from all pods
inhibit_all_warnings!


pod 'FBSDKCoreKit'
pod 'FBSDKLoginKit'
pod 'Dropbox-iOS-SDK'
pod 'couchbase-lite-ios'
pod 'couchbase-lite-ios/Listener'
pod 'yajl-objc'

post_install do |installer|
	installer.pods_project.targets.each do |target|
		target.build_configurations.each do |config|
			config.build_settings['ENABLE_BITCODE'] = 'NO'
		end
	end
end