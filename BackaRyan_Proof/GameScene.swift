//
//  GameScene.swift
//  BackaRyan_Proof
//
//  Created by Ryan K Backa on 5/5/16.
//  Copyright (c) 2016 Ryan Backa. All rights reserved.
//

import SpriteKit
import Social
import GameKit


struct PhysicsCategory {
  static let birdCategory : UInt32  = 0x1 << 1
  static let groundCategory : UInt32  = 0x1 << 2
  static let coinCategory : UInt32  = 0x1 << 3
  static let bombCategory : UInt32  = 0x1 << 4
  static let borderCategory : UInt32 = 0x1 << 5
  static let greenOrbCategory : UInt32 = 0x1 << 6
  static let redOrbCategory : UInt32 = 0x1 << 7
}

class GameScene: SKScene, SKPhysicsContactDelegate, GKGameCenterControllerDelegate {
  
  
  
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
  let howToBtn = SKSpriteNode(imageNamed: "HowTo")
  let leaderboardBtn = SKSpriteNode(imageNamed: "Leaderboard")
  let shareBtn = SKSpriteNode(imageNamed: "Share")
  
  let thud = SKAudioNode(fileNamed: "thud.wav")
  let ching = SKAudioNode(fileNamed: "coin_drop.wav")
  let flapping = SKAudioNode(fileNamed: "flap.wav")
  let explosion = SKAudioNode(fileNamed: "explosion.wav")
  let blip = SKAudioNode(fileNamed: "laser.wav")
  let blip2 = SKAudioNode(fileNamed: "Blip_Select.mp3")
  let defuse = SKAudioNode(fileNamed: "drum.mp3")
  
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
  var totalCoin = Int()
  
  let screenSize: CGRect = UIScreen.mainScreen().bounds
  var screenWidth = CGFloat()
  var screenHeight = CGFloat()
  var widthRatio = CGFloat()
  
  var orbOn = false
  var orbCount = 0
  
  var authenticated = false
  
  let leaderboardID = "MHleaderboard62016"
  let bombAch = GKAchievement.init(identifier: "firstBombExplosion")
  let firstCoinAch = GKAchievement.init(identifier: "first50CoinGameMH")
  let secondCoinAch = GKAchievement.init(identifier: "first100CoinGameMH")
  let thirdCoinAch = GKAchievement.init(identifier: "first150CoinGameMH")
  let grOrbAch = GKAchievement.init(identifier: "greenOrbEarnedMH")
  let redOrbAch = GKAchievement.init(identifier: "redOrbEarnedMH")
  let totCoinAch1 = GKAchievement.init(identifier: "total1000coinMH")
  let totCoinAch2 = GKAchievement.init(identifier: "total2500coinMH")
  let totCoinAch3 = GKAchievement.init(identifier: "total5000coinMH")
  var achievementArray: [GKAchievement] = []
  
  
  override func didMoveToView(view: SKView) {
    if GKLocalPlayer.localPlayer().authenticated {
      authenticated = true
    }
    
    achievementArray = [bombAch, firstCoinAch, secondCoinAch, thirdCoinAch, grOrbAch, redOrbAch, totCoinAch1, totCoinAch2, totCoinAch3]
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
    orbLabel.text = "Orbs: \(orbCount)"
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
    blip.autoplayLooped = false
    blip2.autoplayLooped = false
    ching.autoplayLooped = false
    defuse.autoplayLooped = false
    addChild(explosion)
    addChild(thud)
    addChild(blip)
    addChild(blip2)
    addChild(ching)
    addChild(defuse)
    
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
  func createMenu(){
    resetBtn.size = CGSizeMake(200, 100)
    resetBtn.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2 + self.frame.height / 5)
    resetBtn.zPosition = 6
    resetBtn.setScale(0.9 * widthRatio)
    self.addChild(resetBtn)
    
    
    
    leaderboardBtn.size = CGSizeMake(200, 100)
    leaderboardBtn.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2 )
    leaderboardBtn.zPosition = 6
    leaderboardBtn.setScale(0.9 * widthRatio)
    self.addChild(leaderboardBtn)
    
    shareBtn.size = CGSizeMake(200, 100)
    shareBtn.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2 - self.frame.height / 5)
    shareBtn.zPosition = 6
    shareBtn.setScale(0.9 * widthRatio)
    self.addChild(shareBtn)
  }
  
  
  //send high score to leaderboard
  func setHighScore(score:Int) {
    //check if user is signed in
      let scoreReporter = GKScore(leaderboardIdentifier: leaderboardID)
      scoreReporter.value = Int64(score)
      let scoreArray: [GKScore] = [scoreReporter]
      GKScore.reportScores(scoreArray, withCompletionHandler: { (error) in
        if error != nil {
          print ("Error: \(error)")
        }
      })
    
  }
  
  func setAchievements(achArray:[GKAchievement]){
    GKAchievement.reportAchievements(achArray, withCompletionHandler: { (error) in
      if error != nil {
        print("Error reporting achievement: \(error)")
      } else {
        print("I reported: \(self.thirdCoinAch.percentComplete)")
      }
    })
  }
  
  //hides leaderboard screen
  func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController)
  {
    gameCenterViewController.dismissViewControllerAnimated(true, completion: nil)
    
  }
  
  // function to reset the scene
  func resetScene(){
    setHighScore(score)
    self.removeAllChildren()
    died = false
    gameStarted = false
    score = 0
    level = 1
    orbCount = 0
    coinCount1 = 0
    coinCount2 = 0
    orbOn = false
    orbLabel.text = "Orbs: \(orbCount)"
    createScene()
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
  
  func showLeader() {
    let vc = self.view?.window?.rootViewController
    let gc = GKGameCenterViewController()
    gc.gameCenterDelegate = self
    vc?.presentViewController(gc, animated: true, completion: nil)
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
        if leaderboardBtn.containsPoint(touched){
          setHighScore(score)
          showLeader()
        }
        if shareBtn.containsPoint(touched){
          let message = "I collected \(score) coins in Money Hungry. How many can you collect?"
          let controller = self.view?.window?.rootViewController as! GameViewController
          let vc = UIActivityViewController(activityItems: [message], applicationActivities: nil)
          controller.presentViewController(vc, animated: true, completion: nil)
        }
      }
    }
    
    // on first touch bombs and coins start generating randomly across the screen
    if gameStarted == false{
      flapping.autoplayLooped = true
      addChild(flapping)
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
      case 126:
        removeActionForKey("bombAction")
        level = 13
        levelLbl.text = "Level: \(level)"
        duration = 0.4
        dropBomb(duration)
        actionHappened = true
      case 143:
        removeActionForKey("bombAction")
        level = 14
        levelLbl.text = "Level: \(level)"
        duration = 0.3
        dropBomb(duration)
        actionHappened = true
      case 161:
        removeActionForKey("bombAction")
        level = 15
        levelLbl.text = "Level: \(level)"
        duration = 0.25
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
    
    //checks to see if you have collected an orb and determines which logic to use based on that
    if orbOn == false{
      // handles if the bird runs into the bomb
      if firstBody.categoryBitMask == PhysicsCategory.bombCategory && secondBody.categoryBitMask == PhysicsCategory.birdCategory ||
        firstBody.categoryBitMask == PhysicsCategory.birdCategory && secondBody.categoryBitMask == PhysicsCategory.bombCategory {
        explosion.runAction(SKAction.play())
        flapping.runAction(SKAction.pause())
        firstBody.node!.removeFromParent()
        secondBody.node!.removeFromParent()
        self.removeAllActions()
        died = true
        if authenticated == true {
          bombAch.percentComplete = bombAch.percentComplete + 100
          if firstCoinAch.completed != true {
            firstCoinAch.percentComplete = 0.0
          }
          if secondCoinAch.completed != true {
            secondCoinAch.percentComplete = 0.0
          }
          if thirdCoinAch.completed != true{
            thirdCoinAch.percentComplete = 0.0
          }
          setAchievements(achievementArray)
        }
        createMenu()
      }
    } else if orbOn == true{
      // handles if the bird hits a bomb while orb is on and turns orb off if last orb is used
      if firstBody.categoryBitMask == PhysicsCategory.bombCategory && secondBody.categoryBitMask == PhysicsCategory.birdCategory {
        defuse.runAction(SKAction.play())
        firstBody.node!.removeFromParent()
        orbCount = orbCount - 1
        if orbCount == 0 {
          orbOn = false
          orbLabel.text = "Orbs: \(orbCount)"
        }
      }
      if firstBody.categoryBitMask == PhysicsCategory.birdCategory && secondBody.categoryBitMask == PhysicsCategory.bombCategory{
        defuse.runAction(SKAction.play())
        secondBody.node!.removeFromParent()
        orbCount = orbCount - 1
        if orbCount == 0 {
          orbOn = false
          orbLabel.text = "Orbs: \(orbCount)"
        }
      }
    }
    
    // handles if the bird runs into the coin and adds orb production
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
      case 126:
        actionHappened = false
      case 143:
        actionHappened = false
      case 161:
        actionHappened = false
      default:
        break
      }
      
      if authenticated == true{
        if firstCoinAch.completed != true{
          firstCoinAch.percentComplete = firstCoinAch.percentComplete + 2.0
          setAchievements(achievementArray)
        }
        if secondCoinAch.completed != true{
          secondCoinAch.percentComplete = secondCoinAch.percentComplete + 1.0
          setAchievements(achievementArray)
        }
        if thirdCoinAch.completed != true{
          
          thirdCoinAch.percentComplete = thirdCoinAch.percentComplete + 0.666666
          if thirdCoinAch.percentComplete == 99.333234{
            thirdCoinAch.percentComplete = 100
          }
          setAchievements(achievementArray)
        }
        
        if totCoinAch1.completed != true{
          totCoinAch1.percentComplete = totCoinAch1.percentComplete + 0.1
          setAchievements(achievementArray)
        }
        if totCoinAch2.completed != true{
          totCoinAch2.percentComplete = totCoinAch2.percentComplete + 0.04
          setAchievements(achievementArray)
        }
        if totCoinAch3.completed != true{
          totCoinAch3.percentComplete = totCoinAch3.percentComplete + 0.02
          setAchievements(achievementArray)
        }
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
    
    // handles if the bird runs into the coin and adds orb production
    if firstBody.categoryBitMask == PhysicsCategory.coinCategory && secondBody.categoryBitMask == PhysicsCategory.birdCategory {
      ching.runAction(SKAction.play())
      firstBody.node?.removeFromParent()
      score = score+1
      scoreLabel.text = "\(score)"
      coinCount1 = coinCount1 + 1
      coinCount2 = coinCount2 + 1
      totalCoin = totalCoin + 1
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
      case 126:
        actionHappened = false
      case 143:
        actionHappened = false
      case 161:
        actionHappened = false
      default:
        break
      }
      
      if authenticated == true{
        if firstCoinAch.completed != true{
          firstCoinAch.percentComplete = firstCoinAch.percentComplete + 2.0
          setAchievements(achievementArray)
        }
        if secondCoinAch.completed != true{
          secondCoinAch.percentComplete = secondCoinAch.percentComplete + 1.0
          setAchievements(achievementArray)
        }
        if thirdCoinAch.completed != true{
          thirdCoinAch.percentComplete = thirdCoinAch.percentComplete + 0.00666667
          setAchievements(achievementArray)
        }
        
        if totCoinAch1.completed != true{
          totCoinAch1.percentComplete = totCoinAch1.percentComplete + 0.001
          setAchievements(achievementArray)
        }
        if totCoinAch2.completed != true{
          totCoinAch2.percentComplete = totCoinAch2.percentComplete + 0.0004
          setAchievements(achievementArray)
        }
        if totCoinAch3.completed != true{
          totCoinAch3.percentComplete = totCoinAch3.percentComplete + 0.0002
          setAchievements(achievementArray)
        }
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
      orbCount = orbCount + 3
      orbOn = true
      orbLabel.text = "Orbs: \(orbCount)"
      coinCount2 = 0
      if authenticated == true {
        if grOrbAch.completed != true{
          grOrbAch.percentComplete = grOrbAch.percentComplete + 100.0
          setAchievements(achievementArray)
        }
      }
    }
    if firstBody.categoryBitMask == PhysicsCategory.birdCategory  && secondBody.categoryBitMask == PhysicsCategory.greenOrbCategory {
      blip.runAction(SKAction.play())
      secondBody.node?.removeFromParent()
      orbCount = orbCount + 3
      orbOn = true
      orbLabel.text = "Orbs: \(orbCount)"
      coinCount2 = 0
      if authenticated == true {
        if grOrbAch.completed != true{
          grOrbAch.percentComplete = grOrbAch.percentComplete + 100.0
          setAchievements(achievementArray)
        }
      }
    }
    
    //handles if the bird hits the red orb
    if firstBody.categoryBitMask == PhysicsCategory.redOrbCategory && secondBody.categoryBitMask == PhysicsCategory.birdCategory {
      blip2.runAction(SKAction.play())
      firstBody.node?.removeFromParent()
      orbCount = orbCount + 1
      orbOn = true
      orbLabel.text = "Orbs: \(orbCount)"
      coinCount1 = 0
      if authenticated == true {
        if redOrbAch.completed != true{
          redOrbAch.percentComplete = redOrbAch.percentComplete + 100.0
          setAchievements(achievementArray)
        }
      }
    }
    if firstBody.categoryBitMask == PhysicsCategory.birdCategory && secondBody.categoryBitMask == PhysicsCategory.redOrbCategory {
      blip2.runAction(SKAction.play())
      secondBody.node?.removeFromParent()
      orbCount = orbCount + 1
      orbOn = true
      orbLabel.text = "Orbs: \(orbCount)"
      coinCount1 = 0
      if authenticated == true {
        if redOrbAch.completed != true{
          redOrbAch.percentComplete = redOrbAch.percentComplete + 100.0
          setAchievements(achievementArray)
        }
      }
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
      if distanceLeft >= 10{
        let distanceToTravel = CGFloat(delta!) * CGFloat(defaultBirdSpeed)
        let angle = atan2(currentPosition.y - destination.y, currentPosition.x - destination.x)
        let yOffset = distanceToTravel * sin(angle)
        let xOffset = distanceToTravel * cos(angle)
        bird.position = CGPointMake(bird.position.x-xOffset, bird.position.y-yOffset)
      }
    }
  }
}
