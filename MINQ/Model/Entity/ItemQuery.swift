struct ItemQuery {
  let type: QueryType
}

extension ItemQuery {

  enum QueryType: Hashable {
    case latest
    case stocks
    case mine
    case tag(tag: ItemTag)
    case user(user: User)
    case search(string: String)

    static func make(from string: String) -> QueryType? {
      switch string {
      case "latest":
        return .latest
      case "stocks":
        return .stocks
      case "mine":
        return .mine

      default:
        if let identifier = string.split(separator: "_", maxSplits: 2, omittingEmptySubsequences: true).last?.lowercased() {
          if string.hasPrefix("tag_") {
            return .tag(tag: ItemTag(name: identifier))
          } else if string.hasPrefix("user_") {
            return .user(user: User(id: identifier))
          } else if string.hasPrefix("search_") {
            return .search(string: identifier)
          } else {
            return nil
          }
        } else {
          return nil
        }
      }
    }

    var title: String {
      switch self {
      case .latest:
        return L10n.latestItems
      case .stocks:
        return L10n.stockedItems
      case .mine:
        return L10n.myItems
      case .tag(let tag):
        return tag.name
      case .user(let user):
        return user.id
      case .search:
        return L10n.search
      }
    }

    /// ItemCollectionRecordのtypeStringへの変換値
    var tableKey: String {
      switch self {
      case .latest:
        return "latest"
      case .stocks:
        return "stocks"
      case .mine:
        return "mine"
      case .tag(let tag):
        return "tag_\(tag.name)"
      case .user(let user):
        return "user_\(user.id)"
      case .search(let string):
        return "search_\(string)"
      }
    }

    var authRequired: Bool {
      switch self {
      case .mine, .stocks:
        return true
      default:
        return false
      }
    }
  }

}
