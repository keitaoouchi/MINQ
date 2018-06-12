import Realm
import RealmSwift

struct MINQDatabase {

  /// 現在のスキーマバージョン
  static let schemaVersion: UInt64 = 0

  /// 設定とマイグレーションを実行する
  static func configure() {
    Realm.Configuration.defaultConfiguration = defaultConfiguration
    _ = try? Realm()
  }

  /// コンパクション実行
  static func compact() throws {
    if let defaultURL = Realm.Configuration.defaultConfiguration.fileURL {
      let compactedURL = defaultURL
        .deletingLastPathComponent()
        .appendingPathComponent("compacting.realm")

      try autoreleasepool {
        let realm = try Realm()
        try realm.writeCopy(toFile: compactedURL)
        try FileManager.default.removeItem(at: defaultURL)
        try FileManager.default.moveItem(at: compactedURL, to: defaultURL)
      }
    }
  }

  static func refresh() throws {
    let realm = try Realm()
    try realm.write {
      realm.deleteAll()
    }
    try compact()
  }
}

private extension MINQDatabase {
  static var defaultConfiguration: Realm.Configuration {
    var config = Realm.Configuration(schemaVersion: schemaVersion)
    config.deleteRealmIfMigrationNeeded = true
    return config
  }
}
