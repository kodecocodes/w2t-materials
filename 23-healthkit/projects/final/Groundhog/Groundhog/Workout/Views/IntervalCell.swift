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

class IntervalCell: UITableViewCell {
  
  // ****** Models
  var interval: IntervalWorkoutInterval? {
    
    willSet(newInterval) {
      guard let newInterval = newInterval else {
        durationLabel?.text = ""
        distanceLabel?.text = ""
        heartRateLabel?.text = ""
        caloriesLabel?.text = ""
        return
      }
      
      // Duration
      if let elapsedTime = elapsedTimeFormatter.string(from: (newInterval.duration)) {
        durationLabel?.text = elapsedTime
      } else {
        durationLabel?.text = ""
      }
      
      // Distance
      if let distance = newInterval.distance {
        distanceLabel?.text = distanceFormatter.string(fromValue: distance, unit: distanceFormatterUnit)
      } else {
        distanceLabel?.text = ""
      }
      
      // Heart Rate
      if let heartRate = newInterval.averageHeartRate {
        heartRateLabel?.text = numberFormatter.string(from: NSNumber(value: heartRate))! + " bpm"
      } else {
        heartRateLabel?.text = "No HR"
      }
      
      // Calories
      if let calories = newInterval.calories {
        caloriesLabel?.text = calorieFormatter.string(fromValue: calories, unit: energyFormatterUnit)
      } else {
        caloriesLabel?.text = ""
      }
    }
  }

  // ****** Interface Elements
  @IBOutlet weak var durationLabel: UILabel!
  @IBOutlet weak var distanceLabel: UILabel!
  @IBOutlet weak var heartRateLabel: UILabel!
  @IBOutlet weak var caloriesLabel: UILabel!
  
}
