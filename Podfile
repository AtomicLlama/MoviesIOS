workspace 'Movies'
source 'https://github.com/CocoaPods/Specs.git'
xcodeproj 'Movies.xcodeproj'
platform :ios, '8.0'
use_frameworks!

target "Movies" do
	xcodeproj 'Movies.xcodeproj'
	pod 'Alamofire'
	pod 'PZPullToRefresh'
	pod 'JFMinimalNotifications', '~> 0.0.4'
	pod 'YouTubePlayer'
	pod 'MCSwipeTableViewCell', '~> 2.1.4'
	pod 'THCalendarDatePicker', '~> 1.2.5'
	pod 'GMStepper'
end

target "Watch Extension" do
	platform :watchos, '2.0'
	xcodeproj 'Movies.xcodeproj'
	pod 'Alamofire'
end
