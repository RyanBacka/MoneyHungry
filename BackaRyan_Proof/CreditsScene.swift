//
//  CreditsScene.swift
//  BackaRyan_Proof
//
//  Created by Ryan K Backa on 5/26/16.
//  Copyright © 2016 Ryan Backa. All rights reserved.
//

import SpriteKit

class CreditsScene: SKScene {
  // creates nodes
  let createdByLbl = SKLabelNode()
  let kane = SKSpriteNode(imageNamed: "Kane")
  
  override func didMoveToView(view: SKView) {
    // sets the label for who developed it
    createdByLbl.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2 + self.frame.height / 15)
    createdByLbl.text = "Created by Ryan Backa"
    createdByLbl.fontName = "04b_19"
    createdByLbl.zPosition = 3
    createdByLbl.fontSize = 30
    self.addChild(createdByLbl)
    
    // adds my tag to the game
    kane.position = CGPoint(x: self.frame.width/2, y: self.frame.height/2 - self.frame.height/20)
    kane.setScale(1)
    addChild(kane)
  }
  
  //goes back to main menu when screen is pressed
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    let menuScene = MenuScene(size: view!.bounds.size)
    let transition = SKTransition.fadeWithDuration(0.15)
    view?.presentScene(menuScene, transition: transition)
  }
}
