import Quick
import Nimble
import RealmSwift
@testable import MINQ

class ItemRecordSpec: QuickSpec {
  
  override func spec() {
    
    beforeEach {
      TestHelper.configureDB()
    }
    
    describe(".find(by:)") {
      it("should return nil if there is no record that match a given id") {
        expect(try! ItemRecord.find(by: "hoge")).to(beNil())
      }
      
      it("should return a record if there is any record that match a given id") {
        let item = TestFixture.item
        try? ItemRecord.save(entity: item)
        expect(try! ItemRecord.find(by: item.id)).notTo(beNil())
      }
    }
    
    describe(".findReadItems()") {
      it("should return results of ItemRecord that of readAt is not nil") {
        let items = ItemRecord.new(by: TestFixture.items)
        let realm = try! Realm()
        try! realm.write {
          items.forEach { realm.add($0, update: true) }
        }
        let readItems = try! ItemRecord.findReadItems()
        expect(readItems).to(beEmpty())
        
        try! items.first?.touch()
        expect(readItems).to(contain(items.first!))
      }
    }
    
    describe(".save(entity:)") {
      it("should save given entity") {
        let item = TestFixture.item
        try! ItemRecord.save(entity: item)
        let realm = try! Realm()
        let record = realm.object(ofType: ItemRecord.self, forPrimaryKey: item.id)
        expect(record!.id).to(equal(item.id))
      }
    }
    
    describe(".like(item:)") {
      it("should increment its likesCount") {
        let item = TestFixture.item
        try! ItemRecord.save(entity: item)
        try! ItemRecord.like(item: item)
        let itemRecord = try! ItemRecord.find(by: item.id)
        expect(itemRecord!.likesCount.value!).to(equal(item.likesCount + 1))
      }
    }
    
    describe(".unlike(item:)") {
      it("should decrement its likesCount") {
        let item = TestFixture.item
        try! ItemRecord.save(entity: item)
        try! ItemRecord.unlike(item: item)
        let itemRecord = try! ItemRecord.find(by: item.id)
        expect(itemRecord!.likesCount.value!).to(equal(item.likesCount - 1))
      }
    }
    
    describe(".touch()") {
      it("should update its readAt to current date time") {
        let item = TestFixture.item
        try! ItemRecord.save(entity: item)
        let record = try! ItemRecord.find(by: item.id)
        try! record!.touch()
        expect(record?.readAt).notTo(beNil())
      }
    }
  }
}
