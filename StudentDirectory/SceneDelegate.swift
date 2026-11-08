import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }
        connect(windowScene)
    }

    /// Builds the window; also used for restored scenes without a delegate (R-30).
    func connect(_ windowScene: UIWindowScene) {
        let window = UIWindow(windowScene: windowScene)
        // Composition root: the only StudentStore, injected into every screen.
        let store = StudentStore()
        window.rootViewController = UINavigationController(rootViewController: StudentListViewController(store: store))
        window.makeKeyAndVisible()
        self.window = window
    }
}
