//
//  StartupScene.swift
//  Flappy Bird Clone
//
//  Created by Jad El Jerdy on 6/16/14.
//  Copyright (c) 2014 jadeljerdy. All rights reserved.
//

import Foundation
import SpriteKit

class StartupScene :SKScene {
    override func didMoveToView(view: SKView) {
        
        let bgImage = SKTexture(imageNamed: "launchR4.png")
        let bgNode = SKSpriteNode(texture: bgImage)
        bgNode.setScale(0.5)
        bgNode.position = CGPoint(x:160, y:568/2)
        self.addChild(bgNode)
        
        _ = NSTimer.scheduledTimerWithTimeInterval(4.5, target: self, selector: #selector(moveToMainMenu), userInfo: nil, repeats: false)
    }
    
    func moveToMainMenu()
    {
        
        //let reveal = SKTransition.fadeWithColor(UIColor.blackColor(), duration: 0.8)
        let reveal = SKTransition.crossFadeWithDuration(0.8)
        
        let scene = MainMenuScene(size:self.scene!.size)
        scene.scaleMode = SKSceneScaleMode.AspectFill
        
        
        self.scene!.view!.presentScene(scene, transition: reveal)
    }
}