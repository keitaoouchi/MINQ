# MINQ

オープンソースのiOS用Qiitaアプリ。

[![appstore](https://keitaoouchi.github.io/minq-web/images/apple.svg)](https://itunes.apple.com/jp/app/%E3%83%8B%E3%83%A5%E3%83%BC%E3%82%B9%E3%82%A2%E3%83%97%E3%83%AA%E6%84%9F%E8%A6%9A%E3%81%AEqiita%E3%83%AA%E3%83%BC%E3%83%80%E3%83%BC-minq/id1130700537?mt=8)

## ライセンス

MINQ is under MIT license. See the [LICENSE](LICENSE) file for more info.

## Build & Run

```bash
bundle install
bundle exec pod install
carthage bootstrap --platform ios --cache-builds
bundle exec gyro --model MINQ/MINQ.xcdatamodeld/MINQ.xcdatamodel --template swift4 --output ./Generated
cp config/GoogleService-Info.plist.template config/GoogleService-Info.plist
cp config/Secrets.h.template config/Secrets.h
touch config/fabric.key
touch config/fabric.secret
open MINQ.xcworkspace
```

### 設定ファイル

```
config
├── GoogleService-Info.Debug.plist
├── GoogleService-Info.Release.plist
├── GoogleService-Info.plist
├── Secrets.h
├── fabric.key
└── fabric.secret
```

fabric.keyとfabric.secretはプレーンテキストにFabricのAPI KeyとBuild Secretを貼り付けたもの。
Secrets.hはInfo.plistのプリプロセスに使われ、Info.plistのなかにFabricのAPI Keyをハードコードしないようにするために設置。

```Objective-C
#ifndef Secrets_pch
#define Secrets_pch

#define _FABRIC_API_KEY         XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

#endif
```
