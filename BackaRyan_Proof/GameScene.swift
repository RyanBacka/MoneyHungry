//
//  GameScene.swift
//  BackaRyan_Proof
//
//  Created by Ryan K Backa on 5/5/16.
//  Copyright (c) 2016 Ryan Backa. All rights reserved.
//

import SpriteKit

struct PhysicsCategory {
  static let birdCategory : UInt32  = 0x1 << 1
  static let groundCategory : UInt32  = 0x1 << 2
  static let coinCategory : UInt32  = 0x1 << 3
  static let bombCategory : UInt32  = 0x1 << 4
  static let borderCategory : UInt32 = 0x1 << 5
}

class GameScene: SKScene, SKPhysicsContactDelegate {
  
  
  
  // Creation of Nodes
  
  let bgImage = SKSpriteNode(imageNamed: "Background")
  let birdSheet = Bird()
  var bird: SKSpriteNode!
  let coinSheet = Coin()
  var coin: SKSpriteNode!
  let ground = SKSpriteNode(imageNamed: "ground")
  let resetBtn = SKSpriteNode(imageNamed: "reset")
  let pauseBtn = SKSpriteNode(imageNamed: "pause_icon")
  
  let thud = SKAudioNode(fileNamed: "thud.wav")
  let ching = SKAudioNode(fileNamed: "coin_drop.wav")
  let flapping = SKAudioNode(fileNamed: "flap.wav")
  let explosion = SKAudioNode(fileNamed: "explosion.wav")
  
  var bombDelay = SKAction()
  
  var lastTimeFrame: CFTimeInterval?
  var delta: CFTimeInterval?
  var defaultBirdSpeed = 200
  var destination: CGPoint?
  
  var maxX: CGFloat = 0.0
  var maxY: CGFloat = 0.0
  
  var gameStarted = Bool()
  
  var score = Int()
  var scoreLabel = SKLabelNode()
  
  var died = Bool()
  var reset = SKSpriteNode()
  
  let screenSize: CGRect = UIScreen.mainScreen().bounds
  var screenWidth = CGFloat()
  var screenHeight = CGFloat()
  var widthRatio = CGFloat()

  
  
  override func didMoveToView(view: SKView) {
    //used to scale the images
    screenWidth = screenSize.width
    widthRatio = screenWidth/1080
    // used for randomly placing the images
    maxX = size.width
    maxY = size.height
    
    
    gameStarted = false
    physicsWorld.gravity = CGVectorMake(0.0, -0.5)
    createScene()
  }
  
  //function to create the starting scene before gameplay starts
  func createScene(){
    // creates and places the score label
    scoreLabel.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2 - self.frame.height / 2.05)
    scoreLabel.text = "\(score)"
    scoreLabel.fontName = "04b_19"
    scoreLabel.zPosition = 3
    scoreLabel.fontSize = 40
    self.addChild(scoreLabel)
    
    //creates and places the pause button
    pauseBtn.position = CGPoint(x: self.frame.width / 2 - self.frame.width / 2.2, y: self.frame.height / 2 - self.frame.height / 2.15)
    pauseBtn.zPosition = 3
    pauseBtn.setScale(0.5*widthRatio)
    addChild(pauseBtn)
    
    //creates a border so the bird cant leave the screen
    let borderBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
    borderBody.friction = 0
    self.physicsBody = borderBody
    borderBody.categoryBitMask = PhysicsCategory.borderCategory
    
    //animation for the bird
    bird = SKSpriteNode(texture: birdSheet.frame_1())
    let fly = SKAction.animateWithTextures(birdSheet.frame_(), timePerFrame: 0.18)
    let birdSequence = SKAction.repeatActionForever(fly)
    bird.runAction(birdSequence)
    
    // Set background image and resize to fit screen properly
    bgImage.setScale(1.15*widthRatio)
    bgImage.position = CGPointMake(self.size.width/2, self.size.height/2)
    bgImage.zPosition = 0
    addChild(bgImage)
    
    // adds the ground to the scene and adds physics
    ground.setScale(1.7*widthRatio)
    ground.position = CGPointMake(self.frame.width/2, 0+ground.frame.height/2)
    ground.zPosition = 2
    ground.physicsBody = SKPhysicsBody(rectangleOfSize: ground.frame.size)
    ground.physicsBody?.categoryBitMask = PhysicsCategory.groundCategory
    ground.physicsBody?.collisionBitMask = PhysicsCategory.birdCategory | PhysicsCategory.coinCategory
    ground.physicsBody?.contactTestBitMask = PhysicsCategory.birdCategory | PhysicsCategory.coinCategory | PhysicsCategory.bombCategory
    ground.physicsBody?.affectedByGravity = false
    ground.physicsBody?.dynamic = false
    addChild(ground)
    
    // Set scale of bird, position and sound for bird flapping and add to scene
    bird.setScale(0.15*widthRatio)
    bird.position = CGPointMake(100, self.size.height/2)
    bird.zPosition = 1
    bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.width/2)
    bird.physicsBody?.categoryBitMask = PhysicsCategory.birdCategory
    bird.physicsBody?.collisionBitMask = PhysicsCategory.groundCategory
    bird.physicsBody?.contactTestBitMask =  PhysicsCategory.bombCategory | PhysicsCategory.coinCategory
    bird.physicsBody?.affectedByGravity = false
    bird.physicsBody?.dynamic = true
    bird.physicsBody?.allowsRotation = false
    bird.physicsBody?.usesPreciseCollisionDetection = true
    addChild(bird)
    
    //sets up the sounds to be used later
    explosion.autoplayLooped = false
    thud.autoplayLooped = false
    flapping.autoplayLooped = true
    addChild(flapping)
    addChild(explosion)
    addChild(thud)
    
    ching.autoplayLooped = false
    addChild(ching)
    
    // sets the scene as the physics contact delegate
    physicsWorld.contactDelegate = self
    
  }
  
  //creates the bomb for random placement
  func createBomb(){
    //adds the bomb to the scene and adds physics
    let bomb = SKSpriteNode(imageNamed: "bomb")
    let xPos = CGFloat(Float(arc4random()) / Float(UINT32_MAX)) * maxX
    
    bomb.position = CGPointMake(xPos, self.frame.height / 2 + self.frame.height / 2.2)
    bomb.setScale(0.25*widthRatio)
    bomb.zPosition = 1
    bomb.physicsBody = SKPhysicsBody(circleOfRadius: bomb.size.width/2)
    bomb.physicsBody?.categoryBitMask = PhysicsCategory.bombCategory
    bomb.physicsBody?.contactTestBitMask = PhysicsCategory.birdCategory | PhysicsCategory.groundCategory
    bomb.physicsBody?.affectedByGravity = true
    bomb.physicsBody?.dynamic = true
    addChild(bomb)
  }
  
  // creates the coin for random placement
  func createCoin(){
    
    coin = SKSpriteNode(texture: coinSheet.coin_01())
    let spin = SKAction.animateWithTextures(coinSheet.coin_(), timePerFrame: 0.2)
    let coinSequence = SKAction.repeatActionForever(spin)
    coin.runAction(coinSequence)
    
    //places coin and adds physics
    coin.setScale(0.8*widthRatio)
    let xPos = CGFloat(Float(arc4random()) / Float(UINT32_MAX)) * maxX
    coin.position = CGPointMake(xPos, self.frame.height / 2 + self.frame.height / 2.2)
    coin.zPosition = 1
    coin.physicsBody = SKPhysicsBody(circleOfRadius: coin.size.width/2)
    coin.physicsBody?.categoryBitMask = PhysicsCategory.coinCategory
    coin.physicsBody?.contactTestBitMask = PhysicsCategory.birdCategory | PhysicsCategory.groundCategory
    coin.physicsBody?.affectedByGravity = true
    coin.physicsBody?.dynamic = true
    addChild(coin)
    
  }
  
  //creates the reset button
  func createReset(){
    resetBtn.size = CGSizeMake(200, 100)
    resetBtn.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
    resetBtn.zPosition = 6
    resetBtn.setScale(0.7)
    self.addChild(resetBtn)
    resetBtn.runAction(SKAction.scaleTo(1.0, duration: 0.3))
  }
  
  // function to reset the scene
  func resetScene(){
    let menuScene = MenuScene(size: view!.bounds.size)
    let transition = SKTransition.fadeWithDuration(0.15)
    view?.presentScene(menuScene, transition: transition)
  }
  
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    /* Called when a touch begins */
    
    // gets the position touched if it is the pause button it pauses the game if not it moves the bird
    if let touch:UITouch = touches.first! as UITouch {
      let touched = touch.locationInNode(self)
      if pauseBtn.containsPoint(touched){
        if self.view?.paused == false {
          self.view?.paused = true
        } else {
          self.view?.paused = false
        }
      } else {
        destination = touched
      }
      if died == true{
        if resetBtn.containsPoint(touched){
          resetScene()
        }
      }
    }
    
      // on first touch bombs and coins start generating randomly across the screen
      if gameStarted == false{
        gameStarted = true
        // creates coins at a 3 second interval
        let spawnCoin = SKAction.runBlock {
          ()in
          self.createCoin()
        }
        let coinDelay = SKAction.waitForDuration(4.0)
        let coinSpawnDelay = SKAction.sequence([spawnCoin,coinDelay])
        let coinAction = SKAction.repeatActionForever(coinSpawnDelay)
        self.runAction(coinAction)
        
        let spawnBomb = SKAction.runBlock {
          ()in
          self.createBomb()

        }
        bombDelay = SKAction.waitForDuration(1.0)
        let bombSpawDelay = SKAction.sequence([spawnBomb,bombDelay])
        let bombAction = SKAction.repeatActionForever(bombSpawDelay)
        self.runAction(bombAction)
      }
    }
    
    // Mark: - Physics
    
    // adds logic for when the bird makes contact with other sprites
    func didBeginContact(contact: SKPhysicsContact){
      let firstBody = contact.bodyA
      let secondBody = contact.bodyB
      
      // handles if the bird runs into the wall or ground
      if firstBody.categoryBitMask == PhysicsCategory.groundCategory && secondBody.categoryBitMask == PhysicsCategory.birdCategory ||
        firstBody.categoryBitMask == PhysicsCategory.birdCategory && secondBody.categoryBitMask == PhysicsCategory.groundCategory{
        thud.runAction(SKAction.play())
      }
      
      //handles if the coin or bomb reaches the ground
      if firstBody.categoryBitMask == PhysicsCategory.coinCategory && secondBody.categoryBitMask == PhysicsCategory.groundCategory || firstBody.categoryBitMask == PhysicsCategory.bombCategory && secondBody.categoryBitMask == PhysicsCategory.groundCategory {
        firstBody.node?.removeFromParent()
      }
      if firstBody.categoryBitMask == PhysicsCategory.groundCategory && secondBody.categoryBitMask == PhysicsCategory.coinCategory || firstBody.categoryBitMask == PhysicsCategory.groundCategory && secondBody.categoryBitMask == PhysicsCategory.bombCategory{
        secondBody.node?.removeFromParent()
      }
      
      // handles if the bird runs into the bomb
      if firstBody.categoryBitMask == PhysicsCategory.bombCategory && secondBody.categoryBitMask == PhysicsCategory.birdCategory ||
        firstBody.categoryBitMask == PhysicsCategory.birdCategory && secondBody.categoryBitMask == PhysicsCategory.bombCategory {
        explosion.runAction(SKAction.play())
        flapping.runAction(SKAction.pause())
        firstBody.node!.removeFromParent()
        secondBody.node!.removeFromParent()
        died = true
        self.removeAllActions()
        createReset()
      }
      
      // handles if the bird runs into the coin
      if firstBody.categoryBitMask == PhysicsCategory.birdCategory && secondBody.categoryBitMask == PhysicsCategory.coinCategory {
        ching.runAction(SKAction.play())
        secondBody.node?.removeFromParent()
        score = score+1
        scoreLabel.text = "\(score)"
      }
      
      // handles if the bird runs into the coin
      if firstBody.categoryBitMask == PhysicsCategory.coinCategory && secondBody.categoryBitMask == PhysicsCategory.birdCategory {
        ching.runAction(SKAction.play())
        firstBody.node?.removeFromParent()
        score = score+1
        scoreLabel.text = "\(score)"
      }
    }
    
    // Mark: - Update
    
    override func update(currentTime: CFTimeInterval) {
      /* Called before each frame is rendered */
      
      // get delta for linear interpolation
      if lastTimeFrame == nil {
        lastTimeFrame = currentTime
      }
      delta = currentTime - lastTimeFrame!
      
      lastTimeFrame = currentTime
      
      let currentPosition = bird.position
      //linear interpolation for moving the bird
      if let destination = destination {
        let distanceLeft = sqrt(pow(currentPosition.x - destination.x, 2) + pow(currentPosition.y - destination.y, 2))
        print(distanceLeft)
        if distanceLeft >= 10{
          let distanceToTravel = CGFloat(delta!) * CGFloat(defaultBirdSpeed)
          print(distanceToTravel)
          let angle = atan2(currentPosition.y - destination.y, currentPosition.x - destination.x)
          let yOffset = distanceToTravel * sin(angle)
          let xOffset = distanceToTravel * cos(angle)
          bird.position = CGPointMake(bird.position.x-xOffset, bird.position.y-yOffset)
        }
      }
    }
}
