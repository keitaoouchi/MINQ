import Foundation
import Moya
import RxSwift
import SwiftDate

struct Item: MINQCodable {
  let body: String
  let commentsCount: Int64
  let createdAt: String
  let id: String
  let likesCount: Int64
  let isPrivate: Bool
  let title: String
  let updatedAt: String
  let url: String
  let tags: [Tag]
  let user: User
}

extension Item {
  enum CodingKeys: String, CodingKey {
    case body
    case commentsCount = "comments_count"
    case createdAt = "created_at"
    case id
    case likesCount = "likes_count"
    case isPrivate = "private"
    case title
    case updatedAt = "updated_at"
    case url
    case tags
    case user
  }
}

// MARK: - Init
extension Item {
  init?(record: ItemRecord) {
    guard
      let body = record.body,
      let commentsCount = record.commentsCount.value,
      let createdAt = record.createdAt,
      let id = record.id,
      let likesCount = record.likesCount.value,
      let isPrivate = record.isPrivate.value,
      let title = record.title,
      let updatedAt = record.updatedAt,
      let url = record.url,
      let user = User(record: record.user) else {
        return nil
    }
    self.body = body
    self.commentsCount = commentsCount
    self.createdAt = createdAt
    self.id = id
    self.likesCount = likesCount
    self.isPrivate = isPrivate
    self.title = title
    self.updatedAt = updatedAt
    self.url = url
    self.tags = Tag.from(records: record.tags)
    self.user = user
  }
}

// MARK: - Presentation
extension Item {

  var createdDateString: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZ"
    guard let createdDate = formatter.date(from: createdAt) else {
      return "unknown days ago"
    }

    let region = Region(
      tz: TimeZoneName.asiaTokyo.timeZone,
      cal: CalendarName.gregorian.calendar,
      loc: LocaleName.current.locale
    )
    let date = DateInRegion(absoluteDate: createdDate, in: region)
    return self.dateDiff(for: date)
  }

  private func dateDiff(for date: DateInRegion) -> String {
    let current = DateInRegion()
    if current - 1.hours < date {
      let diff = abs((date - current).in(.minute) ?? 0)
      return "\(diff) minutes ago"
    } else if current - 24.hours < date {
      let diff = abs((date - current).in(.hour) ?? 0)
      return "\(diff) hours ago"
    } else if current - 31.days < date {
      let diff = abs((date - current).in(.day) ?? 0)
      return "\(diff) days ago"
    } else {
      let diff = abs((date - current).in(.month) ?? 0)
      return "\(diff) months ago"
    }
  }
}

// MARK: - API
extension Item {

  static func find(by id: String) -> Single<ItemContainer> {
    return API
      .provider
      .rx
      .request(.item(id: id))
      .map { response in
        if let container = ItemContainer.from(response: response) {
          return container
        } else {
          throw APIError.mappingError
        }
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
    if Authentication.retrieve() != nil {
      return User.whoami().flatMap { userContainer in
        return findPublishedItems(by: userContainer.content,
                                  paging: paging)
      }
    } else {
      return Single.error(AuthError.notAuthorized)
    }
  }

  private static func findMyStockedItems(paging: Paging) -> Single<ItemsContainer> {
    if Authentication.retrieve() != nil {
      return User.whoami().flatMap { userContainer in
        return findStockedItems(by: userContainer.content,
                                paging: paging)
      }
    } else {
      return Single.error(AuthError.notAuthorized)
    }
  }

  private static func findTaggedItems(by tag: Tag, paging: Paging) -> Single<ItemsContainer> {
    return API
      .provider
      .rx
      .request(.tagItems(tag: tag, paging: paging))
      .map { response in
        if let container = ItemsContainer.from(response: response) {
          return container
        } else {
          throw APIError.mappingError
        }
      }
  }

  private static func findPublishedItems(by user: User, paging: Paging) -> Single<ItemsContainer> {
    return API
      .provider
      .rx
      .request(.userItems(user: user, paging: paging))
      .map { response in
        if let container = ItemsContainer.from(response: response) {
          return container
        } else {
          throw APIError.mappingError
        }
    }
  }

  private static func findStockedItems(by user: User, paging: Paging) -> Single<ItemsContainer> {
    return API
      .provider
      .rx
      .request(.userStockedItems(user: user, paging: paging))
      .map { response in
        if let container = ItemsContainer.from(response: response) {
          return container
        } else {
          throw APIError.mappingError
        }
    }
  }

  private static func findAnyItems(by query: String, paging: Paging) -> Single<ItemsContainer> {
    return API
      .provider
      .rx
      .request(.anyItems(query: query, paging: paging))
      .map { response in
        if let container = ItemsContainer.from(response: response) {
          return container
        } else {
          throw APIError.mappingError
        }
    }
  }
}

extension Item {

  // TODO: すでに~~だったときのカスタムエラー

  func isLiked() -> Single<Bool> {
    return API
      .provider
      .rx
      .request(.isLikedItem(item: self))
      .map { response in
        return response.statusCode == 204
      }
  }

  func like() -> Single<Bool> {
    return API
      .provider
      .rx
      .request(.likeItem(item: self))
      .map { response in
        return response.statusCode == 204
      }
      .do(onSuccess: { success in
        if success {
          try? ItemRecord.like(item: self)
        }
      })
  }

  func unlike() -> Single<Bool> {
    return API
      .provider
      .rx
      .request(.unlikeItem(item: self))
      .map { response in
        return response.statusCode == 204
      }
      .do(onSuccess: { success in
        if success {
          try? ItemRecord.unlike(item: self)
        }
      })
  }
}

extension Item {

  // TODO: すでに~~だったときのカスタムエラー

  func isStocked() -> Single<Bool> {
    return API
      .provider
      .rx
      .request(.isStockedItem(item: self))
      .map { response in
        return response.statusCode == 204
      }
  }

  func stock() -> Single<Bool> {
    return API
      .provider
      .rx
      .request(.stockItem(item: self))
      .map { response in
        return response.statusCode == 204
      }
      .do(onSuccess: { success in
        if success {
          try? ItemCollectionRecord.append(item: self, to: .stocks)
        }
      })
  }

  func unstock() -> Single<Bool> {
    return API
      .provider
      .rx
      .request(.unstockItem(item: self))
      .map { response in
        return response.statusCode == 204
      }
      .do(onSuccess: { success in
        if success {
          try? ItemCollectionRecord.drop(item: self, from: .stocks)
        }
      })
  }
}
