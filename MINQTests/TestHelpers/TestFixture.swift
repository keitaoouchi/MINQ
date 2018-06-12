import Foundation
@testable import MINQ

final class TestFixture {

  static func makeItem() -> Item {
    
    return Item(body: "", commentsCount: 0, createdAt: "", id: UUID().uuidString, likesCount: 9, isPrivate: false, title: UUID().uuidString, updatedAt: "", url: "", tags: [], user: makeUser())
  }
  
  static var item: Item {
    return Item.from(data: TestHelper.load(json: "item"))!
  }
  
  static var items: [Item] {
    return Item.from(data: TestHelper.load(json: "items"))!
  }
  
  static var tags: [Tag] {
    let followingTags: [FollowingTag] = FollowingTag.from(data: TestHelper.load(json: "tags"))!
    return followingTags.map { $0.asTag }
  }
  
  static func makeUser() -> User {
    return User(id: UUID().uuidString)
  }

  static var user: User {
    return User.from(data: TestHelper.load(json: "user"))!
  }
}
