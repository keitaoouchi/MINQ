import UIKit
import RealmSwift
import Moya
@testable import MINQ

final class TestHelper {
  
  static func wait(for seconds: TimeInterval) {
    let date = Date(timeIntervalSinceNow: seconds)
    RunLoop.current.run(until: date)
  }
  
  static func configureDB(id: String = UUID.init().uuidString) {
    Realm.Configuration.defaultConfiguration.inMemoryIdentifier = id
  }
  
  static func load(json name: String) -> Data {
    guard
      let path = Bundle(for: self as AnyClass).path(forResource: name, ofType: "json") else {
        fatalError()
    }
    
    return try! Data(contentsOf: URL(fileURLWithPath: path))
  }
  
  static func stubAPI() {
    makeStub(statusCode: 200, responseData: Data())
  }
  
  static func makeStub(statusCode: Int, responseData: Data) {
    let stubEndpoint = { (target: API) -> Endpoint in
      return Endpoint(
        url: URL(target: target).absoluteString,
        sampleResponseClosure: {
          return .networkResponse(statusCode, responseData)
        },
        method: target.method,
        task: target.task,
        httpHeaderFields: nil
      )
    }
    
    let stubProvider: MoyaProvider<API> =
      MoyaProvider<API>(
        endpointClosure: stubEndpoint,
        stubClosure: MoyaProvider.immediatelyStub,
        plugins: []
    )
    
    API.stub(provider: stubProvider)
  }

}
