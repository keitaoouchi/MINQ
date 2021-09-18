import UIKit
import FluxxKit
import RxSwift
import RKDropdownAlert
import AuthenticationServices

final class AppRootViewController: UIViewController {
  private var session: ASWebAuthenticationSession?
  private let store = AppRootViewModel.make()
  private let disposeBag = DisposeBag()

  init() {
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    Dispatcher.shared.unregister(store: store)
    Dispatcher.shared.register(store: store)

    bind(store: store)
    onStart()
  }

  deinit {
    Dispatcher.shared.unregister(store: store)
  }
}

// MARK: - アプリケーションのルーティング
extension AppRootViewController {

  func onStart() {
    onMain()
  }

  private func onMain() {
    let vc = MenuViewController.make()
    minq.fill(with: vc)
  }

  private func onRestart() {
    if let menu = children.first(where: { $0 is MenuViewController }) as? MenuViewController {
      menu.deactivateEachTab()
    }

    let launchScreen = StoryboardScene.LaunchScreen.initialScene.instantiate()
    minq.fill(with: launchScreen)
    AnalyticsService.log(event: .reset)
  }
}

// MARK: - バインド
private extension AppRootViewController {

  func bind(store: AppRootViewModel.AppRootStore) {
    store.state.messageStream.subscribe(on: MainScheduler.instance)
      .subscribe(onNext: { message in
        switch message {
        case .success(let title):
          RKDropdownAlert.title(title,
                                backgroundColor: Asset.Colors.blue.color,
                                textColor: .white)
        case .alert(let title):
          RKDropdownAlert.title(title,
                                backgroundColor: Asset.Colors.red.color,
                                textColor: .white)
        }
      }).disposed(by: self.disposeBag)

    store.state.signinTrigger.subscribe(on: MainScheduler.instance)
      .subscribe(onNext: { [weak self] _ in
        guard let self = self else { return }
        guard self.session == nil else { return }

        let service = OAuthService()
        let session = ASWebAuthenticationSession(
          url: service.url,
          callbackURLScheme: OAuthService.urlScheme
        ) { [weak self] url, _ in
          guard let self = self else { return }

          guard let url = url, let code = service.process(url: url) else { return }

          AuthenticationRepository
            .apply(code: code)
            .subscribe(
              onSuccess: { [weak self] _ in
                Dispatcher.shared.dispatch(
                  action: AppRootViewModel.Action.show(
                    message: .success(message: L10n.loggedIn)))
                self?.session = nil
                AnalyticsService.log(event: .signin(sucess: true))
              },
              onFailure: { [weak self] _ in
                self?.session = nil
                AnalyticsService.log(event: .signin(sucess: false))
              }
            ).disposed(by: self.disposeBag)
        }
        session.presentationContextProvider = self
        #if RELEASE
        session.prefersEphemeralWebBrowserSession = true
        #endif
        session.start()
        self.session = session

      }).disposed(by: disposeBag)

    store.state.resetTrigger.subscribe(onNext: { [weak self] force in
      guard !force else {
        self?.restartApp()
        return
      }
      let alert = UIAlertController(
        title: L10n.deleteCache,
        message: L10n.deleteCacheAndRestartApp,
        preferredStyle: .alert
      )
      let ok = UIAlertAction(title: L10n.ok, style: .default, handler: { _ in
        self?.onRestart()
        self?.restartApp()
      })
      let cancel = UIAlertAction(title: L10n.cancel, style: .cancel, handler: nil)
      alert.addAction(ok)
      alert.addAction(cancel)
      self?.present(alert, animated: true, completion: nil)
    }).disposed(by: self.disposeBag)
  }

  private func restartApp() {
    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: { [weak self] in
      try? MINQDatabase.refresh()
      self?.onStart()
    })
  }
}

extension AppRootViewController: ASWebAuthenticationPresentationContextProviding {
  func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
    view.window!
  }
}
