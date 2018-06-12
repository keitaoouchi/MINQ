fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew cask install fastlane`

# Available Actions
## iOS
### ios setup
```
fastlane ios setup
```
セットアップ(Certifications, CocoaPods, Carthage)
### ios beta
```
fastlane ios beta
```
Betaビルドの配布
### ios submit
```
fastlane ios submit
```
Releaseビルドを作成してAppStoreにアップロードする
### ios certificates
```
fastlane ios certificates
```
Certificates
### ios register_devices!
```
fastlane ios register_devices!
```
Devices一覧とProvisioningProfile更新
### ios screenshots
```
fastlane ios screenshots
```
ストア用スクショ作成
### ios test
```
fastlane ios test
```
Testを実行

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
