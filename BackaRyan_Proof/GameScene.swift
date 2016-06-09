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
  static let greenOrbCategory : UInt32 = 0x1 << 6
  static let redOrbCategory : UInt32 = 0x1 << 7
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
  let redOrb = SKSpriteNode(imageNamed: "redOrb")
  let greenOrb = SKSpriteNode(imageNamed: "greenOrb")
  
  let thud = SKAudioNode(fileNamed: "thud.wav")
  let ching = SKAudioNode(fileNamed: "coin_drop.wav")
  let flapping = SKAudioNode(fileNamed: "flap.wav")
  let explosion = SKAudioNode(fileNamed: "explosion.wav")
  let blip = SKAudioNode(fileNamed: "laser.wav")
  let blip2 = SKAudioNode(fileNamed: "Blip_Select.mp3")
  
  var bombAction = SKAction()
  var duration = NSTimeInterval()
  
  var lastTimeFrame: CFTimeInterval?
  var delta: CFTimeInterval?
  var defaultBirdSpeed = 200
  var destination: CGPoint?
  
  var maxX: CGFloat = 0.0
  var maxY: CGFloat = 0.0
  
  var gameStarted = Bool()
  var actionHappened = false
  
  var score = Int()
  var scoreLabel = SKLabelNode()
  var level = 1
  var levelLbl = SKLabelNode()
  var orbLabel = SKLabelNode()
  
  var died = Bool()
  var reset = SKSpriteNode()
  
  var coinCount1 = Int()
  var coinCount2 = Int()
  
  let screenSize: CGRect = UIScreen.mainScreen().bounds
  var screenWidth = CGFloat()
  var screenHeight = CGFloat()
  var widthRatio = CGFloat()
  
  var orbOn = false
  var orbCount = 0
  var droppedBombs = 0
  
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
    
    levelLbl.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
    levelLbl.text = "Level: \(level)"
    levelLbl.fontName = "04b_19"
    levelLbl.zPosition = 1
    levelLbl.fontSize = 40
    self.addChild(levelLbl)
    
    orbLabel.position = CGPoint(x: self.frame.width / 2 + self.frame.width / 2.4, y: self.frame.height / 2 - self.frame.height / 2.05)
    orbLabel.text = "Orb: Off"
    orbLabel.fontName = "04b_19"
    orbLabel.zPosition = 3
    orbLabel.fontSize = 30
    self.addChild(orbLabel)
    
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
    bird.zPosition = 2
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
    blip.autoplayLooped = false
    blip2.autoplayLooped = false
    ching.autoplayLooped = false
    addChild(flapping)
    addChild(explosion)
    addChild(thud)
    addChild(blip)
    addChild(blip2)
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
    bomb.zPosition = 2
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
    coin.zPosition = 2
    coin.physicsBody = SKPhysicsBody(circleOfRadius: coin.size.width/2)
    coin.physicsBody?.categoryBitMask = PhysicsCategory.coinCategory
    coin.physicsBody?.contactTestBitMask = PhysicsCategory.birdCategory | PhysicsCategory.groundCategory
    coin.physicsBody?.affectedByGravity = true
    coin.physicsBody?.dynamic = true
    addChild(coin)
    
  }
  
  func greenOrbCreate(){
    let xPos = CGFloat(Float(arc4random()) / Float(UINT32_MAX)) * maxX
    greenOrb.position = CGPointMake(xPos, self.frame.height / 2 + self.frame.height / 2.2)
    greenOrb.setScale(0.05*widthRatio)
    greenOrb.zPosition = 2
    greenOrb.physicsBody = SKPhysicsBody(circleOfRadius: greenOrb.size.width/2)
    greenOrb.physicsBody?.categoryBitMask = PhysicsCategory.greenOrbCategory
    greenOrb.physicsBody?.contactTestBitMask = PhysicsCategory.birdCategory | PhysicsCategory.groundCategory
    greenOrb.physicsBody?.affectedByGravity = true
    greenOrb.physicsBody?.dynamic = true
    addChild(greenOrb)
  }
  
  func redOrbCreate(){
    let xPos = CGFloat(Float(arc4random()) / Float(UINT32_MAX)) * maxX
    redOrb.position = CGPointMake(xPos, self.frame.height / 2 + self.frame.height / 2.2)
    redOrb.setScale(0.05*widthRatio)
    redOrb.zPosition = 2
    redOrb.physicsBody = SKPhysicsBody(circleOfRadius: redOrb.size.width/2)
    redOrb.physicsBody?.categoryBitMask = PhysicsCategory.redOrbCategory
    redOrb.physicsBody?.contactTestBitMask = PhysicsCategory.birdCategory | PhysicsCategory.groundCategory
    redOrb.physicsBody?.affectedByGravity = true
    redOrb.physicsBody?.dynamic = true
    addChild(redOrb)
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
  
  func dropBomb(duration:NSTimeInterval){
    let spawnBomb = SKAction.runBlock {
      ()in
      self.createBomb()
      
    }
    let bombDelay = SKAction.waitForDuration(duration)
    let bombSpawnDelay = SKAction.sequence([spawnBomb,bombDelay])
    bombAction = SKAction.repeatActionForever(bombSpawnDelay)
    self.runAction(bombAction, withKey: "bombAction")
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
      
      duration = 4.0
      dropBomb(duration)
    }
    
    //creation of Levels logic
    if gameStarted == true && actionHappened == false{
      switch score{
      case 5:
        removeActionForKey("bombAction")
        level = 2
        levelLbl.text = "Level: \(level)"
        duration = 3.5
        dropBomb(duration)
        actionHappened = true
      case 11:
        removeActionForKey("bombAction")
        level = 3
        levelLbl.text = "Level: \(level)"
        duration = 3.0
        dropBomb(duration)
        actionHappened = true
      case 18:
        removeActionForKey("bombAction")
        level = 4
        levelLbl.text = "Level: \(level)"
        duration = 2.5
        dropBomb(duration)
        actionHappened = true
      case 26:
        removeActionForKey("bombAction")
        level = 5
        levelLbl.text = "Level: \(level)"
        duration = 2.0
        dropBomb(duration)
        actionHappened = true
      case 35:
        removeActionForKey("bombAction")
        level = 6
        levelLbl.text = "Level: \(level)"
        duration = 1.75
        dropBomb(duration)
        actionHappened = true
      case 45:
        removeActionForKey("bombAction")
        level = 7
        levelLbl.text = "Level: \(level)"
        duration = 1.5
        dropBomb(duration)
        actionHappened = true
      case 56:
        removeActionForKey("bombAction")
        level = 8
        levelLbl.text = "Level: \(level)"
        duration = 1.25
        dropBomb(duration)
        actionHappened = true
      case 68:
        removeActionForKey("bombAction")
        level = 9
        levelLbl.text = "Level: \(level)"
        duration = 1.0
        dropBomb(duration)
        actionHappened = true
      case 81:
        removeActionForKey("bombAction")
        level = 10
        levelLbl.text = "Level: \(level)"
        duration = 0.8
        dropBomb(duration)
        actionHappened = true
      case 95:
        removeActionForKey("bombAction")
        level = 11
        levelLbl.text = "Level: \(level)"
        duration = 0.6
        dropBomb(duration)
        actionHappened = true
      case 110:
        removeActionForKey("bombAction")
        level = 12
        levelLbl.text = "Level: \(level)"
        duration = 0.5
        dropBomb(duration)
        actionHappened = true
      default:
        break
      }
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
    
    //handles if the bomb or orbs reach the ground
    if firstBody.categoryBitMask == PhysicsCategory.bombCategory && secondBody.categoryBitMask == PhysicsCategory.groundCategory || firstBody.categoryBitMask == PhysicsCategory.redOrbCategory && secondBody.categoryBitMask == PhysicsCategory.groundCategory || firstBody.categoryBitMask == PhysicsCategory.greenOrbCategory && secondBody.categoryBitMask == PhysicsCategory.groundCategory{
      firstBody.node?.removeFromParent()
    }
    if firstBody.categoryBitMask == PhysicsCategory.groundCategory &&  secondBody.categoryBitMask == PhysicsCategory.bombCategory || firstBody.categoryBitMask == PhysicsCategory.groundCategory &&  secondBody.categoryBitMask == PhysicsCategory.redOrbCategory || firstBody.categoryBitMask == PhysicsCategory.groundCategory &&  secondBody.categoryBitMask == PhysicsCategory.greenOrbCategory{
      secondBody.node?.removeFromParent()
    }
    
    // handles if the coin reaches the ground
    if firstBody.categoryBitMask == PhysicsCategory.coinCategory && secondBody.categoryBitMask == PhysicsCategory.groundCategory {
      firstBody.node?.removeFromParent()
      coinCount1 = 0
      coinCount2 = 0
    }
    if firstBody.categoryBitMask == PhysicsCategory.groundCategory && secondBody.categoryBitMask == PhysicsCategory.coinCategory {
      secondBody.node?.removeFromParent()
      coinCount1 = 0
      coinCount2 = 0
    }
    
    if orbOn == false{
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
    } else if orbOn == true{
      if firstBody.categoryBitMask == PhysicsCategory.bombCategory && secondBody.categoryBitMask == PhysicsCategory.birdCategory {
        firstBody.node!.removeFromParent()
        orbCount = orbCount - 1
        if orbCount == 0 {
          orbOn = false
          orbLabel.text = "Orb: Off"
        }
      }
      if firstBody.categoryBitMask == PhysicsCategory.birdCategory && secondBody.categoryBitMask == PhysicsCategory.bombCategory{
        secondBody.node!.removeFromParent()
        orbCount = orbCount - 1
        if orbCount == 0 {
          orbOn = false
          orbLabel.text = "Orb: Off"
        }
      }
    }
    
    // handles if the bird runs into the coin
    if firstBody.categoryBitMask == PhysicsCategory.birdCategory && secondBody.categoryBitMask == PhysicsCategory.coinCategory {
      ching.runAction(SKAction.play())
      secondBody.node?.removeFromParent()
      score = score+1
      scoreLabel.text = "\(score)"
      coinCount1 = coinCount1 + 1
      coinCount2 = coinCount2 + 1
      switch score{
      case 11:
        actionHappened = false
      case 18:
        actionHappened = false
      case 26:
        actionHappened = false
      case 35:
        actionHappened = false
      case 45:
        actionHappened = false
      case 56:
        actionHappened = false
      case 68:
        actionHappened = false
      case 81:
        actionHappened = false
      case 95:
        actionHappened = false
      case 110:
        actionHappened = false
      default:
        break
      }
      
      if coinCount1 == 10 {
        coinCount1 = 0
        redOrbCreate()
      }
      
      if coinCount2 == 25 {
        coinCount2 = 0
        greenOrbCreate()
      }

    }
    
    // handles if the bird runs into the coin
    if firstBody.categoryBitMask == PhysicsCategory.coinCategory && secondBody.categoryBitMask == PhysicsCategory.birdCategory {
      ching.runAction(SKAction.play())
      firstBody.node?.removeFromParent()
      score = score+1
      scoreLabel.text = "\(score)"
      coinCount1 = coinCount1 + 1
      coinCount2 = coinCount2 + 1
      switch score{
      case 11:
        actionHappened = false
      case 18:
        actionHappened = false
      case 26:
        actionHappened = false
      case 35:
        actionHappened = false
      case 45:
        actionHappened = false
      case 56:
        actionHappened = false
      case 68:
        actionHappened = false
      case 81:
        actionHappened = false
      case 95:
        actionHappened = false
      case 110:
        actionHappened = false
      default:
        break
      }
      
      if coinCount1 == 10 {
        coinCount1 = 0
        redOrbCreate()
      }
      
      if coinCount2 == 25 {
        coinCount2 = 0
        greenOrbCreate()
      }

    }
    
    //handles if the bird hits the green orb
    if firstBody.categoryBitMask == PhysicsCategory.greenOrbCategory && secondBody.categoryBitMask == PhysicsCategory.birdCategory {
      blip.runAction(SKAction.play())
      firstBody.node?.removeFromParent()
      orbCount = orbCount + 5
      orbOn = true
      orbLabel.text = "Orb: On"
      coinCount2 = 0
    }
    if firstBody.categoryBitMask == PhysicsCategory.birdCategory  && secondBody.categoryBitMask == PhysicsCategory.greenOrbCategory {
      blip.runAction(SKAction.play())
      secondBody.node?.removeFromParent()
      orbCount = orbCount + 5
      orbOn = true
      orbLabel.text = "Orb: On"
      coinCount2 = 0
    }
    
    //handles if the bird hits the red orb
    if firstBody.categoryBitMask == PhysicsCategory.redOrbCategory && secondBody.categoryBitMask == PhysicsCategory.birdCategory {
      blip2.runAction(SKAction.play())
      firstBody.node?.removeFromParent()
      orbCount = orbCount + 1
      orbOn = true
      orbLabel.text = "Orb: On"
      coinCount1 = 0
    }
    if firstBody.categoryBitMask == PhysicsCategory.birdCategory && secondBody.categoryBitMask == PhysicsCategory.redOrbCategory {
      blip2.runAction(SKAction.play())
      secondBody.node?.removeFromParent()
      orbCount = orbCount + 1
      orbOn = true
      orbLabel.text = "Orb: On"
      coinCount1 = 0
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
