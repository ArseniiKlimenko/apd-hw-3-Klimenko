import UIKit

@main
final class StudentDirectoryApp: UIResponder, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // R-30: a scene session saved by a build without a delegate class is
        // restored without calling configurationForConnecting below, so the
        // scene comes back without SceneDelegate and the app shows nothing.
        // Give such a scene a SceneDelegate when it connects.
        NotificationCenter.default.addObserver(forName: UIScene.willConnectNotification, object: nil, queue: .main) { notification in
            MainActor.assumeIsolated {
                guard let scene = notification.object as? UIWindowScene, scene.delegate == nil else { return }
                let sceneDelegate = SceneDelegate()
                scene.delegate = sceneDelegate
                sceneDelegate.connect(scene)
            }
        }
        return true
    }

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let configuration = UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
        // R-25: the generated Info.plist has no scene configuration, so without
        // this line SceneDelegate is never created and the app has no window.
        configuration.delegateClass = SceneDelegate.self
        return configuration
    }
}
