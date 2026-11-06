//
//  AppDelegate.swift
//  Gravity Putt iOS
//
//  Created by Andrew Finke on 3/13/20.
//  Copyright © 2020 Andrew Finke. All rights reserved.
//

import UIKit
#if !targetEnvironment(simulator)
import FirebaseCore
#endif

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        #if DEBUG
        if UserDefaults.standard.bool(forKey: "FASTLANE_SNAPSHOT") {
            guard let url = Bundle.main.url(forResource: "fastlane_scene_data", withExtension: nil), let data = try? Data(contentsOf: url) else { fatalError() }
            
            SaveUtility.fastlaneSave(data: data)
        }
        #endif
        
        #if !targetEnvironment(simulator)
        FirebaseApp.configure()
        #endif
        
        return true
    }

    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let configuration = UISceneConfiguration(name: "Game", sessionRole: connectingSceneSession.role)
        configuration.delegateClass = SceneDelegate.self
        return configuration
    }
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = GameViewController()
        self.window = window
        window.makeKeyAndVisible()
    }
}
