import RealmSwift

extension UserRecord {
  convenience init(entity: User) {
    self.init()
    self.id = entity.id
    self.name = entity.name
    self.profile = entity.profile
    self.facebookId = entity.facebookId
    self.followeesCount.value = entity.followeesCount
    self.followersCount.value = entity.followersCount
    self.githubLoginName = entity.githubLoginName
    self.itemsCount.value = entity.itemsCount
    self.linkedinId = entity.linkedinId
    self.location = entity.location
    self.organization = entity.organization
    self.profileImageUrl = entity.profileImageUrl
    self.twitterScreenName = entity.twitterScreenName
    self.wesiteUrl = entity.websiteUrl
  }
}
