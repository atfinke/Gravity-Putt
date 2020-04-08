//
//  SKCodableColor.swift
//  Untitled Space Game
//
//  Created by Andrew Finke on 4/6/20.
//  Copyright © 2020 Andrew Finke. All rights reserved.
//

import SpriteKit

struct SKCodableColor: Codable {

    // MARK: - Types -

    enum CodingKeys: String, CodingKey {
        case red
        case green
        case blue
        case alpha
    }

    // MARK: - Properties -

    let color: SKColor

    // MARK: - Initalization -

    init(_ color: SKColor) {
        self.color = color
    }

    // MARK: - Codable -

    public func encode(to encoder: Encoder) throws {
        let (r, g, b, a) = color.rgba()
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(r, forKey: .red)
        try container.encode(g, forKey: .green)
        try container.encode(b, forKey: .blue)
        try container.encode(a, forKey: .alpha)
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let r = try values.decode(CGFloat.self, forKey: .red)
        let g = try values.decode(CGFloat.self, forKey: .green)
        let b = try values.decode(CGFloat.self, forKey: .blue)
        let a = try values.decode(CGFloat.self, forKey: .alpha)
        color = SKColor(red: r, green: g, blue: b, alpha: a)
    }
}
