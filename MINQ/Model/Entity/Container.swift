import Moya

typealias ItemsContainer = ContentsContainer<Item>
typealias TagsContainer = ContentsContainer<FollowingTag>
typealias UserContainer = ContentContainer<User>
typealias ItemContainer = ContentContainer<Item>

struct ContentContainer<T: MINQCodable> {
  let content: T
  let rateLimit: RateLimit?

  static func from(response: Response) -> ContentContainer<T>? {
    if let content: T = T.from(data: response.data) {
      let rateLimit = RateLimit.parse(response: response.response)
      return ContentContainer(content: content, rateLimit: rateLimit)
    }
    return nil
  }
}

struct ContentsContainer<T: MINQCodable> {
  let contents: [T]
  let links: [Link]
  let rateLimit: RateLimit?

  var nextPage: PagingState {
    let queries = links.filter { $0.rel == .next }.first?.url.minq_queryDictionary
    if let pageStr = queries?["page"],
       let page = Int(pageStr),
       let perPageStr = queries?["per_page"],
       let perPage = Int(perPageStr) {
      let paging = Paging(page: page, perPage: perPage)
      return .newPage(paging: paging)
    } else {
      return .noPage
    }
  }

  static func from(response: Response) -> ContentsContainer<T>? {
    if let contents: [T] = T.from(data: response.data) {
      let links = Link.parse(response: response.response)
      let rateLimit = RateLimit.parse(response: response.response)
      return ContentsContainer(contents: contents, links: links, rateLimit: rateLimit)
    }
    return nil
  }
}
