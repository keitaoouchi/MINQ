import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    FirebaseApp.configure()
    Debugger.configure()
    MINQDatabase.configure()
    try! WatchingTagRepository.storeInitialRecordsIfNeeded()

    UINavigationBar.appearance().tintColor = .secondaryLabel
    UITabBar.appearance().tintColor = Asset.Colors.green.color
    UIButton.appearance().isExclusiveTouch = true

    let window = UIWindow(frame: UIScreen.main.bounds)
    self.window = window
    window.makeKeyAndVisible()
    let vc = AppRootViewController()
    window.rootViewController = vc
    return true
  }

  func applicationDidEnterBackground(_ application: UIApplication) {
    try? MINQDatabase.compact()
  }

}
