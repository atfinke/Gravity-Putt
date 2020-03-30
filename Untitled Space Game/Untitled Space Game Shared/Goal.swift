//
//  Goal.swift
//  Untitled Space Game
//
//  Created by Andrew Finke on 3/13/20.
//  Copyright © 2020 Andrew Finke. All rights reserved.
//

import SpriteKit

class Goal: SKSpriteNode {
    
    // MARK: - Properties -
    
    let border: SKShapeNode
    let innerBorder: SKShapeNode
    
    let gravityField: SKFieldNode = {
        let field = SKFieldNode.radialGravityField()
        field.strength = 2
        field.categoryBitMask = SpriteCategory.player
        return field
    }()
    
    // MARK: - Initalization -
    
    init(radius: CGFloat, color: SKColor, levelNumber: Int) {
        let outerRadius: CGFloat = radius
        let innerRadius = outerRadius - 10
        
        let borderPath = CGMutablePath()
        borderPath.move(to: .zero)
        
        let dashes: CGFloat = 4
        let offset = CGFloat.pi / dashes / 2
        for i in 0..<Int(dashes * 3) {
            let angle = CGFloat.pi / dashes * CGFloat(2 * i) - offset
            let newAngle = CGFloat.pi / dashes * CGFloat(2 * i + 1) - offset
            
            let start = CGPoint(x: innerRadius * cos(angle), y: innerRadius * sin(angle))
             
            borderPath.move(to: start)
            borderPath.addArc(center: .zero,
                       radius: innerRadius,
                       startAngle: angle,
                       endAngle: newAngle,
                       clockwise: false)
            
            borderPath.addLine(to: CGPoint(x: outerRadius * cos(newAngle), y: outerRadius * sin(newAngle)))
            borderPath.addArc(center: .zero,
            radius: outerRadius,
            startAngle: newAngle,
            endAngle: angle,
            clockwise: true)
            borderPath.addLine(to: start)
        }

        border = SKShapeNode(path: borderPath)
        border.fillColor = .black
        border.strokeColor = SKColor.green.withAlphaComponent(0.5)
        border.lineWidth = 2
        
        innerBorder = SKShapeNode(circleOfRadius: radius / 2)
                innerBorder.strokeColor = .clear
        innerBorder.fillColor = SKColor(white: 0.1, alpha: 1.0)
                
        
        let label = SKLabelNode(text: levelNumber.description)
                label.fontName = "SF Mono Bold"
                label.horizontalAlignmentMode = .center
                label.verticalAlignmentMode = .center
                label.fontSize = 15
        //        label.position = CGPoint(x: -label.frame.width / 2, y: -label.frame.height / 2)
                label.fontColor = SKColor.white
//                label.zRotation = CGFloat.pi / dashes / 2
                
                innerBorder.addChild(label)
                
                
        
        
        super.init(texture: nil, color: .clear, size: CGSize(width: radius * 2, height: radius * 2))
        addChild(innerBorder)
        gravityField.minimumRadius = Float(radius)
        gravityField.region = SKRegion(radius: Float(radius * 4))
        addChild(gravityField)
        addChild(border)
        
        let body = SKPhysicsBody(circleOfRadius: radius)
        body.contactTestBitMask = SpriteCategory.player
        body.collisionBitMask = SpriteCategory.none
        body.categoryBitMask = SpriteCategory.none
        body.isDynamic = false
        physicsBody = body
        
        let action: SKAction = .repeatForever(.sequence([
            .rotate(byAngle: -CGFloat.pi, duration: 30),
        ]))
        action.timingMode = .easeInEaseOut
        
        border.run(action)

//        
        

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers -
    
    func update(color: SKColor) {
//        border.fillColor = color
//        border.strokeColor = color
    }
}

extension SKColor {
    func lerp(color: SKColor, percent: CGFloat) -> SKColor {
        #if os(macOS)
        let ir = redComponent
        let ig = greenComponent
        let ib = blueComponent
        let fr = color.redComponent
        let fg = color.greenComponent
        let fb = color.blueComponent
        #else
        var ir: CGFloat = 0
        var ig: CGFloat = 0
        var ib: CGFloat = 0
        getRed(&ir, green: &ig, blue: &ib, alpha: nil)
        var fr: CGFloat = 0
        var fg: CGFloat = 0
        var fb: CGFloat = 0
        getRed(&fr, green: &fg, blue: &fb, alpha: nil)
        #endif
        
        return SKColor(red: ir + (fr - ir) * percent,
        green: ig + (fg - ig) * percent,
        blue: ib + (fb - ib) * percent,
        alpha: 1)
    }
}
