import SwiftyBeaver
import Keys

struct Debugger {
  static let shared = SwiftyBeaver.self

  static func configure() {
    #if DEBUG
    let console = ConsoleDestination()
    console.format = "[MINQ][$L@$N.$F:$l] $M"
    shared.addDestination(console)
    console.minLevel = .debug
    let keys = MINQKeys()
    let id = keys.swiftyBeaverId
    let secret = keys.swiftyBeaverSecret
    let key = keys.swiftyBeaverEncryptionKey
    if !(id.isEmpty || secret.isEmpty || key.isEmpty) {
      let cloud = SBPlatformDestination(appID: id, appSecret: secret, encryptionKey: key)
      shared.addDestination(cloud)
    }
    #endif
  }
}
