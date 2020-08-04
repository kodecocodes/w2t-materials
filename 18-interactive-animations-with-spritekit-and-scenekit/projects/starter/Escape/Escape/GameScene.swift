/**
 * Copyright (c) 2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 * distribute, sublicense, create a derivative work, and/or sell copies of the
 * Software in any work that is designed, intended, or marketed for pedagogical or
 * instructional purposes related to programming, coding, application development,
 * or information technology.  Permission for such use, copying, modification,
 * merger, publication, distribution, sublicensing, creation of derivative works,
 * or sale is expressly withheld.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import CoreMotion
import SpriteKit

enum Edge: String {
  case top, right, bottom, left
}

enum CollisionType: UInt32 {
  case player = 1
  case post = 2
  case bumper = 4
  case exitFence = 8
}

class GameScene: SKScene, SKPhysicsContactDelegate {
  
  var motionManager: CMMotionManager!
  
  var player: SKNode!
  var closingMessage: SKSpriteNode!
  var ring: SKRingNode!
  var levelLabel: SKLabelNode!
  var bgNode: SKSpriteNode!
  
  var tileDepth: CGFloat!
  var bumperLengthWide: CGFloat!
  var bumperLengthTall: CGFloat!
  var bumpersWide: Int!
  var bumpersTall: Int!
  
  var lastTouchPosition: CGPoint?
  
  let levelsToWin = 5
  
  var level = 1
  
  var gamePaused = false
  var gameOver = false {
    didSet {
      if gameOver {
        gamePaused = true
      }
    }
  }
  
  override func didMove(to view: SKView) {
    backgroundColor = SKColor.black
    
    physicsWorld.gravity = CGVector(dx: 0, dy: 0)
    physicsWorld.contactDelegate = self
    
    motionManager = CMMotionManager()
    motionManager.startAccelerometerUpdates()
    
    setupUI()
  }
  
  // Helper methods
  
  // Bigger quanitities as device size increses. Square root function curves out--decreasing rate of change
  func deviceAdjusted(quantity: CGFloat) -> CGFloat {
    let multiplier = sqrt(min(size.height, size.width) / 136) // baseline, 136 horizontal points on Apple Watch 38mm
    return quantity * multiplier
  }
  
  func edge(for position: CGPoint) -> Edge {
    let lowerBound = Int(round(tileDepth / 2))
    let upperBoundWidth = Int(round(size.width - tileDepth / 2))
    let upperBoundHeight = Int(round(size.height - tileDepth / 2))
    
    switch (Int(round(position.x)), Int(round(position.y))) {
    case (_, lowerBound):
      return .bottom
    case (upperBoundWidth, _):
      return .right
    case (_, upperBoundHeight):
      return .top
    case (lowerBound, _):
      return .left
    default:
      fatalError()
    }
  }
  
  func rotateAndScale(node: SKSpriteNode) {
    // Need to to rotate for each edge becasue the bumper and exit images are oriented for .right edge only
    var rotation: CGFloat = 0
    let edge = self.edge(for: node.position)
    switch edge {
    case .top, .bottom:
      switch edge {
      case .top:
        rotation = .pi / 2
      case .bottom:
        rotation = .pi / -2
      default:
        break
      }
      node.yScale = bumperLengthWide / node.size.height
    case .left, .right:
      switch edge {
      case .left:
        rotation = .pi
      case .right:
        rotation = 0
      default:
        break
      }
      node.yScale = bumperLengthTall / node.size.height
    }
    node.xScale = tileDepth / node.size.width
    
    node.zRotation = rotation
  }
  
  // Setup methods
  
  func buildBackgroundGrid() {
    // Create a grid as a path
    let tileEdgeLength: CGFloat = 10
    let columns = Int(frame.width / tileEdgeLength)
    let rows = Int(frame.height / tileEdgeLength)
    let path = UIBezierPath()
    
    for i in 0...columns {
      let x = CGFloat(i) * tileEdgeLength - 1
      path.move(to: CGPoint(x: x, y: 0))
      path.addLine(to: CGPoint(x: x, y: frame.height))
    }
    
    for j in 0...rows {
      let y = CGFloat(j) * tileEdgeLength - 1
      path.move(to: CGPoint(x: 0, y: y))
      path.addLine(to: CGPoint(x: frame.width, y: y))
    }
    
    UIGraphicsBeginImageContextWithOptions(frame.size, false, 0)
    
    guard let context = UIGraphicsGetCurrentContext() else {
      return
    }
    
    // Fill the background with a solid color
    context.setFillColor(SKColor(red: 27 / 255.0, green: 17 / 255.0, blue: 58 / 255.0, alpha: 1.0).cgColor)
    context.fill(frame)
    
    let bottomLeftColor = UIColor(red: 31 / 255.0, green: 218 / 255.0, blue: 255 / 255.0, alpha: 0.2)
    let topRightColor = UIColor(red: 12 / 255.0, green: 160 / 255.0, blue: 255 / 255.0, alpha: 0.2)
    let colors = [bottomLeftColor.cgColor, topRightColor.cgColor]
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    guard let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: [0,1]) else {
      return
    }
    
    let startPoint = CGPoint(x: 0, y: 0)
    let endPoint = CGPoint(x: frame.height, y: frame.width)
    
    // Draw the gridlines using a gradient
    context.addPath(path.cgPath)
    context.setLineWidth(0.5)
    context.replacePathWithStrokedPath()
    context.clip()
    context.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: .drawsAfterEndLocation)
    
    // Construct an image from the drawing
    guard let image = context.makeImage() else {
      return
    }
    UIGraphicsEndImageContext()
    let texture = SKTexture(cgImage: image)
    
    // Apply the image as a sprite
    bgNode = SKSpriteNode(texture: texture)
    bgNode.zPosition = -10
    bgNode.lightingBitMask = 1
    bgNode.name = "background"
    addChild(bgNode)
  }
  
  func setupUI() {
    let exitFence = SKSpriteNode()
    exitFence.size = size
    exitFence.physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
    exitFence.physicsBody?.isDynamic = false
    exitFence.physicsBody?.categoryBitMask = CollisionType.exitFence.rawValue
    exitFence.physicsBody?.contactTestBitMask = CollisionType.player.rawValue
    exitFence.name = "exitFence"
    addChild(exitFence)
    
    levelLabel = SKLabelNode()
    levelLabel.fontSize = min(size.width, size.height) * 2 / 3
    levelLabel.zPosition = 1001
    levelLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)
    levelLabel.verticalAlignmentMode = .center
    levelLabel.alpha = 0
    levelLabel.name = "levelLabel"
    addChild(levelLabel)
    
    // Set the bumper edge length
    if size.height < size.width {
      // Landscape
      tileDepth = size.height / deviceAdjusted(quantity: CGFloat(levelsToWin) + 2) // Accounts for two posts at corners
    } else {
      // Portrait
      tileDepth = size.width / deviceAdjusted(quantity: CGFloat(levelsToWin) + 2) // Accounts for two posts at corners
    }
    
    // Add corner posts
    for col in 0..<2 {
      for row in 0..<2 {
        let x = CGFloat(col) * (size.width - tileDepth) + tileDepth / 2
        let y = CGFloat(row) * (size.height - tileDepth) + tileDepth / 2
        createPost(at: CGPoint(x: x, y: y))
      }
    }
    
    buildBackgroundGrid()
    
    loadLevel()
  }
  
  func createPlayer() {
    
    let playerPosition = CGPoint(x: frame.midX, y: frame.midY)
    let playerSize = CGSize(width: tileDepth, height: tileDepth)
    
    let orb = SKSpriteNode(imageNamed: "orb")
    orb.size = playerSize
    
    let playerLight = SKLightNode()
    playerLight.falloff = 1
    playerLight.ambientColor = UIColor.black
    playerLight.lightColor = UIColor(red: 33 / 255.0, green: 235 / 255.0, blue: 235 / 255.0, alpha: 1.0)
    
    player = SKNode()
    player.addChild(orb)
    player.addChild(playerLight)
    player.position = playerPosition
    player.zPosition = 1000
    player.physicsBody = SKPhysicsBody(circleOfRadius: playerSize.width / 2 * 0.8)  // Adding a margin of safety so that a collision only triggers when it's well-deserved
    player.physicsBody?.allowsRotation = false
    player.physicsBody?.linearDamping = 0.5
    player.physicsBody?.categoryBitMask = CollisionType.player.rawValue
    player.physicsBody?.contactTestBitMask = CollisionType.bumper.rawValue
    player.physicsBody?.collisionBitMask = CollisionType.bumper.rawValue | CollisionType.post.rawValue
    player.name = "player"
    addChild(player)
  }
  
  func createBumper(at position: CGPoint) {
    let bumper = SKSpriteNode(imageNamed: "right_bumper")
    bumper.position = position
    bumper.color = UIColor(red: 237 / 255.0, green: 30 / 255.0, blue: 95 / 255.0, alpha: 1)
    bumper.colorBlendFactor = 1
    
    rotateAndScale(node: bumper)
    
    bumper.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: "right_bumper_alpha"), size: bumper.size)
    bumper.physicsBody?.isDynamic = false
    bumper.physicsBody?.categoryBitMask = CollisionType.bumper.rawValue
    bumper.physicsBody?.contactTestBitMask = CollisionType.player.rawValue
    bumper.centerRect = CGRect(x: 0.33, y: 0.33, width: 0.33, height: 0.33)
    bumper.name = "bumper"
    addChild(bumper)
  }
  
  func createPost(at position: CGPoint) {
    let post = SKSpriteNode(imageNamed: "corner")
    post.size = CGSize(width: tileDepth, height: tileDepth)
    post.position = position
    post.physicsBody = SKPhysicsBody(rectangleOf: post.size)
    post.physicsBody?.isDynamic = false
    post.physicsBody?.categoryBitMask = CollisionType.post.rawValue
    post.name = "post"
    addChild(post)
  }
  
  func createExit(at position: CGPoint) {
    
    let exitLight = SKLightNode()
    exitLight.position = position
    exitLight.falloff = 1
    exitLight.ambientColor = UIColor.black
    exitLight.lightColor = UIColor(red: 33 / 255.0, green: 235 / 255.0, blue: 235 / 255.0, alpha: 1.0)
    exitLight.name = "exitLight"
    addChild(exitLight)
  }
  
  // Gameplay methods
  
  func loadLevel() {
    
    // Calculate bumper quantity and sizing
    if size.height < size.width { // Landscape
      bumperLengthWide = (size.width - 2 * tileDepth) / round(deviceAdjusted(quantity: CGFloat(level)))
      let adjustedHeight = size.height - 2 * tileDepth
      bumpersTall = Int(ceil(adjustedHeight / bumperLengthWide))
      bumpersWide = Int(round(deviceAdjusted(quantity: CGFloat(level))))
      bumperLengthTall = adjustedHeight / CGFloat(bumpersTall)
    } else {  // Portrait
      bumperLengthTall = (size.height - 2 * tileDepth) / round(deviceAdjusted(quantity: CGFloat(level)))
      let adjustedWidth = size.width - 2 * tileDepth
      bumpersWide = Int(ceil(adjustedWidth / bumperLengthTall))
      bumpersTall = Int(round(deviceAdjusted(quantity: CGFloat(level))))
      bumperLengthWide = adjustedWidth / CGFloat(bumpersWide)
    }
    
    // Calculate random exit
    let rotation = Int(arc4random_uniform(2)) // horizontal or vertical
    let distance = Int(arc4random_uniform(2)) // near origin or not
    let bumpers: Int = rotation == 0 ? bumpersWide : bumpersTall // bumpers per side
    let index = Int(arc4random_uniform(UInt32(bumpers)))
    let missingBumperForExit = (rotation, distance, index)
    
    // Add bumpers
    for rotation in 0..<2 { // horizontal or vertical
      let bumpers: Int = rotation == 0 ? bumpersWide : bumpersTall
      for distance in 0..<2 { // near origin or not
        for index in 0..<bumpers { // bumpers per side
          var x: CGFloat, y: CGFloat
          if case (rotation, distance, index) = missingBumperForExit {
            if rotation == 0 { // Wide exit
              x = tileDepth + CGFloat(index) * bumperLengthWide + bumperLengthWide / 2
              y = CGFloat(distance) * size.height
            } else { // Tall exit
              x = CGFloat(distance) * size.width
              y = tileDepth + CGFloat(index) * bumperLengthTall + bumperLengthTall / 2
            }
            createExit(at: CGPoint(x: x, y: y))
          } else {
            if rotation == 0 { // Wide bumpers
              x = tileDepth + CGFloat(index) * bumperLengthWide + bumperLengthWide / 2
              y = CGFloat(distance) * (size.height - tileDepth) + tileDepth / 2
            } else { // Tall bumpers
              x = CGFloat(distance) * (size.width - tileDepth) + tileDepth / 2
              y = tileDepth + CGFloat(index) * bumperLengthTall + bumperLengthTall / 2
            }
            createBumper(at: CGPoint(x: x, y: y))
          }
        }
      }
    }
    
    // Briefly show level number
    levelLabel.text = "\(level)"
    let fadeIn = SKAction.fadeIn(withDuration: 0.6)
    let fadeOut = SKAction.fadeOut(withDuration: 0.6)
    let sequence = SKAction.sequence([fadeIn, fadeOut])
    levelLabel.run(sequence) {
      self.bgNode.isHidden = false
      self.createPlayer()
      self.gamePaused = false
    }
  }
  
  func tearDownLevelUI(leaving lastNode: SKNode? = nil, completion: (() -> Void)? = nil) {
    bgNode.isHidden = true
    // Remove bumpers and exitLight one by one
    let nodesToRemove: [SKNode] = self.children.filter() {
      let isBumperNotLastNode = ($0.name == "bumper" && $0 != lastNode)
      let isExitLight = ($0.name == "exitLight")
      return isBumperNotLastNode || isExitLight
    }
    
    let nestedActionsToRun: [[SKAction]] = nodesToRemove.map { node in
      let block = {
        node.run(SKAction.removeFromParent())
      }
      let duration = 1 / Double(nodesToRemove.count) // Runs faster when more nodes displayed
      
      // These two actions are collected into a sequence with many others. Weirdly, the latter action doesn't run at the very end of the collected sequence. I had these two actions swapped before. The bug I noticed was one bumper node left over in the hierarchy at the end. By swapping these two actions, the bumper gets removed correctly. No idea why.
      return [SKAction.run(block), SKAction.wait(forDuration: duration)]
      }
    let actionsToRun: [SKAction] = nestedActionsToRun.flatMap{$0}
    run(SKAction.sequence(actionsToRun)) {
      lastNode?.removeFromParent()
      // All bumpers have been removed
      completion?()
    }
  }
  
  func playerCollided(with node: SKNode) {
    guard !gamePaused else {
      return
    }
    gamePaused = true
    if node.name == "exitFence" {
      let scale = SKAction.scale(to: 0.001, duration: 0.4)
      let remove = SKAction.removeFromParent()
      let sequence = SKAction.sequence([scale, remove])
      player.run(sequence) {
        self.tearDownLevelUI() {
          self.level += 1
          if self.level > self.levelsToWin {
            self.runCelebration()
          } else {
            self.loadLevel()
          }
        }
      }
    } else if node.name == "bumper" {
      var position = CGPoint()
      switch edge(for: node.position) {
      case .top:
        position = CGPoint(x: node.position.x, y: player.position.y + tileDepth / 2)
      case .bottom:
        position = CGPoint(x: node.position.x, y: player.position.y - tileDepth / 2)
      case .right:
        position = CGPoint(x: player.position.x + tileDepth / 2, y: node.position.y)
      case .left:
        position = CGPoint(x: player.position.x - tileDepth / 2, y: node.position.y)
      }
      
      let moveEffect = SKTMoveEffect(node: node, duration: 0.6, startPosition: node.position, endPosition: position)
      moveEffect.timingFunction = SKTTimingFunctionBounceEaseOut
      let moveAction = SKAction.actionWithEffect(moveEffect)
      
      let removeColorization = SKAction.colorize(withColorBlendFactor: 0, duration: 0.6)
      let moveAndRemoveColorization = SKAction.group([moveAction, removeColorization])
      let addColorizationBack = SKAction.colorize(withColorBlendFactor: 1, duration: 0.2)
      let bumperSequence = SKAction.sequence([moveAndRemoveColorization, addColorizationBack])
      
      node.run(bumperSequence)
      
      let fadeDuration = 0.6
      let fade = SKAction.fadeOut(withDuration: TimeInterval(fadeDuration))
      let wait = SKAction.wait(forDuration: TimeInterval(fadeDuration))
      let remove = SKAction.removeFromParent()
      let sequence = SKAction.sequence([fade, wait, remove])
      player.run(sequence) { [unowned self] in
        self.tearDownLevelUI(leaving: node) {
          self.runCelebration()
        }
      }
    }
  }
  
  func didBegin(_ contact: SKPhysicsContact) {
    if contact.bodyA.node == player {
      playerCollided(with: contact.bodyB.node!)
    } else if contact.bodyB.node == player {
      playerCollided(with: contact.bodyA.node!)
    }
  }
  
  override func update(_ currentTime: TimeInterval) {
    guard !gamePaused else {
      return
    }
    #if (arch(i386) || arch(x86_64)) // Running on simulator. Adjust gravity based on touch events
      if let lastTouchPosition = lastTouchPosition {
        let diff = CGPoint(x: lastTouchPosition.x - player.position.x , y: lastTouchPosition.y - player.position.y)
        physicsWorld.gravity = CGVector(dx: diff.x / 100, dy: diff.y / 100)
      } else {
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
      }
    #else // Running on device. Adjust gravity based accelerometer
      if let accelerometerData = motionManager.accelerometerData {
        let accelerationX = accelerometerData.acceleration.x
        let accelerationY = accelerometerData.acceleration.y
        let dx = -accelerationY
        let dy = accelerationX
        
        physicsWorld.gravity = CGVector(dx: dx, dy: dy)
      }
    #endif
  }
}

// MARK: - Celebration animations

extension GameScene {
  func runCelebration() {
    gameOver = true
    
    if self.level > self.levelsToWin {
      self.closingMessage = SKSpriteNode(imageNamed: "congratulations")
    } else {
      self.closingMessage = SKSpriteNode(imageNamed: "try_again")
    }
    self.closingMessage.zPosition = 1000
    self.closingMessage.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
    self.closingMessage.name = "closingMessage"
    self.addChild(self.closingMessage)
  }
  
  func removeCelebration() {
    closingMessage.removeFromParent()
    
    level = 1
    loadLevel()
    gameOver = false
  }
}

// MARK: - Handle touches

extension GameScene {
  func handleTap() {
    if gameOver {
      removeCelebration()
    }
  }
}

