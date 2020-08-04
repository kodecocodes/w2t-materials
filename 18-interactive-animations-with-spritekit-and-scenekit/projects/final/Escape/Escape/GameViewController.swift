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

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
  
  var scene: GameScene!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    guard let view = self.view as! SKView? else {
      return
    }

    scene = GameScene(size: view.frame.size)
    
    // Present the scene
    view.presentScene(scene)
    
    view.ignoresSiblingOrder = true
    
    view.showsFPS = true
    view.showsNodeCount = true
  }
  
  @IBAction func tapRecognized(_ sender: UITapGestureRecognizer) {
    scene.handleTap()
  }
  
  @IBAction func gestureRecognized(_ sender: AnyObject) {
    // 1
    guard let gesture = sender as? UIGestureRecognizer else {
      return
    }
    // 2
    switch gesture.state {
    case .began, .changed:
      let location = gesture.location(in: view)
      // 3
      let y = view.frame.size.height - location.y
      scene.lastTouchPosition = CGPoint(x: location.x, y: y)
    default:
      scene.lastTouchPosition = nil
    }
  }
  
}
