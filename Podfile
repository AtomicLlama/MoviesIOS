workspace 'Movies'
source 'https://github.com/CocoaPods/Specs.git'
xcodeproj 'Movies.xcodeproj'
platform :ios, '10.0'
use_frameworks!

target "Movies" do
	xcodeproj 'Movies.xcodeproj'
	pod 'Alamofire', '~> 4.0'
	pod 'PZPullToRefresh', :git => 'https://github.com/mathiasquintero/PZPullToRefresh.git'
	pod 'MXParallaxHeader'
	pod 'JFMinimalNotifications', '~> 0.0.4'
	pod 'YouTubePlayer', :git => 'https://github.com/jr9098/Swift-YouTube-Player.git', :branch => 'swift3'
	pod 'MCSwipeTableViewCell', '~> 2.1.4'
	pod 'THCalendarDatePicker', '~> 1.2.6'
	pod 'GMStepper', '~> 2.0'
	pod 'SFFocusViewLayout', '~> 3.0'
  	pod 'DoneHUD', :git => 'https://github.com/mathiasquintero/DoneHUD.git', :commit => '66c7f875e6eecc6124d2998dd0bca656f2bac032'
	pod 'ObjectMapper', '~> 2.2.1'
	pod 'AlamofireObjectMapper', '~> 4.0'
end

target "Watch Extension" do
	platform :watchos, '3.0'
	xcodeproj 'Movies.xcodeproj'
	pod 'Alamofire', '~> 4.0'
	pod 'ObjectMapper', '~> 2.2.1'
	pod 'AlamofireObjectMapper', '~> 4.0'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.0.1'
    end
  end
end
