Pod::Spec.new do |s|
s.name                   = "spawn-notifications-ios"
s.version                = "0.1.0"
s.summary                = "Spawn Notifications SDK for iOS."
s.homepage               = "https://github.com/hjudi/spawn-notifications-ios"
s.license                = { :type => "Attribution License", :file => "LICENSE" }
s.source                 = { :git => "https://github.com/hjudi/spawn-notifications-ios.git", :tag => "0.1.0" }
s.authors                = { 'Haz' => 'haz@born.cool' }
s.social_media_url       = "https://twitter.com/tidwall"
s.ios.deployment_target  = "8.0"
s.osx.deployment_target  = "10.9"
s.tvos.deployment_target = "9.0"
s.source_files           = "Source/*.swift"
s.requires_arc           = true
s.libraries              = 'z'
s.dependency 'RealmSwift'
end
