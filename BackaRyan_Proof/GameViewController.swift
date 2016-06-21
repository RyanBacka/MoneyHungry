//
//  GameViewController.swift
//  BackaRyan_Proof
//
//  Created by Ryan K Backa on 5/5/16.
//  Copyright (c) 2016 Ryan Backa. All rights reserved.
//

import UIKit
import SpriteKit
import GameKit

class GameViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    authenticateLocalPlayer()
    presentScene()
  }
  
  func presentScene(){
    let scene = MenuScene(size: view.bounds.size)
    // Configure the view.
    let skView = view as! SKView
    
    skView.showsFPS = true
    skView.showsNodeCount = true
    
    /* Sprite Kit applies additional optimizations to improve rendering performance */
    skView.ignoresSiblingOrder = true
    
    /* Set the scale mode to scale to fit the window */
    scene.scaleMode = .ResizeFill
    
    skView.presentScene(scene)
  }
  
  //initiate gamecenter
  func authenticateLocalPlayer(){
    let localPlayer = GKLocalPlayer.localPlayer()
    localPlayer.authenticateHandler = {(viewController, error) -> Void in
      if (viewController != nil) {
        self.presentViewController(viewController!, animated: true, completion: nil)
      }else {
        print((GKLocalPlayer.localPlayer().authenticated))
      }
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Release any cached data, images, etc that aren't in use.
  }
  
  override func prefersStatusBarHidden() -> Bool {
    return true
  }
}
