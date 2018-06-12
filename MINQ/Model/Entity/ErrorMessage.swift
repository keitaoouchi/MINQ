import Moya

// Unauthorized {"message":"Unauthorized","type":"unauthorized"}
struct ErrorMessage: MINQCodable {
  let message: String
  let type: String
}

extension ErrorMessage {
  var isUnauthorized: Bool {
    return self.type == "unauthorized"
  }
}
