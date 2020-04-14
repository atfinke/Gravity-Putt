//
//  AppDelegate.swift
//  Gravity Putt iOS
//
//  Created by Andrew Finke on 3/13/20.
//  Copyright © 2020 Andrew Finke. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        #if DEBUG
        if UserDefaults.standard.bool(forKey: "FASTLANE_SNAPSHOT") {
            guard let url = Bundle.main.url(forResource: "fastlane_scene_data", withExtension: nil), let data = try? Data(contentsOf: url) else { fatalError() }
            
            SaveUtility.fastlaneSave(data: data)
        }
        #endif
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        let controller = GameViewController()
        window.rootViewController = controller
        window.makeKeyAndVisible()
        self.window = window
        
        FirebaseApp.configure()
        
        return true
    }

}
