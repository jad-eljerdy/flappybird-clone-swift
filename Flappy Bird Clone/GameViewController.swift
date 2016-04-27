//
//  GameViewController.swift
//  Flappy Bird Clone
//
//  Created by Jad El Jerdy on 6/5/14.
//  Copyright (c) 2014 jadeljerdy. All rights reserved.
//

import UIKit
import SpriteKit

extension SKNode {
    class func unarchiveFromFile(file : NSString) -> SKNode? {
        
        let path = NSBundle.mainBundle().pathForResource(file as String, ofType: "sks")
        
        var sceneData = NSData?()
        do {
            sceneData = try NSData(contentsOfFile:path!, options: NSDataReadingOptions.DataReadingMappedIfSafe)
        } catch _ {
            sceneData = nil
        }
        
        let archiver = NSKeyedUnarchiver(forReadingWithData: sceneData!)
        
        
        
        archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
        let scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as! StartupScene
        archiver.finishDecoding()
        return scene
    }
}

class GameViewController: UIViewController {

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let skView = self.view as! SKView
        print(skView.bounds.size)
        
        let scene = StartupScene(size:skView.bounds.size)
        // Configure the view.
            
        skView.showsFPS = true
        skView.showsNodeCount = true
            
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
            
        /* Set the scale mode to scale to fit the window */
        //scene.scaleMode = SKSceneScaleMode.AspectFit
            
        skView.presentScene(scene)
        
    }

    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return UIInterfaceOrientationMask.AllButUpsideDown
        } else {
            return UIInterfaceOrientationMask.All
        }
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
}
