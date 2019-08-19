# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'Bitsy' do |installer|
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  pod 'GLNPianoView'

  target 'BitsyTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'BitsyUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['CONFIGURATION_BUILD_DIR'] = '$PODS_CONFIGURATION_BUILD_DIR'
    end
  end
end
