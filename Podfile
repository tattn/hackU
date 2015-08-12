# Uncomment this line to define a global platform for your project
platform :ios, '8.0'
use_frameworks!

target 'hackuProduct' do
	platform :ios, '8.0'
	pod "AFNetworking", "~> 2.0"
	pod 'RMUniversalAlert'
	pod 'SDWebImage', '~>3.7'
	pod 'SIAlertView', :git => 'https://github.com/tattn/SIAlertView.git'
	pod 'SVProgressHUD'
	pod 'CLImageEditor'
	# pod 'Parse'
	pod 'REMenu', '~> 1.10'
	pod 'TTToast', '~> 0.0.3'
	pod 'TTScanView', '~> 0.0.1'
end

target 'hackuProductTests' do

end

post_install do | installer |
  require 'fileutils'
  FileUtils.cp_r('Pods/Target Support Files/Pods-hackuProduct/Pods-hackuProduct-acknowledgements.plist', 'hackuProduct/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
end

