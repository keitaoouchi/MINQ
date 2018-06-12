platform :ios, '11.0'
project 'MINQ.xcodeproj'
use_modular_headers!

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '4.0'
        end
    end
end

plugin 'cocoapods-keys', {
  project: 'MINQ',
  keys: [
    'swiftyBeaverId',
    'swiftyBeaverSecret',
    'swiftyBeaverEncryptionKey',
    'qiitaClientId',
    'qiitaClientSecret'
  ]
}

target 'MINQ' do
  pod 'Fabric'
  pod 'Crashlytics'
  pod 'Firebase/Core'
  pod 'Firebase/Analytics'
  pod 'Firebase/Performance'
  pod 'SwiftLint'
  pod 'SwiftGen'
  pod 'IoniconsKit'
  pod 'RKDropdownAlert'
  pod 'Umbrella'
  pod 'Umbrella/Firebase'
  pod 'Umbrella/Answers'

  pod 'Kingfisher'
  pod 'KeychainAccess'
  pod 'ReachabilitySwift'
  pod 'SwiftyBeaver'
  pod 'Hue'
  pod 'FluxxKit'
  pod 'MarkdownView'
  pod 'Reusable'
  pod 'Defaults'
  pod 'SwiftDate'
  pod 'Moya/RxSwift'
  pod 'RxSwift'
  pod 'RxCocoa'
  pod 'HTMLString'

  target 'MINQTests' do
    inherit! :search_paths
  end
end
