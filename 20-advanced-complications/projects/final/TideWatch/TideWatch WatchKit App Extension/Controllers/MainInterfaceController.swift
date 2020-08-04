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

class MainInterfaceController: WKInterfaceController {
  @IBOutlet var nameLabel: WKInterfaceLabel!
  @IBOutlet var stateLabel: WKInterfaceLabel!
  @IBOutlet var waterLevelLabel: WKInterfaceLabel!
  @IBOutlet var averageWaterLevelLabel: WKInterfaceLabel!
  @IBOutlet var tideLabel: WKInterfaceLabel!
  
  var tideConditions: TideConditions = TideConditions.loadConditions()
  
  override func awake(withContext context: Any?) {
    super.awake(withContext: context)
  }
  
  override func willActivate() {
    super.willActivate()
    populateStationData()
    populateTideData()
    refresh()
    let notificationCenter = NotificationCenter.default
    notificationCenter.addObserver(forName: NSNotification.Name(rawValue: PhoneUpdatedDataNotification), object: nil, queue: nil) { notification in
      if let conditions = notification.object as? TideConditions {
        self.tideConditions = conditions;
        DispatchQueue.main.async {
          self.populateStationData()
          self.populateTideData()
        }
      }
    }
  }
  
  override func didDeactivate() {
    super.didDeactivate()
    let notificationCenter = NotificationCenter.default
    notificationCenter.removeObserver(self)
  }
  
  override func contextForSegue(withIdentifier segueIdentifier: String) -> Any? {
    return tideConditions
  }
}

// MARK: Load Data
extension MainInterfaceController {
  func refresh() {
    let yesterday = Date(timeIntervalSinceNow: -24 * 60 * 60)
    let tomorrow = Date(timeIntervalSinceNow: 24 * 60 * 60)
    tideConditions.loadWaterLevels(from: yesterday, to: tomorrow) { success in
      DispatchQueue.main.async {
        if success {
          self.populateTideData()
          TideConditions.saveConditions(self.tideConditions)
          let notificationCenter = NotificationCenter.default
          notificationCenter.post(name: Notification.Name(rawValue: WatchUpdatedDataNotification), object: self.tideConditions)
        }
        else {
          print("Failed to load station: \(self.tideConditions.station.name)")
        }
      }
    }
  }
  
  func populateStationData() {
    nameLabel.setText(tideConditions.station.name)
    stateLabel.setText(tideConditions.station.state)
  }
  
  func populateTideData() {
    guard tideConditions.waterLevels.count > 0 else {
      waterLevelLabel.setText("--")
      tideLabel.setText("--")
      averageWaterLevelLabel.setText("--")
      return
    }
    
    if let currentWaterLevel = tideConditions.currentWaterLevel {
      waterLevelLabel.setText(String(format: "%.1fm", currentWaterLevel.height))
      tideLabel.setText(currentWaterLevel.situation.rawValue)
    }
    averageWaterLevelLabel.setText(String(format: "%.1fm", tideConditions.averageWaterLevel))
  }
}
