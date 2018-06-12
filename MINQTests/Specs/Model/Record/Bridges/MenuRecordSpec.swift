import Quick
import Nimble
import RealmSwift
@testable import MINQ

class MenuRecordSpec: QuickSpec {
  
  override func spec() {
    beforeEach {
      TestHelper.configureDB()
    }
    
    describe(".instance") {
      it("should return new singleton record even if none exists") {
        let realm = try! Realm()
        expect(realm.objects(MenuRecord.self)).to(beEmpty())
        expect(MenuRecord.instance).notTo(beNil())
        expect(realm.objects(MenuRecord.self)).notTo(beEmpty())
      }
    }
    
    describe(".add(tag:)") {
      it("should add given tag if it is not contained") {
        let newTag = TestFixture.tags.first!
        try! MenuRecord.instance.append(tag: newTag)
        expect(MenuRecord.instance.tags.map { $0.name }).to(contain(newTag.name))
      }
      
      it("should not add given tag if already contained") {
        let newTag = TestFixture.tags.first!
        let size = MenuRecord.instance.tags.count
        try! MenuRecord.instance.append(tag: newTag)
        try! MenuRecord.instance.append(tag: newTag)
        expect(MenuRecord.instance.tags.count).to(equal(size + 1))
      }
      
    }
    
    describe(".remove(named:)") {
      it("should remove given named tag") {
        let newTag = TestFixture.tags.first!
        try! MenuRecord.instance.append(tag: newTag)
        try! MenuRecord.instance.remove(named: newTag.name)
        expect(MenuRecord.instance.contains(tag: newTag)).to(beFalse())
      }
    }
    
    describe(".contains(tag:)") {
      it("should return boolean whether it contains given tag") {
        let tag = TestFixture.tags.first!
        expect(MenuRecord.instance.contains(tag: tag)).to(beFalse())
        try! MenuRecord.instance.append(tag: tag)
        expect(MenuRecord.instance.contains(tag: tag)).to(beTrue())
      }
    }
    
    describe(".move(named:to:)") {
      it("should move named tag's index to given index") {
        let tags = TestFixture.tags
        tags.forEach { try! MenuRecord.instance.append(tag: $0) }
        let firstTag = MenuRecord.instance.tags.first!
        let lastTag = MenuRecord.instance.tags.last!
        try! MenuRecord.instance.move(named: lastTag.name!, to: 0)
        expect(MenuRecord.instance.tags.first!.name).to(equal(lastTag.name))
        expect(MenuRecord.instance.tags[1].name).to(equal(firstTag.name))
      }
    }
  }
}
