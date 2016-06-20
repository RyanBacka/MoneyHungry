//
//  GameViewController.swift
//  BackaRyan_Proof
//
//  Created by Ryan K Backa on 5/5/16.
//  Copyright (c) 2016 Ryan Backa. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController, GPGStatusDelegate{
  
  
  var kClientID = "431231126719-dajh1k7n7rms75g55mnggq0aqons2ii8.apps.googleusercontent.com"
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    
    GPGManager.sharedInstance().statusDelegate = self;
    
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
  
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Release any cached data, images, etc that aren't in use.
  }
  
  override func prefersStatusBarHidden() -> Bool {
    return true
  }
  
  func didFinishGamesSignInWithError(error: NSError!) {
    if (error != nil) {
      print("Signed in!")
    } else {
      print("recieved error \(error) while signing in")
    }
  }
  
  
  
}
