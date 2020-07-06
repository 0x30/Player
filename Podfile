# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

def shared_pods
  pod 'SnapKit'

  pod 'RxCocoa'
  pod 'RxSwift'
  
  pod 'RxOptional'
  
  pod 'MobileVLCKit', :podspec => 'http://localhost:3030/MobileVLCKit.podspec.json'
end

target 'CoeverPlayer' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for CoeverPlayer

  shared_pods

  target 'CoeverPlayerTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'CoeverPlayerUITests' do
    # Pods for testing
  end

end

target 'VideoThumbnail' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for VideoThumbnail

  shared_pods

end
