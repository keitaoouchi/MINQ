import UIKit
import Firebase
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

      Fabric.with([Answers.self, Crashlytics.self])
      FirebaseApp.configure()
      Debugger.configure()
      MINQDatabase.configure()

      UINavigationBar.appearance().tintColor = Asset.Colors.gray.color
      UITabBar.appearance().tintColor = Asset.Colors.green.color
      UIButton.appearance().isExclusiveTouch = true

      return true
    }

  func applicationDidEnterBackground(_ application: UIApplication) {
    try? MINQDatabase.compact()
  }

}
