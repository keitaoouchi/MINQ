import Umbrella

struct AnalyticsService {

  static private var analytics: Analytics<AnalyticsEvent> = {
    let analytics = Analytics<AnalyticsEvent>()
    analytics.register(provider: FirebaseProvider())
    analytics.register(provider: AnswersProvider())
    return analytics
  }()

  static func log(event: AnalyticsEvent) {
    self.analytics.log(event)
  }
}

enum AnalyticsEvent {
  case viewItem(id: String)
  case viewItemsBy(tag: ItemTag)
  case like(itemId: String)
  case stock(itemId: String)
  case signin(sucess: Bool)
  case search
  case reset
  case requestReview(stock: Int, likes: Int)
}

extension AnalyticsEvent: EventType {
  /// An event name to be logged
  func name(for provider: ProviderType) -> String? {
    switch self {
    case .viewItem:
      return "view_item"
    case .viewItemsBy:
      return "view_items_by_tag"
    case .like:
      return "like_item"
    case .stock:
      return "stock_item"
    case .signin:
      return "signin"
    case .search:
      return "search"
    case .reset:
      return "reset"
    case .requestReview:
      return "request_review"
    }
  }

  func parameters(for provider: ProviderType) -> [String: Any]? {
    switch self {
    case .viewItem(let id):
      return ["id": id]
    case .viewItemsBy(let tag):
      return ["tag": tag.name]
    case .like(let itemId), .stock(let itemId):
      return ["item_id": itemId]
    case .signin(let success):
      return ["success": success]
    case .requestReview(let stocks, let likes):
      return ["stocks": stocks, "likes": likes]
    default:
      return nil
    }
  }
}
