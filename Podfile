source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '9.0'

use_frameworks!

project 'spawn-notifications-ios'

target 'spawn-notifications-ios' do
	pod 'SwiftMoment', :git => 'https://github.com/akosma/SwiftMoment.git', :branch => 'master', :submodules => true
	pod 'Alamofire', :git => 'https://github.com/Alamofire/Alamofire.git', :branch => 'master', :submodules => true
	pod 'RealmSwift'
	pod 'SnapKit'
	pod 'ActionSheetPicker-3.0'
end

post_install do |installer|
	installer.pods_project.targets.each do |target|
		target.build_configurations.each do |config|
			config.build_settings['SWIFT_VERSION'] = '4.0'
		end
	end
end
