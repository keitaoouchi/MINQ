import Foundation
import Moya
import RxSwift
import SwiftDate

struct Item: MINQCodable, Hashable {
  let body: String
  let commentsCount: Int
  let createdAt: String
  let id: String
  let likesCount: Int
  let title: String
  let updatedAt: String
  let url: String
  let tags: [ItemTag]
  let user: User
}

// MARK: - Init
extension Item {
  init?(record: ItemRecord) {
    guard
      let body = record.body,
      let commentsCount = record.commentsCount,
      let createdAt = record.createdAt,
      let id = record.id,
      let likesCount = record.likesCount,
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
    self.title = title
    self.updatedAt = updatedAt
    self.url = url
    self.tags = ItemTag.from(records: record.tags)
    self.user = user
  }
}

// MARK: - Presentation
extension Item {

  var createdDateString: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZ"
    guard let createdDate = formatter.date(from: createdAt) else {
      return L10n.unknownDaysAgo
    }

    let region = Region(
      calendar: Calendar(identifier: .gregorian),
      zone: Zones.asiaTokyo,
      locale: Locale.current)
    let date = DateInRegion(createdDate, region: region)
    return self.dateDiff(for: date)
  }

  private func dateDiff(for date: DateInRegion) -> String {
    let current = DateInRegion()
    if current - 1.hours < date {
      let diff = abs((date - current).toUnit(.minute) ?? 0)
      return L10n.dMinutesAgo(diff)
    } else if current - 24.hours < date {
      let diff = abs((date - current).toUnit(.hour) ?? 0)
      return L10n.dHoursAgo(diff)
    } else if current - 31.days < date {
      let diff = abs((date - current).toUnit(.day) ?? 0)
      return L10n.dDaysAgo(diff)
    } else if current - 12.months < date {
      let diff = abs((date - current).toUnit(.month) ?? 0)
      return L10n.dMonthsAgo(diff)
    } else {
      let diff = abs((date - current).toUnit(.year) ?? 0)
      return L10n.dYearsAgo(diff)
    }
  }
}
