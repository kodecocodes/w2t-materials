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

class ProgressView: UIView {
  @IBOutlet weak var progressLabel: UILabel!
  @IBOutlet weak var progressBarView: UIView!
  @IBOutlet weak var progressBarLeftConstraint: NSLayoutConstraint!
  @IBOutlet weak var completeImage: UIImageView!
    
  var total = 1
  var current = 1
  
  override func updateConstraints() {
    super.updateConstraints()
    if (total > 0) {
      let progress = CGFloat(current)/CGFloat(total)
      let width = bounds.width

      let randomOffset: CGFloat
      if (current != 0 && current != total) {
        // Spice it up by adding a bit of randomness
        let wiggleRoom = width / CGFloat(total)
        let randomFloat = CGFloat(Float(arc4random()) / Float(UINT32_MAX))
        randomOffset = (wiggleRoom * randomFloat) - wiggleRoom / 2
      }
      else {
        randomOffset = 0
      }
      
      progressBarLeftConstraint.constant = progress * width + randomOffset
    }
  }
  
  func update(_ color: UIColor, current: Int, total: Int) {
    self.current = current
    self.total = total
    
    progressBarView.backgroundColor = color
    progressLabel.text = "\(current)/\(total)"
    
    completeImage.isHidden = current != total
    progressLabel.isHidden = !completeImage.isHidden
    
    setNeedsUpdateConstraints()
  }
}
