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

import SpriteKit

class FollowPathScene: SKScene {
  var player: SKSpriteNode!
  var playerPath = SKShapeNode()
  var message: SKLabelNode!
  override func sceneDidLoad() {
    playerPath.lineWidth = 4
    playerPath.strokeColor = UIColor(red: 33 / 255.0,
      green: 235 / 255.0,
      blue: 235 / 255.0,
      alpha: 0.2)
    addChild(playerPath)
    
    player = SKSpriteNode(imageNamed: "orb")
    addChild(player)
    
    let singleLineMessage = SKLabelNode()
    singleLineMessage.fontSize = min(size.width, size.height) / 3
    singleLineMessage.verticalAlignmentMode = .center
    singleLineMessage.text = "Your 25\ndaily rolls\nare here!"
    message = singleLineMessage.multilined()
    message.position = CGPoint(x: frame.midX, y: frame.midY)
    message.zPosition = 1001
    message.alpha = 0
    addChild(message)
    play()
  }
  
  func play() {
    // 1
    let numPoints = 6
    // 2
    var randomPoints: [CGPoint] = (-2...(numPoints + 2)).map {
      column -> CGPoint in
      let x = frame.width / CGFloat(numPoints) * CGFloat(column)
      // 3
      let minY = player.size.height / 4 * 3
      let maxY = frame.height - player.size.height / 4 * 3
      let y = (frame.height * CGFloat.random()).clamped(minY, maxY)
      return CGPoint(x: x, y: y)
    }
    // 4
    let swapQuantity = numPoints / 2
    let midindex = randomPoints.count / 2
    let swapRange =
      (midindex - swapQuantity / 2)...(midindex + swapQuantity / 2)
    randomPoints[swapRange] =
      ArraySlice(randomPoints[swapRange].reversed())
    // 5
    guard let path = UIBezierPath(
      catmullRomInterpolatedPoints: randomPoints,
      closed: false,
      alpha: 0.5) else {
        return
    }
    // 6
    playerPath.path = path.cgPath
    
    let traverseDuration = 3.0
    let traverse = SKAction.follow(path.cgPath,
                                   asOffset: false,
                                   orientToPath: false,
                                   duration: traverseDuration)
    let traverseForwardsAndBackwards = SKAction.run {
      let sequence = SKAction.sequence([traverse, traverse.reversed()])
      self.player.run(sequence)
    }
    
    let waitForTraverse =
      SKAction.wait(forDuration: traverseDuration)
    let fadeOutPathAndBall = SKAction.run {
      self.playerPath.run(
        SKAction.fadeOut(withDuration: traverseDuration))
      self.player.run(SKAction.fadeOut(
        withDuration: traverseDuration))
    }
    let waitForHalfTraverse =
      SKAction.wait(forDuration: traverseDuration / 2)
    let revealMessage = SKAction.run {
      let scaleEffect = SKTScaleEffect(
        node: self.message,
        duration: traverseDuration / 3,
        startScale: CGPoint(x: 0.01, y: 0.01),
        endScale: CGPoint(x: 1, y: 1))
      scaleEffect.timingFunction = SKTTimingFunctionBounceEaseOut
      let scaleEffectAction = SKAction.actionWithEffect(scaleEffect)
      let fadeIn =
        SKAction.fadeIn(withDuration: traverseDuration / 3)
      let group =
        SKAction.group([fadeIn, scaleEffectAction])
      self.message.run(group)
    }
    let sequence = SKAction.sequence([traverseForwardsAndBackwards,
      waitForTraverse,
      fadeOutPathAndBall,
      waitForHalfTraverse,
      revealMessage])
    run(sequence)
  }
}
