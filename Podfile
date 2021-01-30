# Uncomment the next line to define a global platform for your project
platform :ios, '13.0'
source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/sktston/Specs.git'

target 'EvernymApp' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for EvernymApp
  #pod 'vcx'
  #pod 'MobileWallet', :path => '/Users/volk/TopCoder/34_Evernym/mobile-wallet'
  pod 'MobileWallet', :git => 'git@github.com:topcoder-platform/mobile-wallet.git', :branch => 'master'
  pod 'Keychain83', '0.0.1'
  pod 'SwiftEx83/Int'
  pod 'QRCodeScanner83', :git => 'https://github.com/seriyvolk83/QRCodeScanner.git', :tag => '0.0.3'
  pod 'AppCenter/Distribute'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ENABLE_BITCODE'] = 'NO'
    end
  end
end
