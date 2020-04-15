//
//  UnlockLevelsNode.swift
//  Gravity Putt
//
//  Created by Andrew Finke on 4/13/20.
//  Copyright © 2020 Andrew Finke. All rights reserved.
//

import SpriteKit

class UnlockLevelsNode: SKNode {
    
    // MARK: - Properties -
    
    let background = SKShapeNode(rectOf: CGSize(width: 500, height: 150), cornerRadius: 20)
    let backgroundLabel = SKLabelNode()
    let button = SKShapeNode(rectOf: CGSize(width: 110, height: 60), cornerRadius: 10)
    let buttonLabel = SKLabelNode()
    let restoreButton = SKShapeNode(rectOf: CGSize(width: 110, height: 60), cornerRadius: 10)
    let restoreButtonLabel = SKLabelNode()
    
    // MARK: - Initalization -
    
    override init() {
        super.init()
        
        background.lineWidth = 4
        background.position = CGPoint(x: 0, y: 60)
        background.fillColor = SKColor.black.withAlphaComponent(0.85)
        background.strokeColor = SKColor.white
        addChild(background)
        
        backgroundLabel.numberOfLines = 5
        backgroundLabel.verticalAlignmentMode = .center
        backgroundLabel.horizontalAlignmentMode = .center
        let text = NSAttributedString.stylized(string: "Thanks for playing the first 18!\n\nPlease consider unlocking\nunlimited levels to keep playing.",
                                               size: 22,
                                               weight: .semibold)
        let mutableText = NSMutableAttributedString(attributedString: text)
        
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        mutableText.addAttribute(.paragraphStyle, value: style, range: NSRange(location: 0, length: text.length))
        backgroundLabel.attributedText = mutableText
        
        background.addChild(backgroundLabel)
        
        button.lineWidth = 3
        button.fillColor = SKColor.purple.withAlphaComponent(0.9)
        button.strokeColor = SKColor.white
        button.position = CGPoint(x: 0, y: background.frame.minY - 50)
        addChild(button)
        
        buttonLabel.verticalAlignmentMode = .center
        buttonLabel.horizontalAlignmentMode = .center
        button.addChild(buttonLabel)
        
        restoreButton.lineWidth = 3
        restoreButton.fillColor = SKColor.red.withAlphaComponent(0.6)
        restoreButton.strokeColor = SKColor.white
        restoreButton.position = CGPoint(x: 0, y: button.frame.minY - 50)
        addChild(restoreButton)
        
        restoreButtonLabel.verticalAlignmentMode = .center
        restoreButtonLabel.horizontalAlignmentMode = .center
        restoreButtonLabel.attributedText = NSAttributedString.stylized(string: "Restore",
                                                                        size: 18,
                                                                        weight: .medium)
        restoreButton.addChild(restoreButtonLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers -
    
    func updatePrice() {
        let price = UserDefaults.standard.string(forKey: "unlockLevelsProductPrice") ?? "N/A"
        buttonLabel.attributedText = NSAttributedString.stylized(string: price,
                                                                 size: 22,
                                                                 weight: .semibold)
    }
}
