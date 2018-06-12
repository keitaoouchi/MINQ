import Quick
import Nimble
import RealmSwift
@testable import MINQ

class ItemCollectionRecordSpec: QuickSpec {
  
  override func spec() {
    beforeEach {
      TestHelper.configureDB()
    }
    
    describe(".save(of:with:paging:)") {
      it("should create new ItemCollecctionRecord with given items and paging") {
        let items = TestFixture.items
        let paging = Paging(page: 0, perPage: 100)
        try! ItemCollectionRecord.save(of: .latest, with: items, paging: paging)
        let record = try! ItemCollectionRecord.find(of: .latest)
        expect(record).notTo(beNil())
        expect(record!.paging).notTo(beNil())
        expect(record!.updatedAt).notTo(beNil())
        expect(record!.items.map { $0.id }).to(contain(items.map { $0.id }))
        expect(record!.isOutdated).to(beFalse())
      }
    }
    
    describe(".find(of:)") {
      it("should return nil if given type is not stored") {
        expect(try! ItemCollectionRecord.find(of: .mine)).to(beNil())
      }
      
      it("should return nil if given type is stored") {
        try! ItemCollectionRecord.save(of: .mine, with: [], paging: nil)
        expect(try! ItemCollectionRecord.find(of: .mine)).notTo(beNil())
      }
    }
    
    describe("findOrNew(of:)") {
      it("should return new unmanaged record if not exists") {
        let record = try! ItemCollectionRecord.findOrNew(of: .mine)
        expect(record.realm).to(beNil())
      }
      
      it("should return existing managed record if exists") {
        try! ItemCollectionRecord.save(of: .mine, with: [], paging: nil)
        let record = try! ItemCollectionRecord.findOrNew(of: .mine)
        expect(record.realm).notTo(beNil())
      }
    }
    
    describe("findOrCreate(of:)") {
      it("should return new managed record if not exists") {
        let record = try! ItemCollectionRecord.findOrCreate(of: .mine)
        expect(record.realm).notTo(beNil())
      }
    }
    
    describe(".append(of:with:paging:)") {
      beforeEach {
        let items = TestFixture.items
        let paging = Paging(page: 0, perPage: 100)
        try! ItemCollectionRecord.save(of: .mine, with: items, paging: paging)
      }

      it("should not append duplicate items") {
        let newItems = TestFixture.items + [TestFixture.makeItem()]
        try! ItemCollectionRecord.append(of: .mine, with: newItems, paging: nil)
        let itemIds = try! ItemCollectionRecord.find(of: .mine)!.items.map { $0.id }
        expect(itemIds).to(contain(newItems.map { $0.id }))
        expect(itemIds.count).to(equal(TestFixture.items.count + 1))
      }
      
      it("should update paing") {
        let newPaging = Paging(page: 1, perPage: 100)
        try! ItemCollectionRecord.append(of: .mine, with: [], paging: newPaging)
        let paging = try! ItemCollectionRecord.find(of: .mine)!.paging!
        expect(paging.page).to(equal(newPaging.page))
        expect(paging.perPage).to(equal(newPaging.perPage))
      }
    }
    
  }
}
