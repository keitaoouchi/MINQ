import RxSwift
import Moya
import RealmSwift
import RxRelay

// MARK: - API

struct ItemRepository {
  static func find(by id: String) -> Single<Item> {
    if let cached = findCached(by: id) {
      return Single.just(cached)
    } else {
      return API
        .provider
        .rx
        .request(.item(id: id))
        .mapItemContainer()
        .map { $0.content }
        .do(onSuccess: { item in
          try? ItemRepository.save(item)
        })
    }
  }

  static func find(by itemQuery: ItemQuery, paging: Paging) -> Single<ItemsContainer> {
    switch itemQuery.type {
    case .latest:
      return findAnyItems(by: "stocks:>6 OR lieks:>6", paging: paging)
    case .tag(let tag):
      return findTaggedItems(by: tag, paging: paging)
    case .user(let user):
      return findPublishedItems(by: user, paging: paging)
    case .mine:
      return findMyItems(paging: paging)
    case .stocks:
      return findMyStockedItems(paging: paging)
    case .search(let string):
      return findAnyItems(by: string, paging: paging)
    }
  }

  private static func findMyItems(paging: Paging) -> Single<ItemsContainer> {
    if AuthenticationRepository.find() != nil {
      return UserRepository.whoami().flatMap { userContainer in
        return findPublishedItems(by: userContainer.content,
                                  paging: paging)
      }
    } else {
      return Single.error(AuthError.notAuthorized)
    }
  }

  private static func findMyStockedItems(paging: Paging) -> Single<ItemsContainer> {
    if AuthenticationRepository.find() != nil {
      return UserRepository.whoami().flatMap { userContainer in
        return findStockedItems(by: userContainer.content,
                                paging: paging)
      }
    } else {
      return Single.error(AuthError.notAuthorized)
    }
  }

  private static func findTaggedItems(by tag: ItemTag, paging: Paging) -> Single<ItemsContainer> {
    return API
      .provider
      .rx
      .request(.tagItems(tag: tag, paging: paging))
      .mapItemsContainer()
  }

  private static func findPublishedItems(by user: User, paging: Paging) -> Single<ItemsContainer> {
    return API
      .provider
      .rx
      .request(.userItems(user: user, paging: paging))
      .mapItemsContainer()
  }

  private static func findStockedItems(by user: User, paging: Paging) -> Single<ItemsContainer> {
    return API
      .provider
      .rx
      .request(.userStockedItems(user: user, paging: paging))
      .mapItemsContainer()
  }

  private static func findAnyItems(by query: String, paging: Paging) -> Single<ItemsContainer> {
    API
      .provider
      .rx
      .request(.anyItems(query: query, paging: paging))
      .mapItemsContainer()
  }
}

// MARK: - LIKE

extension ItemRepository {
  static func isLiked(_ item: Item) -> Single<Bool> {
    return API
      .provider
      .rx
      .request(.isLikedItem(item: item))
      .map { response in
        return response.statusCode == 204
      }
  }

  static func like(_ item: Item) -> Single<Bool> {
    return API
      .provider
      .rx
      .request(.likeItem(item: item))
      .map { response in
        return response.statusCode == 204
      }
      .do(onSuccess: { success in
        if success {
          try? likeRecord(item)
        }
      })
  }

  static func unlike(_ item: Item) -> Single<Bool> {
    return API
      .provider
      .rx
      .request(.unlikeItem(item: item))
      .map { response in
        return response.statusCode == 204
      }
      .do(onSuccess: { success in
        if success {
          try? unlikeRecord(item)
        }
      })
  }
}

// MARK: - STOCK

extension ItemRepository {
  static func isStocked(_ item: Item) -> Single<Bool> {
    return API
      .provider
      .rx
      .request(.isStockedItem(item: item))
      .map { response in
        return response.statusCode == 204
      }
  }

  static func stock(_ item: Item) -> Single<Bool> {
    return API
      .provider
      .rx
      .request(.stockItem(item: item))
      .map { response in
        return response.statusCode == 204
      }
      .do(onSuccess: { success in
        if success {
          try? ItemRepository.append(item: item, to: .stocks)
        }
      })
  }

  static func unstock(_ item: Item) -> Single<Bool> {
    return API
      .provider
      .rx
      .request(.unstockItem(item: item))
      .map { response in
        return response.statusCode == 204
      }
      .do(onSuccess: { success in
        if success {
          try? ItemRepository.drop(item: item, from: .stocks)
        }
      })
  }
}

// MARK: - REALM

// MARK: - OBSERVATION
extension ItemRepository {
  static func watchItems(of type: ItemQuery.QueryType) -> Observable<[String]> {
    return Observable.create { observer in
      let items = try! ItemRepository.findOrCreateRecord(of: type).items
      let token = items.observe { changes in
        observer.onNext(changes.identifiers)
      }
      return Disposables.create {
        token.invalidate()
      }
    }
  }

  static func watchReadItems() -> (items: BehaviorRelay<[Item]>, token: NotificationToken) {
    let realm = try! Realm()
    let records = realm.objects(ItemRecord.self).filter("readAt != nil").sorted(byKeyPath: "readAt", ascending: false)
    let result = BehaviorRelay<[Item]>(value: [])
    let token = records.observe(on: DispatchQueue.main) { changes in
      switch changes {
      case .initial(let items), .update(let items, _, _, _):
        result.accept(items.compactMap { Item(record: $0) })
      case .error:
        break
      }
    }
    return (items: result, token: token)
  }
}

// MARK: - FIND

extension ItemRepository {
  static func findCachedItems(of type: ItemQuery.QueryType) -> ItemsContainer? {
    try? findRecord(of: type, in: Realm())?.containered
  }

  static func findCached(by id: String) -> Item? {
    if let record = try? findRecord(by: id) {
      return Item(record: record)
    }
    return nil
  }
}

// MARK: - UPDATE

extension ItemRepository {
  static func save(_ item: Item) throws {
    let realm = try Realm()
    try realm.write {
      let record = ItemRecord(item)
      realm.add(record, update: .modified)
    }
  }

  static func touch(_ item: Item) throws {
    guard let record = try findRecord(by: item.id) else { return }
    let realm = try Realm()
    try realm.write {
      record.readAt = Date()
      realm.add(record, update: .modified)
    }
  }

  static func save(of type: ItemQuery.QueryType,
                   with items: [Item]) throws {
    let realm = try Realm()
    try realm.write {
      let itemRecords = ItemRecord.new(by: items)
      let record = ItemRepository.findOrNewRecord(of: type, in: realm)
      record.items.removeAll()
      realm.add(itemRecords, update: .modified)
      record.items.append(objectsIn: itemRecords)
      record.updatedAt = Date()
      realm.add(record, update: .modified)
    }
  }

  // 追加の場合はupdatedAtを更新しない
  static func append(of type: ItemQuery.QueryType,
                     with items: [Item]) throws {
    let realm = try Realm()
    try realm.write {
      let record = ItemRepository.findOrNewRecord(of: type, in: realm)
      // 重複レコードのidを抽出する
      let duplicateIds = record
        .items
        .filter("id IN %@", items.map { $0.id }.sorted())
        .map { $0.id }
      let uniqueItems = items.filter { !duplicateIds.contains($0.id) }
      let itemRecords = ItemRecord.new(by: uniqueItems)
      realm.add(itemRecords, update: .modified)
      record.items.append(objectsIn: itemRecords)
      record.updatedAt = Date()
      realm.add(record, update: .modified)
    }
  }

  static func append(item: Item, to type: ItemQuery.QueryType) throws {
    try drop(item: item, from: type)
    let realm = try Realm()
    try realm.write {
      let record = ItemRepository.findOrNewRecord(of: type, in: realm)
      let itemRecord = ItemRecord(item)
      realm.add(itemRecord, update: .modified)
      record.items.insert(itemRecord, at: 0)
    }
  }

  static func drop(item: Item, from type: ItemQuery.QueryType) throws {
    let realm = try Realm()
    try realm.write {
      let record = ItemRepository.findOrNewRecord(of: type, in: realm)
      let predicate = NSPredicate(format: "id = %@", item.id)
      if let index = record.items.index(matching: predicate) {
        record.items.remove(at: index)
      }
    }
  }

  static func clear(type: ItemQuery.QueryType) throws {
    let realm = try Realm()
    try realm.write {
      guard let record = ItemRepository.findRecord(of: type, in: realm) else { return }
      record.items.removeAll()
    }
  }
}

// MARK: - PRIVATE
private extension ItemRepository {
  static func findRecord(by id: String) throws -> ItemRecord? {
    let realm = try Realm()
    return realm.object(ofType: ItemRecord.self,
                        forPrimaryKey: id)
  }

  static func findOrCreateRecord(of type: ItemQuery.QueryType) throws -> ItemCollectionRecord {
    let realm = try Realm()
    if let record = realm.object(ofType: ItemCollectionRecord.self,
                                 forPrimaryKey: type.tableKey) {
      return record
    } else {
      let record = ItemCollectionRecord()
      try realm.write {
        record.type = type
        realm.add(record)
      }
      return record
    }
  }

  static func findRecord(of type: ItemQuery.QueryType, in realm: Realm) -> ItemCollectionRecord? {
    if let record = realm.object(ofType: ItemCollectionRecord.self,
                                 forPrimaryKey: type.tableKey), !record.isOutdated {
      return record
    } else {
      return nil
    }
  }

  static func findOrNewRecord(of type: ItemQuery.QueryType, in realm: Realm) -> ItemCollectionRecord {
    if let record = realm.object(ofType: ItemCollectionRecord.self,
                                 forPrimaryKey: type.tableKey) {
      return record
    } else {
      let record = ItemCollectionRecord()
      record.type = type
      return record
    }
  }

  static func likeRecord(_ item: Item) throws {
    if let record = try findRecord(by: item.id),
       let currentCount = record.likesCount {
      let realm = try Realm()
      try realm.write {
        record.setValue(currentCount + 1, forKey: "likesCount")
      }
    }
  }

  static func unlikeRecord(_ item: Item) throws {
    if let record = try findRecord(by: item.id),
      let currentCount = record.likesCount {
      let realm = try Realm()
      try realm.write {
        record.setValue(currentCount - 1, forKey: "likesCount")
      }
    }
  }
}

fileprivate extension PrimitiveSequenceType where Trait == SingleTrait, Element == Response {
  func mapItemsContainer() -> Single<ItemsContainer> {
    self.map { response in
      if response.statusCode != 200 {
        throw APIError.responseError
      } else if let container = ItemsContainer.from(response: response) {
        return container
      } else {
        throw APIError.mappingError
      }
    }
  }

  func mapItemContainer() -> Single<ItemContainer> {
    self.map { response in
      if response.statusCode != 200 {
        throw APIError.responseError
      } else if let container = ItemContainer.from(response: response) {
        return container
      } else {
        throw APIError.mappingError
      }
    }
  }
}
