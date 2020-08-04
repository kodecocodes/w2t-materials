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

import WatchKit
import Foundation


class ScheduleDetailInterfaceController: WKInterfaceController {
  
  @IBOutlet var opponentNameLabel: WKInterfaceLabel!
  @IBOutlet var opponentLogo: WKInterfaceImage!
  @IBOutlet var dateLabel: WKInterfaceLabel!
  @IBOutlet var timeLabel: WKInterfaceLabel!
  @IBOutlet var locationLabel: WKInterfaceLabel!
  @IBOutlet var advantageLabel: WKInterfaceLabel!
  
  override func awake(withContext context: Any?) {
    super.awake(withContext: context)
        
    guard let upcomingMatchIndex = context as? Int else {
      return
    }
    
    let match = season.upcomingMatches[upcomingMatchIndex]
    
    opponentNameLabel.setText("vs \(match.opponent.name)")
    
    opponentLogo.setImageNamed(match.opponent.logoName)
    
    dateLabel.setText(match.date.mediumDate)
    
    timeLabel.setText("@ \(match.date.simpleTime)")
    
    locationLabel.setText(match.location.name)
    
    let advantage =  match.home == ourTeam ? "(home)" : "(away)"
    
    advantageLabel.setText(advantage)
  }
  
  override func willActivate() {
    // This method is called when watch view controller is about to be visible to user
    super.willActivate()
    
    
  }
  
  override func didDeactivate() {
    // This method is called when watch view controller is no longer visible
    super.didDeactivate()
  }
  
}
