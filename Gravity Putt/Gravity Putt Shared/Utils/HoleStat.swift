//
//  HoleStat.swift
//  Gravity Putt
//
//  Created by Andrew Finke on 4/8/20.
//  Copyright © 2020 Andrew Finke. All rights reserved.
//

import Foundation

struct HoleStat: Codable, Equatable {
    let n: Int // number (name is written to json for every object, keep short)
    let d: Int // duration
    let s: Int // strokes
    
    var number: Int {
        return n
    }
    var duration: Int {
        return d
    }
    var strokes: Int {
        return s
    }
}
