//
//  AnalyticsUtility.swift
//  Gravity Putt
//
//  Created by Andrew Finke on 4/14/20.
//  Copyright © 2020 Andrew Finke. All rights reserved.
//

import Foundation

#if os(iOS)
import Firebase
import FirebaseAnalytics
#else
import AppCenterAnalytics
#endif

class AnalyticsUtility {
    
    static let shared = AnalyticsUtility()
    private let queue = DispatchQueue(label: "com.andrewfinke.space.golf.analytics", qos: .utility)
    private var queued = [(event: String, parameters: [String: String]?)]()
    
    private init() {
        Timer.scheduledTimer(withTimeInterval: 20, repeats: true, block: {_ in
            self.flushQueue()
        })
    }
    
    func flushQueue() {
        self.queue.async {
            for item in self.queued {
                #if os(iOS)
                Analytics.logEvent(item.event, parameters: item.parameters)
                #else
                MSAnalytics.trackEvent(item.event, withProperties: item.parameters)
                #endif
            }
            self.queued = []
        }
    }
    
    func queue(event: String, parameters: [String: String]?) {
        queue.async {
            self.queued.append((event, parameters))
        }
    }
}
