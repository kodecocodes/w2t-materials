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


class ScheduleInterfaceController: WKInterfaceController {
  
  @IBOutlet var table: WKInterfaceTable!
  
  override func awake(withContext context: Any?) {
    super.awake(withContext: context)
    
    let upcomingMatches = season.upcomingMatches
    
    table.setNumberOfRows(upcomingMatches.count, withRowType: "ScheduleRowType")
    
    for (index, match) in upcomingMatches.enumerated() {
      updateRow(at: index, with: match)
    }
    
  }
  
  override func contextForSegue(withIdentifier segueIdentifier: String, in table: WKInterfaceTable, rowIndex: Int) -> Any? {
    return rowIndex
  }
  
  override func willActivate() {
    // This method is called when watch view controller is about to be visible to user
    super.willActivate()
  }
  
  override func didDeactivate() {
    // This method is called when watch view controller is no longer visible
    super.didDeactivate()
  }
  
  func updateRow(at index: Int, with match: Match) {
    guard let row = table.rowController(at: index) as? ScheduleRow else {
      return
    }
    row.opponentLabel.setText(match.opponent.name)
    row.dateLabel.setText("\(match.date.simpleDate) @ \(match.date.simpleTime)")
    row.opponentLogo.setImageNamed(match.opponent.logoName)
  }
  
  @IBAction func addButtonPressed() {
    let match = Match(on: Date().tomorrow)
    season.matches.append(match)
    let matchIndex = season.upcomingMatches.index(of: match)!
    table.insertRows(at: [matchIndex], withRowType: "ScheduleRowType")
    updateRow(at: matchIndex, with: match)
  }
  
  @IBAction func removeButtonPressed() {
    guard let match = season.upcomingMatches.first, let matchIndex = season.matches.index(of: match) else {
      return
    }
    season.matches.remove(at: matchIndex)
    table.removeRows(at: [0])
  }
}
