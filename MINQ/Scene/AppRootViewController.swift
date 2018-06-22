import UIKit
import FluxxKit
import RxSwift
import RKDropdownAlert
import SafariServices

final class AppRootViewController: UIViewController {

  private var session: SFAuthenticationSession?
  private let store = AppRootViewModel.make()
  private let disposeBag = DisposeBag()

  override func viewDidLoad() {
    super.viewDidLoad()
    self.onStart()
  }

  deinit {
    Dispatcher.shared.unregister(store: store)
  }
}

// MARK: - アプリケーションのルーティング
extension AppRootViewController {

  func onStart() {
    Dispatcher.shared.unregister(store: store)
    Dispatcher.shared.register(store: self.store)

    self.bind(store: self.store)

    self.onMain()
  }

  private func onMain() {
    let vc = MenuViewController.make()
    self.minq.fill(with: vc)
  }

  private func onRestart() {
    let launchScreen = StoryboardScene.LaunchScreen.initialScene.instantiate()
    self.minq.fill(with: launchScreen)
    AnalyticsService.log(event: .reset)
  }
}

// MARK: - バインド
private extension AppRootViewController {

  func bind(store: AppRootViewModel.AppRootStore) {
    store.state.messageStream.subscribeOn(MainScheduler.instance)
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

    store.state.signinTrigger.subscribeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] in
        guard let _self = self else { return }
        guard _self.session == nil else { return }

        let service = OAuthService()
        _self.session = SFAuthenticationSession(
          url: service.url,
          callbackURLScheme: OAuthService.urlScheme
        ) { [weak self] url, _ in
          guard let _self = self else { return }

          if let url = url, let code = service.process(url: url) {

            Authentication
              .apply(code: code)
              .subscribe(
                onSuccess: { _ in
                  Dispatcher.shared.dispatch(
                    action: AppRootViewModel.Action.show(
                      message: .success(message: "ログインしました")))
                  _self.session = nil
                  AnalyticsService.log(event: .signin(sucess: true))
                },
                onError: { _ in
                  _self.session = nil
                  AnalyticsService.log(event: .signin(sucess: false))
                }
              ).disposed(by: _self.disposeBag)
          } else {
            _self.session = nil
          }
        }
        _self.session?.start()

      }).disposed(by: self.disposeBag)

    store.state.resetTrigger.subscribe(onNext: { [weak self] in
      let alert = UIAlertController(
        title: "キャッシュ削除",
        message: "キャッシュを削除してアプリケーションをリスタートしますか?",
        preferredStyle: .alert
      )
      let ok = UIAlertAction(title: "OK", style: .default, handler: { _ in
        self?.onRestart()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: { [weak self] in
          try? MINQDatabase.refresh()
          self?.onStart()
        })
      })
      let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
      alert.addAction(ok)
      alert.addAction(cancel)
      self?.present(alert, animated: true, completion: nil)
    }).disposed(by: self.disposeBag)
  }
}

// MARK: - Debugメニュー
extension AppRootViewController {

#if DEBUG
  open override func motionBegan(_ motion: UIEventSubtype, with event: UIEvent?) {
    guard motion == .motionShake else {
      return
    }

    let vc = StoryboardScene.Debug.initialScene.instantiate()
    vc.modalPresentationStyle = .overCurrentContext
    self.present(vc, animated: true, completion: nil)
  }
#endif
}
