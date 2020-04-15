//
//  AppDelegate.swift
//  Gravity Putt tvOS
//
//  Created by Andrew Finke on 3/13/20.
//  Copyright © 2020 Andrew Finke. All rights reserved.
//

import UIKit
import AppCenter
import AppCenterAnalytics
import AppCenterCrashes

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        guard let url = Bundle.main.url(forResource: "appcenter", withExtension: "txt"), let app = try? String(contentsOf: url) else { fatalError() }
        MSAppCenter.start(app, withServices: [MSAnalytics.self, MSCrashes.self])
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        let controller = GameViewController()
        window.rootViewController = controller
        window.makeKeyAndVisible()
        self.window = window
        return true
    }

}
