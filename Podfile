source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '8.0'

use_frameworks!

project 'spawn-notifications-ios'

target 'spawn-notifications-ios' do
pod 'Alamofire', :git => 'https://github.com/Alamofire/Alamofire.git', :branch => 'master', :submodules => true
pod 'SwiftWebSocket', :git => 'https://github.com/tidwall/SwiftWebSocket.git', :branch => 'swift/3.0', :submodules => true
pod 'ReachabilitySwift', '~> 3'
pod 'Reachability'
pod 'SwiftMoment'
end

post_install do |installer|
installer.pods_project.targets.each do |target|
puts target.name
end
end
