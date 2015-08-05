# Uncomment this line to define a global platform for your project
# platform :ios, '6.0'

target 'hackuProduct' do
	platform :ios, '7.0'
	pod "AFNetworking", "~> 2.0"
	pod 'RMUniversalAlert'
	pod 'SDWebImage', '~>3.7'
	pod 'SIAlertView'
	pod 'SVProgressHUD'
	pod 'CLImageEditor'
	pod 'Parse'
	pod 'REMenu', '~> 1.10'
end

target 'hackuProductTests' do

end

post_install do | installer |
  require 'fileutils'
  FileUtils.cp_r('Pods/Target Support Files/Pods-hackuProduct/Pods-hackuProduct-acknowledgements.plist', 'hackuProduct/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
end

