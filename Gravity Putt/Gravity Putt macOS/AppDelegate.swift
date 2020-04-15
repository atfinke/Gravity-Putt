//
//  AppDelegate.swift
//  Gravity Putt macOS
//
//  Created by Andrew Finke on 3/13/20.
//  Copyright © 2020 Andrew Finke. All rights reserved.
//

import Cocoa
import AppCenter
import AppCenterAnalytics
import AppCenterCrashes

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        UserDefaults.standard.register(defaults: ["NSApplicationCrashOnExceptions": true])
        guard let url = Bundle.main.url(forResource: "appcenter", withExtension: "txt"), let app = try? String(contentsOf: url) else { fatalError() }
        MSAppCenter.start(app, withServices: [MSAnalytics.self, MSCrashes.self])
    }


    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

}
