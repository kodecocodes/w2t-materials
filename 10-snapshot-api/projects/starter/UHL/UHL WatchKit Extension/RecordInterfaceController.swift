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


class RecordInterfaceController: WKInterfaceController {
  
  @IBOutlet var table: WKInterfaceTable!
  
  override func awake(withContext context: Any?) {
    super.awake(withContext: context)
    
    let playedMatches = season.playedMatches
    
    table.setNumberOfRows(playedMatches.count, withRowType: "RecordRowType")
    
    for (index, match) in playedMatches.reversed().enumerated() {
      updateRow(at: index, with: match)
    }
    
    updateTitle()
  }
  
  override func willActivate() {
    // This method is called when watch view controller is about to be visible to user
    super.willActivate()
  }
  
  override func didDeactivate() {
    // This method is called when watch view controller is no longer visible
    super.didDeactivate()
  }

  func updateTitle() {
    self.setTitle(season.record)
  }
  
  func updateRow(at index: Int, with match: Match) {
    guard let row = table.rowController(at: index) as? RecordRow else {
      return
    }
    
    row.homeNameLabel.setText(match.home.name)
    row.homeLogo.setImageNamed(match.home.logoName)
    
    row.awayNameLabel.setText(match.away.name)
    row.awayLogo.setImageNamed(match.away.logoName)

    row.dateLabel.setText(match.date.mediumDate)
    
    guard let homeScore = match.score(for: match.home), let awayScore = match.score(for: match.away) else {
      return
    }
    
    row.homeScoreLabel.setText("\(homeScore)")
    row.awayScoreLabel.setText("\(awayScore)")
    
    
    var group: WKInterfaceGroup?
    var label: WKInterfaceLabel?
    
    if homeScore > awayScore {
      group = row.homeGroup
      label = row.homeScoreLabel
    } else if homeScore < awayScore {
      group = row.awayGroup
      label = row.awayScoreLabel
    }
    
    let imageName = ourTeam == match.winner ? "win-triangle" : "lose-triangle"

    let green = UIColor(red: 78 / 255.0, green: 216 / 255.0, blue: 102 / 255.0, alpha: 1.0)
    let red = UIColor(red: 255 / 255.0, green: 49 / 255.0, blue: 81 / 255.0, alpha: 1.0)
    let color = ourTeam == match.winner ? green : red
    
    group?.setBackgroundImageNamed(imageName)
    label?.setTextColor(color)
  }
  
  @IBAction func playNowButtonPressed() {
    let match = Match()
    season.matches.append(match)
    table.insertRows(at: [0], withRowType: "RecordRowType")
    updateRow(at: 0, with: match)
    updateTitle()
  }
  
  @IBAction func removeLastButtonPressed() {
    guard let match = season.playedMatches.last, let matchIndex = season.matches.index(of: match) else {
      return
    }
    season.matches.remove(at: matchIndex)
    table.removeRows(at: [0])
    updateTitle()
  }
}
