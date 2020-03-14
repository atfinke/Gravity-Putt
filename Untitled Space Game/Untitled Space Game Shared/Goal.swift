//
//  Goal.swift
//  Untitled Space Game
//
//  Created by Andrew Finke on 3/13/20.
//  Copyright © 2020 Andrew Finke. All rights reserved.
//

import SpriteKit

class Goal: SKSpriteNode {

     let gravityField: SKFieldNode = {
           let field = SKFieldNode.radialGravityField()
           field.strength = 40
           field.categoryBitMask = SpriteCategory.player
           return field
       }()
    
    let innerGravityField: SKFieldNode = {
              let field = SKFieldNode.radialGravityField()
              field.strength = 10
        field.isExclusive = true
        
              field.categoryBitMask = SpriteCategory.player
              return field
          }()
          
    
       
       init(radius: CGFloat, color: SKColor) {
           super.init(texture: nil, color: .clear, size: CGSize(width: radius * 2, height: radius * 2))
           
        gravityField.region = SKRegion(radius: Float(radius * 4))
        innerGravityField.region = SKRegion(radius: Float(radius * 3))
        
        let _border = SKShapeNode(circleOfRadius: radius)
        guard let dashed = _border.path?.copy(dashingWithPhase: 0, lengths: [12, 12]) else {
            fatalError()
        }
        addChild(gravityField)
        addChild(innerGravityField)

        let border = SKShapeNode(path: dashed)
        border.fillColor = .yellow
        border.strokeColor = .yellow
        border.lineWidth = 6
        addChild(border)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
