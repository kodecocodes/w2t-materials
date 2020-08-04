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
import WatchKit

class OngoingTaskRowController: NSObject {
  static let RowType = "OngoingTaskRow"
  
  @IBOutlet var group: WKInterfaceGroup!

  @IBOutlet var spacerGroup: WKInterfaceGroup!
  @IBOutlet var nameLabel: WKInterfaceLabel!
  @IBOutlet var progressLabel: WKInterfaceLabel!
  
  @IBOutlet var progressBackgroundGroup: WKInterfaceGroup!
  @IBOutlet var progressGroup: WKInterfaceGroup!
  
}

/** NOTES:
  Should be able to adjust progressGroup using RELATIVE WIDTH
  However, currently that only adjusts the width to 3 values, 0, 0.5, 1
  Thus, the frameWidth is needed as a workaround
**/
extension OngoingTaskRowController {
  func populate(with task:Task, frameWidth:CGFloat) {
    nameLabel.setText(task.name)
    
    updateProgress(with:task, frameWidth:frameWidth)
  }
  
  func updateProgress(with task:Task, frameWidth:CGFloat) {
    progressLabel.setText("\(task.totalTimes - task.timesCompleted)")
    
    progressBackgroundGroup.setBackgroundColor(task.color.color.withAlphaComponent(0.15))
    progressGroup.setBackgroundColor(task.color.color)
    
    let progressLeft = 1.0 - CGFloat(task.timesCompleted) / CGFloat(task.totalTimes)
    
    progressGroup.setWidth(progressLeft * frameWidth)
  }
}
