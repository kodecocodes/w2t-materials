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

class MainInterfaceController: WKInterfaceController, WCSessionDelegate {
  @IBOutlet var walkTable: WKInterfaceTable!
  
  lazy var walks: [Walk] = {
    let path = Bundle.main.path(forResource:"Walks", ofType: "plist")
    let arrayOfDicts = NSArray(contentsOfFile: path!)!
    var array = [Walk]()
    for i in 0..<arrayOfDicts.count {
      let walk = Walk.convertDictToWalk(arrayOfDicts[i] as! [String : AnyObject])
      array.append(walk)
    }
    return array as Array
    }()
  
  let data = PedometerData()
  
  override func awake(withContext context: Any?) {
    super.awake(withContext: context)
  }
  
  override func willActivate() {
    loadTable()
  }
  
  func loadTable() {
    walkTable.setNumberOfRows(walks.count, withRowType: "walkRow")
    for i in 0..<walks.count {
      let controller = walkTable.rowController(at: i) as! WalkRowController
      controller.titleLabel.setText(walks[i].walkTitle)
      
      // completions; hide star if < 1
      let completions = data.totalDistance / CGFloat(walks[i].goal)
      controller.starLabel.setHidden(completions < 1.0)
      
      // progress bar
      let fraction = completions.fraction()
      controller.progressGroup.setWidth(fraction * contentFrame.size.width)
      controller.progressGroup.setBackgroundColor(Walk.progressColors[Walk.progressIndex(fraction)])
    }
  }
  
  override func contextForSegue(withIdentifier segueIdentifier: String, in table: WKInterfaceTable, rowIndex: Int) -> Any? {
    return [walks[rowIndex], data]
  }
  
  // WCSessionDelegate method
  
  func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    
  }

}
