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

struct AnalyticsUtility {
    
    static func log(event: String, parameters: [String: String]?) {
        #if os(iOS)
        Analytics.logEvent(event, parameters: parameters)
        #else
        MSAnalytics.trackEvent(event, withProperties: parameters)
        #endif
    }
}
