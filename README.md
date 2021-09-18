# MINQ

オープンソースのiOS用Qiitaアプリ。

[![appstore](https://keitaoouchi.github.io/minq-web/images/apple.svg)](https://itunes.apple.com/jp/app/%E3%83%8B%E3%83%A5%E3%83%BC%E3%82%B9%E3%82%A2%E3%83%97%E3%83%AA%E6%84%9F%E8%A6%9A%E3%81%AEqiita%E3%83%AA%E3%83%BC%E3%83%80%E3%83%BC-minq/id1130700537?mt=8)

## ライセンス

MINQ is under MIT license. See the [LICENSE](LICENSE) file for more info.

## Build & Run

```bash
bundle install
bundle exec pod install
# ここでQiitaのクライアントIDとシークレットを入力
cp config/GoogleService-Info.plist.template config/GoogleService-Info.Debug.plist
cp config/GoogleService-Info.plist.template config/GoogleService-Info.Release.plist
mkdir Generated
./Pods/SwiftGen/bin/swiftgen config run
open MINQ.xcworkspace
```

### 設定ファイル

```
config
├── GoogleService-Info.Debug.plist
├── GoogleService-Info.Release.plist
└── GoogleService-Info.plist
```
