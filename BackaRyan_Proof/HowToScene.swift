//
//  HowToScene.swift
//  BackaRyan_Proof
//
//  Created by Ryan K Backa on 5/26/16.
//  Copyright © 2016 Ryan Backa. All rights reserved.
//

import SpriteKit

class HowToScene: SKScene {
  
  //creation of nodes
  let bgImage = SKSpriteNode(imageNamed: "Background")
  
  let movementLbl = SKLabelNode()
  let bombLbl = SKLabelNode()
  let coinLbl = SKLabelNode()
  let redOrbLabel = SKLabelNode()
  let greenOrbLabel = SKLabelNode()
  
  let birdSheet = Bird()
  var bird1: SKSpriteNode!
  
  let coinSheet = Coin()
  var coin: SKSpriteNode!
  
  let bomb = SKSpriteNode(imageNamed: "bomb")
  let greenOrb = SKSpriteNode(imageNamed: "greenOrb")
  let redOrb = SKSpriteNode(imageNamed: "redOrb")
  
  let screenSize: CGRect = UIScreen.mainScreen().bounds
  var screenWidth = CGFloat()
  var widthRatio = CGFloat()
  
  override func didMoveToView(view: SKView) {
    
    screenWidth = screenSize.width
    widthRatio = screenWidth/1080
    
    //sets background
    bgImage.setScale(1.15*widthRatio)
    bgImage.position = CGPointMake(self.size.width/2, self.size.height/2 )
    bgImage.zPosition = 0
    addChild(bgImage)
    
    // describes how to move
    movementLbl.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2 + self.frame.height / 3.5)
    movementLbl.text = "Tap the screen to move              to where you want to go"
    movementLbl.fontName = "04b_19"
    movementLbl.fontColor = UIColor.blackColor()
    movementLbl.zPosition = 3
    movementLbl.fontSize = 25
    self.addChild(movementLbl)
    
    // tells you to avoid bombs
    bombLbl.position = CGPoint(x: self.frame.width / 2 - self.frame.width / 15, y: self.frame.height / 2 + self.frame.height / 7)
    bombLbl.text = "Move to avoid "
    bombLbl.fontName = "04b_19"
    bombLbl.fontColor = UIColor.blackColor()
    bombLbl.zPosition = 3
    bombLbl.fontSize = 25
    self.addChild(bombLbl)
    
    // tells you to collect coins
    coinLbl.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2 - self.frame.height / 22)
    coinLbl.text = "Collect as many          as you can "
    coinLbl.fontName = "04b_19"
    coinLbl.fontColor = UIColor.blackColor()
    coinLbl.zPosition = 3
    coinLbl.fontSize = 25
    self.addChild(coinLbl)
    
    redOrbLabel.position = CGPoint(x: self.frame.width / 2 + self.frame.width / 27, y: self.frame.height / 2 - self.frame.height / 4.5)
    redOrbLabel.text = "        allows you difuse one bomb"
    redOrbLabel.fontName = "04b_19"
    redOrbLabel.fontColor = UIColor.blackColor()
    redOrbLabel.zPosition = 3
    redOrbLabel.fontSize = 25
    self.addChild(redOrbLabel)
    
    greenOrbLabel.position = CGPoint(x: self.frame.width / 2 + self.frame.width / 27, y: self.frame.height / 2 - self.frame.height / 2.7)
    greenOrbLabel.text = "        allows you difuse three bombs"
    greenOrbLabel.fontName = "04b_19"
    greenOrbLabel.fontColor = UIColor.blackColor()
    greenOrbLabel.zPosition = 3
    greenOrbLabel.fontSize = 25
    self.addChild(greenOrbLabel)
    
    //animation for the bird and adds bird to scene
    bird1 = SKSpriteNode(texture: birdSheet.frame_1())
    let fly = SKAction.animateWithTextures(birdSheet.frame_(), timePerFrame: 0.18)
    let birdSequence = SKAction.repeatActionForever(fly)
    bird1.runAction(birdSequence)
    bird1.setScale(0.15*widthRatio)
    bird1.position = CGPointMake(self.size.width/2 - self.size.width/90, self.size.height/2 + self.size.height/3.5 )
    bird1.zPosition = 1
    addChild(bird1)
    
    // adds bomb to scene
    bomb.position = CGPointMake(self.frame.width / 2 + self.frame.width / 12, self.frame.height / 2  + self.frame.height / 5)
    bomb.setScale(0.25*widthRatio)
    bomb.zPosition = 1
    addChild(bomb)
    
    //adds animated coin to the scene
    coin = SKSpriteNode(texture: coinSheet.coin_01())
    let spin = SKAction.animateWithTextures(coinSheet.coin_(), timePerFrame: 0.2)
    let coinSequence = SKAction.repeatActionForever(spin)
    coin.runAction(coinSequence)
    coin.setScale(0.8*widthRatio)
    coin.position = CGPointMake(self.frame.width / 2 + self.frame.width / 32, self.frame.height / 2  - self.frame.height / 28)
    coin.zPosition = 1
    addChild(coin)
    
    //adds red orb to scene
    redOrb.position = CGPointMake(self.frame.width / 2 - self.frame.width / 4.5, self.frame.height / 2  - self.frame.height / 4.8)
    redOrb.setScale(0.05*widthRatio)
    redOrb.zPosition = 1
    addChild(redOrb)
    
    //adds green orb to scene
    greenOrb.position = CGPointMake(self.frame.width / 2 - self.frame.width / 4.5, self.frame.height / 2  - self.frame.height / 2.9)
    greenOrb.setScale(0.05*widthRatio)
    greenOrb.zPosition = 1
    addChild(greenOrb)
    
  }
  
  // goes back to main menu when screen is touched
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    let menuScene = MenuScene(size: view!.bounds.size)
    let transition = SKTransition.fadeWithDuration(0.15)
    view?.presentScene(menuScene, transition: transition)
  }
}
