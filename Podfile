# Uncomment this line to define a global platform for your project
# platform :ios, '6.0'

target 'hackuProduct' do
	platform :ios, '7.0'
	pod "AFNetworking", "~> 2.0"
<<<<<<< HEAD
	pod 'RMUniversalAlert'
=======
	pod 'SDWebImage', '~>3.7'
>>>>>>> 5a1d3a7c0b27bf3444bdb102d96bed339a726fe8
end

target 'hackuProductTests' do

end

post_install do | installer |
  require 'fileutils'
  FileUtils.cp_r('Pods/Target Support Files/Pods-hackuProduct/Pods-hackuProduct-acknowledgements.plist', 'hackuProduct/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
end

