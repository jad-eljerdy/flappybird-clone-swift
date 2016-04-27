//
//  GameScene.swift
//  Flappy Bird Clone
//
//  Created by Jad El Jerdy on 6/5/14.
//  Copyright (c) 2014 jadeljerdy. All rights reserved.
//

import SpriteKit
import AVFoundation

class GameScene: SKScene,SKPhysicsContactDelegate{
    
    
    let kScale = CGFloat(1.0)
    var kPipeGap = CGFloat(115)
    let birdCategory = UInt32(1 << 0)
    let worldCategory = UInt32(1 << 1)
    let pipeCategory = UInt32(1 << 2)
    let scoreCategory = UInt32(1 << 3)
    let originalSkyColor = UIColor(red: 79/255, green: 191/255, blue: 201/255, alpha: 1.0)
    
    var startSprite = SKSpriteNode()
    var bird = SKSpriteNode()
    var firstPipeTexture = SKTexture()
    var secondPipeTexture = SKTexture()
    var moveThenRemovePipes = SKAction()
    var gameRunning = SKNode()
    var pipes = SKNode()
    var isRestartApplicable = false
    var scoreLabelNode = SKLabelNode()
    var scoreLabelNodeShadow = SKLabelNode()
    var score = 0
    
    var dieSound = SKAction()
    var hitSound = SKAction()
    var pointSound = SKAction()
    var swooshingSound = SKAction()
    var wingSound = SKAction()
    
    var birdAction = SKAction()
    var muteAll = false
    var shouldStart = false
    var birdFlightTextures = NSArray()
    
    var gameOver = SKNode()
    var gameOverOverlay = SKNode()
    var gameOverPlayButton = SKNode()
    var gameOverLeaderButton = SKNode()
    var mainMenuNode = "provisional"
    
    
    
    override init(size: CGSize) {
        super.init(size: size)
        self.size = size
        kPipeGap = kPipeGap * CGFloat(kScale)
        
        wingSound = SKAction.playSoundFileNamed("sfx_wing.mp3", waitForCompletion: false)
        dieSound = SKAction.playSoundFileNamed("sfx_die.mp3", waitForCompletion: false)
        hitSound = SKAction.playSoundFileNamed("sfx_hit.mp3", waitForCompletion: false)
        pointSound = SKAction.playSoundFileNamed("sfx_point.mp3", waitForCompletion: false)
        swooshingSound = SKAction.playSoundFileNamed("sfx_swooshing.mp3", waitForCompletion: false)
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToView(view: SKView) {
        
        /* Setup your scene here */
        
        
        self.physicsWorld.contactDelegate = self
        
        self.isRestartApplicable = false
        
        self.physicsWorld.gravity = CGVectorMake( 0.0, 0.0 )
        
        self.backgroundColor = self.originalSkyColor
        
        self.gameRunning = SKNode()
        self.addChild(gameRunning)
        
        self.pipes = SKNode()
        self.gameRunning.addChild(pipes)
        
        //muteAll = true
        
        
        let startTexture = SKTexture(imageNamed:"splash.png")
        startTexture.filteringMode = SKTextureFilteringMode.Nearest
        
        startSprite = SKSpriteNode(texture: startTexture)
        startSprite.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame)+70)
        startSprite.setScale(1)
        startSprite.alpha = 0
        self.addChild(startSprite)
        startSprite.runAction(SKAction.fadeAlphaTo(1, duration: 0.6))
        
        let landWidth = 336*1
        let landHeight = 112*1
        let land = SKTexture(imageNamed:"land")
        land.filteringMode = SKTextureFilteringMode.Nearest
        let landTilingBounds = 3 + NSInteger(self.frame.size.width) / NSInteger(landWidth*2)
        
        let moveLand = SKAction.moveByX(CGFloat(-landWidth)*2, y: 0, duration:Double( 0.01 * CGFloat(landWidth)*1))
        let resetLand = SKAction.moveByX(CGFloat(landWidth)*2, y: 0, duration: 0)
        let moveLandForever = SKAction.repeatActionForever(SKAction.sequence([moveLand,resetLand]))
        
        
        for index in 0...landTilingBounds
        {
            let sprite = SKSpriteNode(texture: land)
            sprite.setScale(1)
            sprite.position = CGPoint(x:CGFloat(index) * CGFloat(sprite.size.width), y:CGFloat(sprite.size.height) / 2)
            sprite.zPosition = -50
            sprite.runAction(moveLandForever)
            self.gameRunning.addChild(sprite)
        }
        
        
        let skyWidth = 276*1
        let _ = 109*1
        let sky = SKTexture(imageNamed:"sky.png")
        sky.filteringMode = SKTextureFilteringMode.Nearest
        let skyTilingBounds = 4 + NSInteger(self.frame.size.width) / NSInteger(skyWidth*2)
        
        let moveSky = SKAction.moveByX(CGFloat(-skyWidth)*2, y: 0, duration:Double( 0.05 * CGFloat(skyWidth)*2))
        let resetSky = SKAction.moveByX(CGFloat(skyWidth)*2, y: 0, duration: 0)
        let moveSkyForever = SKAction.repeatActionForever(SKAction.sequence([moveSky,resetSky]))
        
        for index in 0...skyTilingBounds
        {
            let sprite = SKSpriteNode(texture: sky)
            sprite.setScale(1)
            sprite.position = CGPoint(x:CGFloat(index) * CGFloat(sprite.size.width), y:CGFloat(sprite.size.height) / 2 + CGFloat(landHeight))
            sprite.zPosition = -80
            sprite.runAction(moveSkyForever)
            self.gameRunning.addChild(sprite)
        }
        
        let dummyLand = SKNode()
        dummyLand.position = CGPointMake(0, CGFloat(landHeight)/2+5)
        dummyLand.zPosition = -6
        dummyLand.physicsBody = SKPhysicsBody(rectangleOfSize:CGSizeMake(self.frame.size.width * CGFloat(kScale), CGFloat(landHeight)) )
        dummyLand.physicsBody!.dynamic = false
        dummyLand.physicsBody!.categoryBitMask = worldCategory
        
        self.addChild(dummyLand)
        
        let birdSize = CGSize(width: 32, height: 24)
        let birdAtlas = SKTextureAtlas(named: "bird.atlas")
        let bird1 = birdAtlas.textureNamed("bird01.png")
        let bird2 = birdAtlas.textureNamed("bird02.png")
        let bird3 = birdAtlas.textureNamed("bird03.png")
        birdFlightTextures = NSArray(objects: bird1,bird2,bird3)
        
        bird = SKSpriteNode(texture: (birdFlightTextures.objectAtIndex(0) as! SKTexture))
        bird.position = CGPointMake(CGRectGetMidX(self.frame)-100, CGRectGetMidY(self.frame)+70)
        bird.zPosition = -60
        bird.setScale(1)
        bird.physicsBody = SKPhysicsBody(circleOfRadius: birdSize.height/2)
        bird.physicsBody!.dynamic = true
        bird.physicsBody!.categoryBitMask = birdCategory
        bird.physicsBody!.collisionBitMask = worldCategory | pipeCategory
        bird.physicsBody!.contactTestBitMask = worldCategory | pipeCategory
        
        let autoPilotAnim = SKAction.repeatActionForever(SKAction.sequence([SKAction.moveToY(bird.position.y-15, duration: 0.4), SKAction.moveToY(bird.position.y, duration: 0.4)]))
        autoPilotAnim.timingMode = SKActionTimingMode.EaseIn;
        bird.runAction(autoPilotAnim, withKey:"initialanim")
        
        
        self.addChild(bird)
        
        birdAction = SKAction.animateWithTextures(birdFlightTextures as! [SKTexture], timePerFrame: 0.1)
        bird.runAction(SKAction.repeatActionForever(birdAction), withKey:"wingflap")
        
        let pipeSize = CGSizeMake(30,160)
        firstPipeTexture = SKTexture(imageNamed:"pipe2.png")
        firstPipeTexture.filteringMode = SKTextureFilteringMode.Nearest
        secondPipeTexture = SKTexture(imageNamed:"pipe1.png")
        secondPipeTexture.filteringMode = SKTextureFilteringMode.Nearest
        
        
        let distanceToMove = self.frame.size.width + 2 * pipeSize.width * CGFloat(kScale)
        let movePipes = SKAction.repeatActionForever(SKAction.moveByX(-distanceToMove, y: 0, duration: 0.005 * Double(distanceToMove)))
        let removePipes = SKAction.removeFromParent()
        moveThenRemovePipes = SKAction.sequence([movePipes, removePipes])
        
        
        let spawn = SKAction.runBlock({() in self.spawnPipe()})
        let delay = SKAction.waitForDuration(NSTimeInterval(0.85))
        let spawnThenDelay = SKAction.sequence([spawn, delay])
        let spawnThenDelayForever = SKAction.repeatActionForever(spawnThenDelay)
        self.runAction(spawnThenDelayForever)
        
        score = 0
        scoreLabelNode = SKLabelNode(fontNamed: "04b_19")
        scoreLabelNode.position = CGPointMake( CGRectGetMidX( self.frame ), (3 * self.frame.size.height / 4)+50 )
        scoreLabelNode.zPosition = 100
        scoreLabelNode.text = NSString(format: "%d", score) as String
        scoreLabelNode.fontSize = 55
        scoreLabelNode.alpha = 0
        scoreLabelNodeShadow = SKLabelNode(fontNamed: "04b_19")
        scoreLabelNodeShadow.position = CGPointMake( CGRectGetMidX( self.frame )+3.5, ((3 * self.frame.size.height / 4)+50)-3)
        scoreLabelNodeShadow.zPosition = 98
        scoreLabelNodeShadow.text = NSString(format: "%d", score) as String
        scoreLabelNodeShadow.fontColor = UIColor.blackColor()
        scoreLabelNodeShadow.fontSize = 55
        scoreLabelNodeShadow.alpha = 0
        self.addChild(scoreLabelNodeShadow)
        self.addChild(scoreLabelNode)
        
    }
    
    func spawnPipe(){
        if(shouldStart)
        {
            let pipeSize = CGSizeMake(52,320)
            let theTwoPipes = SKNode()
            theTwoPipes.position = CGPointMake(self.frame.size.width + pipeSize.width, 0)
            theTwoPipes.zPosition = -60
            
            let y = CGFloat(arc4random()) % CGFloat((NSInteger)( self.frame.size.height / 3 ))
            
            let firstPipe = SKSpriteNode(texture: firstPipeTexture)
            firstPipe.setScale(kScale)
            firstPipe.position = CGPointMake(0,y)
            firstPipe.zPosition = -7
            firstPipe.physicsBody = SKPhysicsBody(rectangleOfSize:CGSizeMake(CGFloat(pipeSize.width)*kScale,CGFloat(pipeSize.height)*kScale))
            firstPipe.physicsBody!.dynamic = false
            firstPipe.physicsBody!.categoryBitMask = pipeCategory
            firstPipe.physicsBody!.contactTestBitMask = birdCategory
            theTwoPipes.addChild(firstPipe)
            
            
            let secondPipe = SKSpriteNode(texture: secondPipeTexture)
            secondPipe.setScale(kScale)
            secondPipe.position = CGPointMake(0, CGFloat(y) + CGFloat(pipeSize.height) + CGFloat(kPipeGap))
            secondPipe.zPosition = -7
            secondPipe.physicsBody = SKPhysicsBody(rectangleOfSize:CGSizeMake(CGFloat(pipeSize.width)*kScale,CGFloat(pipeSize.height)*kScale))
            secondPipe.physicsBody!.dynamic = false
            secondPipe.physicsBody!.categoryBitMask = pipeCategory
            secondPipe.physicsBody!.contactTestBitMask = birdCategory
            theTwoPipes.addChild(secondPipe)
            
            let contactNode = SKNode()
            contactNode.position = CGPointMake(firstPipe.size.width/2, CGRectGetMidY(self.frame))
            contactNode.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake( secondPipe.size.width, self.frame.size.height ))
            contactNode.physicsBody!.dynamic = false
            contactNode.physicsBody!.categoryBitMask = scoreCategory
            contactNode.physicsBody!.collisionBitMask = 0
            contactNode.physicsBody!.contactTestBitMask = birdCategory
            theTwoPipes.addChild(contactNode)
            
            self.pipes.addChild(theTwoPipes)
            
            theTwoPipes.runAction(moveThenRemovePipes)
        }
        
        
    }
    
    override func touchesBegan(_touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
        
        if(!shouldStart) {
            shouldStart = true
            
            
            startSprite.runAction(SKAction.fadeAlphaTo(0, duration: 0.6))
            self.physicsWorld.gravity = CGVectorMake( 0.0, -9.8 )
            
            bird.removeActionForKey("initialanim")
            
            bird.removeActionForKey("wingflap")
            birdAction = SKAction.animateWithTextures(birdFlightTextures as! [SKTexture], timePerFrame: 0.05)
            bird.runAction(SKAction.repeatActionForever(birdAction), withKey:"wingflap")
            
            self.scoreLabelNode.runAction(SKAction.fadeAlphaTo(1, duration: 0.1))
            self.scoreLabelNodeShadow.runAction(SKAction.fadeAlphaTo(1, duration: 0.1))
        }
        
        if self.gameRunning.speed > 0 {
            
            if !muteAll{ self.runAction(wingSound) }
            
            bird.physicsBody!.velocity = CGVectorMake(0,0)
            bird.physicsBody!.angularVelocity = 0
            bird.zRotation = 0
            bird.physicsBody!.applyImpulse(CGVectorMake(0,9))
            bird.physicsBody!.applyAngularImpulse(0.00004)
        }
        else
        {
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
        /*else if self.isRestartApplicable {
        self.resetGame()
        }*/
        
        
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
    
    func autoPilotRun() {
        bird.physicsBody!.velocity = CGVectorMake(0,0)
        bird.physicsBody!.angularVelocity = 0
        bird.zRotation = 0
        bird.physicsBody!.applyImpulse(CGVectorMake(0,5))
        bird.physicsBody!.applyAngularImpulse(0.00005)
    }
    
    func preventLargeRotationsOnBird(min min: CGFloat, max: CGFloat, value:CGFloat) -> CGFloat {
        
        if value > max { return max } else if value < min { return min } else { return value }
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        if self.gameRunning.speed > 0 {
            bird.zRotation = self.preventLargeRotationsOnBird(min: -1, max: 0.3, value: bird.physicsBody!.velocity.dy * ( bird.physicsBody!.velocity.dy < 0 ? 0.003 : 0.001 ) )
        }
        else {
            bird.physicsBody!.angularVelocity = 0
            if bird.zRotation <= CGFloat(-M_PI/2) {
                bird.zRotation = CGFloat(-M_PI/2)
            }
        }
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        // Flash background if contact is detected
        if self.gameRunning.speed > 0 {
            if (contact.bodyA.categoryBitMask & scoreCategory ) == scoreCategory || ( contact.bodyB.categoryBitMask & scoreCategory ) == scoreCategory {
                // Bird has contact with score entity
                if !muteAll{ self.runAction(pointSound) }
                self.score += self.score + 1
                self.scoreLabelNode.text = NSString(format:"%d", self.score) as String
                self.scoreLabelNodeShadow.text = NSString(format:"%d", self.score)  as String
            }
                
            else {
                
                self.scoreLabelNode.runAction(SKAction.fadeAlphaTo(0, duration: 0.3))
                self.scoreLabelNodeShadow.runAction(SKAction.fadeAlphaTo(0, duration: 0.3))
                self.operateOnScore(self.score)
                
                if !muteAll{ self.runAction(hitSound) }
                bird.physicsBody!.collisionBitMask = worldCategory
                bird.runAction( SKAction.rotateToAngle( CGFloat(-M_PI/2), duration: Double(bird.position.y) * 0.0008))
                
                
                if !muteAll{ self.runAction(dieSound) }
                self.gameRunning.speed = 0
                
                //TODO: Stop bird wings animations
                
                self.removeActionForKey("bgflash")
                self.runAction(
                    SKAction.sequence([
                        SKAction.runBlock({ self.backgroundColor = SKColor.whiteColor()}),
                        SKAction.waitForDuration(0.1),
                        SKAction.runBlock({
                            self.backgroundColor = self.originalSkyColor
                            self.isRestartApplicable = true
                            })])
                    ,withKey:"bgflash")
                
                //Initialize game over assets
                let gameOverTexture = SKTexture(imageNamed: "gameover.png")
                gameOver = SKSpriteNode(texture: gameOverTexture)
                gameOver.setScale(1)
                gameOver.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)+130)
                self.addChild(gameOver)
            
                
                
                
                gameOver.runAction(SKAction.sequence([SKAction.moveToY(gameOver.position.y+10, duration: 0.1),SKAction.moveToY(gameOver.position.y, duration: 0.1), SKAction.waitForDuration(0.4)]), completion: {
                    
                    let gameOverOverlayTexture = SKTexture(imageNamed: "gameoverbg.png")
                    self.gameOverOverlay = SKSpriteNode(texture: gameOverOverlayTexture)
                    self.gameOverOverlay.setScale(1)
                    self.gameOverOverlay.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)-0 - 300)
                    self.addChild(self.gameOverOverlay)
                    
                    let scoreFinalText = SKLabelNode(fontNamed: "04b_19")
                    scoreFinalText.fontSize = 26
                    scoreFinalText.position = CGPointMake( CGRectGetMidX( self.frame )+90,CGRectGetMidY( self.frame )+5 - 300)
                    scoreFinalText.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Right
                    scoreFinalText.text = NSString(format: "%d", self.score) as String
                    self.addChild(scoreFinalText)
                    
                    let bestFinalText = SKLabelNode(fontNamed: "04b_19")
                    bestFinalText.fontSize = 26
                    bestFinalText.position = CGPointMake( CGRectGetMidX( self.frame )+90,CGRectGetMidY( self.frame )-40 - 300)
                    bestFinalText.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Right
                    bestFinalText.text = NSString(format: "%d", self.getBestScore()) as String
                    self.addChild(bestFinalText)
                    
                    scoreFinalText.runAction(SKAction.sequence([SKAction.moveToY(CGRectGetMidY(self.frame)+5, duration: 0.2)]))
                    bestFinalText.runAction(SKAction.sequence([SKAction.moveToY(CGRectGetMidY(self.frame)-40, duration: 0.2)]))
                    self.gameOverOverlay.runAction(SKAction.sequence([SKAction.moveToY(CGRectGetMidY(self.frame)-0, duration: 0.2),SKAction.waitForDuration(0.3)]), completion: {
                        
                        
                        let playTexture = SKTexture(imageNamed:"play.png")
                        self.gameOverPlayButton = SKSpriteNode(texture: playTexture)
                        self.gameOverPlayButton.position = CGPoint(x:CGRectGetMidX(self.frame)-80, y:CGRectGetMidY(self.frame)-145)
                        self.gameOverPlayButton.setScale(1)
                        self.gameOverPlayButton.alpha = 0
                        self.gameOverPlayButton.userInteractionEnabled = false
                        self.gameOverPlayButton.name = "playbutton"
                        self.self.addChild(self.gameOverPlayButton)
                        self.gameOverPlayButton.runAction(SKAction.fadeAlphaTo(1, duration: 0.1))
                        
                        let leadTexture = SKTexture(imageNamed:"leaderboard.png")
                        leadTexture.filteringMode = SKTextureFilteringMode.Nearest
                        
                        self.gameOverLeaderButton = SKSpriteNode(texture: leadTexture)
                        self.gameOverLeaderButton.position = CGPoint(x:CGRectGetMidX(self.frame)+80, y:CGRectGetMidY(self.frame)-145)
                        self.gameOverLeaderButton.setScale(1)
                        self.gameOverLeaderButton.alpha = 0
                        self.gameOverLeaderButton.userInteractionEnabled = false
                        self.gameOverLeaderButton.name = "leadbutton"
                        self.addChild(self.gameOverLeaderButton)
                        self.gameOverLeaderButton.runAction(SKAction.fadeAlphaTo(1, duration: 0.1))
                        
                        
                        })
                    
                    })
                
                
                
                
                //shakeScene(nodeToShake: gameRunning, times: 10) //Currently has no effect( IS NO WORK )
            }
            
            
        }
    }
    
    func didEndContact(contact: SKPhysicsContact){
    }
    
    func resetGame() {
        
        shouldStart = false
        
        
        self.physicsWorld.gravity = CGVectorMake( 0.0, 0.0 )
        startSprite.runAction(SKAction.fadeAlphaTo(1, duration: 0.6))
        
        bird.position = CGPointMake(CGRectGetMidX(self.frame)-120, CGRectGetMidY(self.frame)+50)
        bird.physicsBody!.velocity = CGVectorMake(0,0)
        bird.physicsBody!.collisionBitMask = worldCategory | pipeCategory
        bird.speed = 1.0
        bird.zRotation = 0.0
        pipes.removeAllChildren()
        self.isRestartApplicable = false
        self.gameRunning.speed = 1
        
        self.score = 0
        self.scoreLabelNode.text = NSString(format:"%d", self.score) as String
        self.scoreLabelNodeShadow.text = NSString(format:"%d", self.score) as String
        
        
        
        let autoPilotAnim = SKAction.repeatActionForever(SKAction.sequence([SKAction.moveToY(bird.position.y-15, duration: 0.4), SKAction.moveToY(bird.position.y, duration: 0.4)]))
        autoPilotAnim.timingMode = SKActionTimingMode.EaseIn;
        bird.runAction(autoPilotAnim, withKey:"initialanim")
        
        bird.removeActionForKey("wingflap")
        birdAction = SKAction.animateWithTextures(birdFlightTextures as! [SKTexture], timePerFrame: 0.1)
        bird.runAction(SKAction.repeatActionForever(birdAction), withKey:"wingflap")
    }
    
    func shakeScene(nodeToShake nodeToShake: SKNode, times:NSInteger) {
        
        
    }
    
    func operateOnScore(score:NSInteger) {
        if getBestScore() < score {
            setBestScore(score)
        }
    }
    
    func setBestScore(score:NSInteger){
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        userDefaults.setObject(score, forKey: "bestscore")
        
        userDefaults.synchronize()
    }
    
    func getBestScore() -> NSInteger {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        return userDefaults.objectForKey("bestscore")!.integerValue
    }
    
}

