//
//  MenuScene.swift
//  BackaRyan_Proof
//
//  Created by Ryan K Backa on 5/26/16.
//  Copyright © 2016 Ryan Backa. All rights reserved.
//

import SpriteKit
import GameKit

<<<<<<< HEAD
class MenuScene: SKScene, GKGameCenterControllerDelegate{
  
=======
class MenuScene: SKScene{
  var leaderboardID = "CgkIv5mDu8YMEAIQBQ"
>>>>>>> origin/master
  
  // creation of button nodes
  let bgImage = SKSpriteNode(imageNamed: "Background")
  let newGameBtn = SKSpriteNode(imageNamed: "NewGame")
  let creditsBtn = SKSpriteNode(imageNamed: "Credits")
  let howToBtn = SKSpriteNode(imageNamed: "HowTo")
  let leaderboardBtn = SKSpriteNode(imageNamed: "Leaderboard")
  
  let screenSize: CGRect = UIScreen.mainScreen().bounds
  var screenWidth = CGFloat()
  var widthRatio = CGFloat()
  
  override func didMoveToView(view: SKView) {
    
    screenWidth = screenSize.width
    widthRatio = screenWidth/1080
    
    // Set background image and resize to fit screen properly
    bgImage.setScale(1.15*widthRatio)
    bgImage.position = CGPointMake(self.size.width/2, self.size.height/2)
    bgImage.zPosition = 0
    addChild(bgImage)
    
    //sets the new game button
    newGameBtn.size = CGSizeMake(200, 100)
    newGameBtn.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2 + self.frame.height / 3.5)
    newGameBtn.zPosition = 1
    newGameBtn.setScale(0.9*widthRatio)
    self.addChild(newGameBtn)
    
    // sets the credits button
    creditsBtn.size = CGSizeMake(200, 100)
    creditsBtn.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2 - self.frame.height / 10)
    creditsBtn.zPosition = 1
    creditsBtn.setScale(0.9*widthRatio)
    self.addChild(creditsBtn)
    
    // sets the how to button
    howToBtn.size = CGSizeMake(200, 100)
    howToBtn.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2 + self.frame.height / 10)
    howToBtn.zPosition = 1
    howToBtn.setScale(0.9*widthRatio)
    self.addChild(howToBtn)
    
    leaderboardBtn.size = CGSizeMake(200, 100)
    leaderboardBtn.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2 - self.frame.height / 3.5)
    leaderboardBtn.zPosition = 1
    leaderboardBtn.setScale(0.9*widthRatio)
    self.addChild(leaderboardBtn)
    
  }
  
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    // sees where use touched and opens the sppropriate scene
    if let touch:UITouch = touches.first! as UITouch {
      let touched = touch.locationInNode(self)
      if newGameBtn.containsPoint(touched){
        let gameScene = GameScene(size: view!.bounds.size)
        let transition = SKTransition.fadeWithDuration(0.15)
        view?.presentScene(gameScene, transition: transition)
      } else if creditsBtn.containsPoint(touched){
        let creditsScene = CreditsScene(size: view!.bounds.size)
        let transition = SKTransition.fadeWithDuration(0.15)
        view?.presentScene(creditsScene, transition: transition)
      } else if howToBtn.containsPoint(touched){
        let howToScene = HowToScene(size: view!.bounds.size)
        let transition = SKTransition.fadeWithDuration(0.15)
        view?.presentScene(howToScene, transition: transition)
      } else if leaderboardBtn.containsPoint(touched){
<<<<<<< HEAD
        showLeader()
=======
        GPGLauncherController.sharedInstance().presentLeaderboardWithLeaderboardId(leaderboardID)
>>>>>>> origin/master
      }
    }
  }
  
  func showLeader() {
    let vc = self.view?.window?.rootViewController
    let gc = GKGameCenterViewController()
    gc.gameCenterDelegate = self
    vc?.presentViewController(gc, animated: true, completion: nil)
  }
  
  //hides leaderboard screen
  func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController)
  {
    gameCenterViewController.dismissViewControllerAnimated(true, completion: nil)
    
  }
  
}
