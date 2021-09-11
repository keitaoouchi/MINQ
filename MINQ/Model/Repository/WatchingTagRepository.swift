import RealmSwift
import RxSwift
import SwiftUI

struct WatchingTagRepository {

  static func contains(named tagName: String) -> Bool {
    return try! Realm().object(ofType: WatchingTagRecord.self, forPrimaryKey: tagName) != nil
  }

  static func watchTagNames() -> Observable<[String]> {
    Observable.create { observer in
      let realm = try! Realm()
      let token = realm.objects(WatchingTagRecord.self).sorted(byKeyPath: "order").observe { changes in
        switch changes {
        case .initial(let tags):
          observer.onNext(tags.compactMap {$0.id})
        case .update(let tags, _, _, _):
          observer.onNext(tags.compactMap {$0.id})
        default:
          break
        }
      }
      return Disposables.create {
        token.invalidate()
      }
    }
  }

  static func observe(tagName: String) -> Observable<Bool> {
    return Observable.create { observer in
      let realm = try! Realm()
      let predicate = NSPredicate(format: "id = %@", tagName)
      let token = realm.objects(WatchingTagRecord.self).filter(predicate).observe { results in
        switch results {
        case .initial(let tags), .update(let tags, _, _, _):
          if tags.isEmpty {
            observer.on(.next(false))
          } else {
            observer.on(.next(true))
          }
        default:
          break
        }
      }
      return Disposables.create {
        token.invalidate()
      }
    }
  }

  static func findAllTagNames() -> [String] {
    let realm = try! Realm()
    return Array(realm.objects(WatchingTagRecord.self).sorted(byKeyPath: "order").compactMap { $0.id })
  }

  static func append(tag: ItemTag, in realm: Realm? = nil) throws {
    guard !self.contains(named: tag.name) else { return }

    let realm = try realm ?? Realm()
    let block = {
      let record = WatchingTagRecord()
      record.id = tag.name
      record.order = (realm.objects(WatchingTagRecord.self).max(ofProperty: "order") ?? -1) + 1
      realm.add(record, update: .modified)
    }
    if realm.isInWriteTransaction {
      block()
    } else {
      try realm.write(block)
    }
  }

  static func remove(named tagName: String, in realm: Realm? = nil) throws {
    let realm = try realm ?? Realm()
    let block = {
      if let record = realm.object(ofType: WatchingTagRecord.self, forPrimaryKey: tagName) {
        realm.delete(record)
      }
    }
    if realm.isInWriteTransaction {
      block()
    } else {
      try realm.write(block)
    }
  }

  static func reorder(by names: [String]) throws {
    let realm = try Realm()

    try realm.write {
      let records = names.enumerated().compactMap { offset, tag -> WatchingTagRecord? in
        if let record = realm.object(ofType: WatchingTagRecord.self, forPrimaryKey: tag) {
          record.order = offset
          return record
        }
        return nil
      }
      realm.add(records, update: .modified)
    }
  }

  static func storeInitialRecordsIfNeeded() throws {
    let key = "watching_tag_initialized"
    guard !UserDefaults.standard.bool(forKey: key) else { return }
    UserDefaults.standard.setValue(true, forKeyPath: key)
    let realm = try Realm()
    try realm.write {
      let defaultTags = ["Swift", "JavaScript", "AWS", "機械学習"]
      let records = defaultTags.enumerated().map { offset, tag -> WatchingTagRecord in
        let record = WatchingTagRecord()
        record.id = tag
        record.order = offset
        return record
      }
      realm.add(records)
    }
  }
}
