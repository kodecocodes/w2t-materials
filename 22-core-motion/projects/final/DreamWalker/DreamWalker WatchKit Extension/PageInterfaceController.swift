/**
 * Copyright (c) 2016 Razeware LLC
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
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import WatchKit
import Foundation
import WatchConnectivity

class PageInterfaceController: WKInterfaceController, WCSessionDelegate {
  
  @IBOutlet var topGroup: WKInterfaceGroup!
  @IBOutlet var goalLabel: WKInterfaceLabel!
  @IBOutlet var progressGroup: WKInterfaceGroup!
  @IBOutlet var completionsLabel: WKInterfaceLabel!
  @IBOutlet var totalStepsLabel: WKInterfaceLabel!
  @IBOutlet var totalStepsMsgLabel: WKInterfaceLabel!
  @IBOutlet var totalDistanceLabel: WKInterfaceLabel!
  @IBOutlet var totalDistanceUnitLabel: WKInterfaceLabel!
  @IBOutlet var totalDistanceMsgLabel: WKInterfaceLabel!
  @IBOutlet var stepsLabel: WKInterfaceLabel!
  @IBOutlet var distanceLabel: WKInterfaceLabel!
  
  var data: PedometerData!
  var walk: Walk!
  
  let distanceMsgs = ["Ready, set go!",
    "Good progress!",
    "Now you're moving!",
    "You're nearly there!"]
  let stepMsgs = ["It starts with 1 step",
    "They add up fast!",
    "Keep on keeping on...",
    "Give it your all!"]
  
  override func awake(withContext context: Any?) {
    super.awake(withContext: context)
    let context = context as! [AnyObject]
    walk = context[0] as! Walk
    setTitle(walk.walkTitle)
    data = context[1] as! PedometerData
  }
  
  override func willActivate() {
    super.willActivate()
    updateInterface()
  }
  
  func formattedString(_ x: CGFloat) -> String {
    return String(format:"%.1f", x)
  }
  
  func updateInterface() {
    topGroup.setBackgroundImage(UIImage(named: walk.imageName))
    stepsLabel.setText("\(data.steps)")
    totalStepsLabel.setText("\(data.totalSteps)")
    
    let goal = CGFloat(walk.goal)
    // distanceUnit-dependant text
    totalDistanceUnitLabel.setText(data.distanceUnit)
    if data.distanceUnit == "km" {
      goalLabel.setText(formattedString(goal) + " km")
      distanceLabel.setText(formattedString(data.distance))
      totalDistanceLabel.setText(formattedString(data.totalDistance))
    } else {
      goalLabel.setText(formattedString(goal.imperial()) + " mi")
      distanceLabel.setText(formattedString(data.distance.imperial()))
      totalDistanceLabel.setText(formattedString(data.totalDistance.imperial()))
    }
    
    // completions
    let completions = data.totalDistance / goal
    completionsLabel.setText(formattedString(completions))
    let fraction = completions.fraction()
    progressGroup.setWidth(fraction * contentFrame.size.width)
    
    // progress bar and messages
    let index = Walk.progressIndex(fraction)
    progressGroup.setBackgroundColor(Walk.progressColors[index])
    totalDistanceMsgLabel.setText(distanceMsgs[index])
    totalStepsMsgLabel.setText(stepMsgs[index])
  }
  
  // WCSessionDelegate method
  
  func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    
  }
  
}
