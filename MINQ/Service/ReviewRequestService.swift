import StoreKit

struct ReviewRequestService {
  static var stocksCount: Int = {
    UserDefaults.standard.integer(forKey: "stocks_count_in_app")
  }() {
    didSet {
      UserDefaults.standard.setValue(stocksCount, forKey: "stocks_count_in_app")
    }
  }

  static var likesCount: Int = {
    UserDefaults.standard.integer(forKey: "likes_count_in_app")
  }() {
    didSet {
      UserDefaults.standard.setValue(likesCount, forKey: "likes_count_in_app")
    }
  }

  static var reviewRequested: Bool = {
    UserDefaults.standard.bool(forKey: "review_requested_in_app")
  }() {
    didSet {
      UserDefaults.standard.setValue(reviewRequested, forKey: "review_requested_in_app")
    }
  }

  static var shouldRequestReview: Bool {
    !reviewRequested && (stocksCount > 10 || likesCount > 10 || stocksCount + likesCount > 10)
  }
}

extension ReviewRequestService {
  static func stocked() {
    stocksCount += 1
  }

  static func liked() {
    likesCount += 1
  }

  static func request() {
    AnalyticsService.log(event: .requestReview(stock: stocksCount, likes: likesCount))
    SKStoreReviewController.requestReview()
    reviewRequested = true
  }
}
