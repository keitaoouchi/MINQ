import Foundation

protocol MINQCodable: Codable {
  static func from(data: Data) -> Self?
}

extension MINQCodable {

  static func from(data: Data) -> Self? {
    do {
      let decoder = JSONDecoder()
      return try decoder.decode(Self.self, from: data)
    } catch {
      Debugger.shared.error("[MINQ][MAPPING_ERROR] \(error)")
      return nil
    }
  }

  static func from(data: Data) -> [Self]? {
    do {
      let decoder = JSONDecoder()
      return try decoder.decode([Self].self, from: data)
    } catch {
      Debugger.shared.error("[MINQ][MAPPING_ERROR] \(error)")
      return nil
    }
  }

  var jsonData: Data? {
    let encoder = JSONEncoder()
    return try? encoder.encode(self)
  }
}
