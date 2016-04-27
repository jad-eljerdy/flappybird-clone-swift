//
//  MainMenuScene.swift
//  Flappy Bird Clone
//
//  Created by Jad El Jerdy on 6/9/14.
//  Copyright (c) 2014 jadeljerdy. All rights reserved.
//

import Foundation
import SpriteKit
import AVFoundation

class MainMenuScene: SKScene{
    
    let kPipeGap = 160*3.0
    let birdCategory = UInt32(1 << 0)
    let worldCategory = UInt32(1 << 1)
    let pipeCategory = UInt32(1 << 2)
    let scoreCategory = UInt32(1 << 3)
    let originalSkyColor = UIColor(red: 79/255, green: 191/255, blue: 201/255, alpha: 1.0)
    
    var startSprite:SKSpriteNode!
    var bird:SKSpriteNode!
    var firstPipeTexture:SKTexture!
    var secondPipeTexture:SKTexture!
    var moveThenRemovePipes:SKAction!
    var gameRunning:SKNode!
    var pipes:SKNode!
    var isRestartApplicable:Bool!
    var scoreLabelNode:SKLabelNode!
    var scoreLabelNodeShadow:SKLabelNode!
    var score = 0
    var dieSound = SKAction.playSoundFileNamed("sfx_die.mp3", waitForCompletion: false)
    var hitSound = SKAction.playSoundFileNamed("sfx_hit.mp3", waitForCompletion: false)
    var pointSound = SKAction.playSoundFileNamed("sfx_point.mp3", waitForCompletion: false)
    var swooshingSound = SKAction.playSoundFileNamed("sfx_swooshing.mp3", waitForCompletion: false)
    var wingSound = SKAction.playSoundFileNamed("sfx_wing.mp3", waitForCompletion: false)
    
    var birdAutopilot = SKAction()
    var birdAction = SKAction()
    var muteAll = false
    var shouldStart = false
    var birdFlightTextures = NSArray()
    var mainMenuNode = "provisional"
    
    override init(size: CGSize) {
        super.init(size: size)
        self.size = size
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        self.backgroundColor = self.originalSkyColor
        
        
        let landWidth = 336
        let landHeight = 112
        let land = SKTexture(imageNamed:"land.png")
        land.filteringMode = SKTextureFilteringMode.Nearest
        let landTilingBounds = 3 + NSInteger(self.frame.size.width) / NSInteger(landWidth*2)
        
        let moveLand = SKAction.moveByX(CGFloat(-landWidth)*2, y: 0, duration: Double(0.01 * CGFloat(landWidth)*2))
        let resetLand = SKAction.moveByX(CGFloat(landWidth)*2, y: 0, duration: 0)
        let moveLandForever = SKAction.repeatActionForever(SKAction.sequence([moveLand,resetLand]))
        
        
        for index in 0...landTilingBounds
        {
            let sprite = SKSpriteNode(texture: land)
            sprite.position = CGPoint(x:CGFloat(index) * CGFloat(sprite.size.width), y:CGFloat(sprite.size.height) / 2)
            sprite.zPosition = -50
            sprite.runAction(moveLandForever)
            self.addChild(sprite)
        }
        
        
        let skyWidth = 276
//        let skyHeight = 109
        let sky = SKTexture(imageNamed:"sky.png")
        sky.filteringMode = SKTextureFilteringMode.Nearest
        let skyTilingBounds = 4 + NSInteger(self.frame.size.width) / NSInteger(skyWidth*2)
        
        let moveSky = SKAction.moveByX(CGFloat(-skyWidth)*2, y: 0, duration: Double(0.05 * CGFloat(skyWidth)*2))
        let resetSky = SKAction.moveByX(CGFloat(skyWidth)*2, y: 0, duration: 0)
        let moveSkyForever = SKAction.repeatActionForever(SKAction.sequence([moveSky,resetSky]))
        
        for index in 0...skyTilingBounds
        {
            let sprite = SKSpriteNode(texture: sky)
            sprite.position = CGPoint(x:CGFloat(index) * CGFloat(sprite.size.width), y:CGFloat(sprite.size.height) / 2 + CGFloat(landHeight))
            sprite.zPosition = -80
            sprite.runAction(moveSkyForever)
            self.addChild(sprite)
        }
        
        
        
        //let birdSize = CGSize(width: 32, height: 24)
        let birdAtlas = SKTextureAtlas(named: "bird.atlas")
        let bird1 = birdAtlas.textureNamed("bird01.png")
        let bird2 = birdAtlas.textureNamed("bird02.png")
        let bird3 = birdAtlas.textureNamed("bird03.png")
        birdFlightTextures = NSArray(objects: bird1,bird2,bird3)
        
        bird = SKSpriteNode(texture: (birdFlightTextures.objectAtIndex(0) as! SKTexture))
        bird.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)+15)
        bird.zPosition = -60
        bird.setScale(1)
        
        let autoPilotAnim = SKAction.repeatActionForever(SKAction.sequence([SKAction.moveToY(bird.position.y-15, duration: 0.4), SKAction.moveToY(bird.position.y, duration: 0.4)]))
        autoPilotAnim.timingMode = SKActionTimingMode.EaseIn;
        bird.runAction(autoPilotAnim, withKey:"initialanim")
        
        
        self.addChild(bird)
        
        birdAction = SKAction.animateWithTextures(birdFlightTextures as! [SKTexture], timePerFrame: 0.1)
        bird.runAction(SKAction.repeatActionForever(birdAction), withKey:"wingflap")
        
        
        
        let logoTexture = SKTexture(imageNamed:"logo.png")
        logoTexture.filteringMode = SKTextureFilteringMode.Nearest
        
        let logoSprite = SKSpriteNode(texture: logoTexture)
        logoSprite.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame)+70)
        logoSprite.setScale(1)
        logoSprite.alpha = 0
        self.addChild(logoSprite)
        logoSprite.runAction(SKAction.fadeAlphaTo(1, duration: 0.6))
        
        
        let rateTexture = SKTexture(imageNamed:"rate.png")
        rateTexture.filteringMode = SKTextureFilteringMode.Nearest
        
        let rateSprite = SKSpriteNode(texture: rateTexture)
        rateSprite.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame)-50)
        rateSprite.setScale(1)
        rateSprite.alpha = 0
        rateSprite.userInteractionEnabled = false
        rateSprite.name = "ratebutton"
        self.addChild(rateSprite)
        rateSprite.runAction(SKAction.fadeAlphaTo(1, duration: 0.6))
        
        let playTexture = SKTexture(imageNamed:"play.png")
        playTexture.filteringMode = SKTextureFilteringMode.Nearest
        
        let playSprite = SKSpriteNode(texture: playTexture)
        playSprite.position = CGPoint(x:CGRectGetMidX(self.frame)-80, y:CGRectGetMidY(self.frame)-145)
        playSprite.setScale(1)
        playSprite.alpha = 0
        playSprite.userInteractionEnabled = false
        playSprite.name = "playbutton"
        self.addChild(playSprite)
        playSprite.runAction(SKAction.fadeAlphaTo(1, duration: 0.6))
        
        let leadTexture = SKTexture(imageNamed:"leaderboard.png")
        leadTexture.filteringMode = SKTextureFilteringMode.Nearest
        
        let leadSprite = SKSpriteNode(texture: leadTexture)
        leadSprite.position = CGPoint(x:CGRectGetMidX(self.frame)+80, y:CGRectGetMidY(self.frame)-145)
        leadSprite.setScale(1)
        leadSprite.alpha = 0
        leadSprite.userInteractionEnabled = false
        leadSprite.name = "leadbutton"
        self.addChild(leadSprite)
        leadSprite.runAction(SKAction.fadeAlphaTo(1, duration: 0.6))
        
    }
    
    override func touchesBegan(_touches: Set<UITouch>, withEvent event: UIEvent?) {

        /* Called when a touch begins */
        let touch = _touches.first
        
        let location = touch!.locationInNode(self)
        let curNode = self.nodeAtPoint(location)
        
        if curNode.name != nil && curNode.name == "playbutton" {
            
            let animationAction = SKAction.moveToY(curNode.position.y-5, duration:0.02 )
            curNode.runAction(animationAction)
            
            mainMenuNode = "playbutton"
            
        }
        if curNode.name != nil && curNode.name == "leadbutton" {
            
            let animationAction = SKAction.moveToY(curNode.position.y-5, duration:0.02 )
            curNode.runAction(animationAction)
            mainMenuNode = "leadbutton"
        }
        if curNode.name != nil && curNode.name == "ratebutton" {
            
            let animationAction = SKAction.moveToY(curNode.position.y-5, duration:0.02 )
            curNode.runAction(animationAction)
            mainMenuNode = "ratebutton"
        }
    }
    
        override func touchesEnded(_touches: Set<UITouch>, withEvent event: UIEvent?) {
            /* Called when a touch ends */
            let touch = _touches.first

            
            let location = touch!.locationInNode(self)
            let curNode = self.nodeAtPoint(location)

        
        let animationAction = SKAction.moveToY(curNode.position.y+5, duration:0.02 )
        
        if curNode.name != nil && curNode.name == "playbutton" {
            
            
            curNode.runAction(animationAction)
            
            if mainMenuNode == "playbutton" {
                let reveal = SKTransition.fadeWithColor(UIColor.blackColor(), duration: 0.75)
                
                let scene = GameScene(size:self.scene!.size)
                scene.scaleMode = SKSceneScaleMode.AspectFill
                
                self.scene!.view!.presentScene(scene, transition: reveal)
            }
            
        }
        else if curNode.name != nil && curNode.name == "leadbutton" {
            
            curNode.runAction(animationAction)
            
            if mainMenuNode == "leadbutton" {
            }
        }
        else if curNode.name != nil && curNode.name == "ratebutton" {
            
            curNode.runAction(animationAction)
            
            if mainMenuNode == "ratebutton" {
            }
        }
        else {
            if mainMenuNode == "playbutton" {
                //let relativeNode =
            }
            else if mainMenuNode == "leadbutton" {
            }
            else if mainMenuNode == "ratebutton" {
            }
        }
        
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
    }
    
    
}
