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
import MapKit
import WatchConnectivity

extension String {
  var NS: NSString { return (self as NSString) }
}

class WalksTableViewController: UITableViewController, WCSessionDelegate {
  var session: WCSession?
  
  lazy var walks: [Walk] = {
    let path = Bundle.main.path(forResource: "Walks", ofType: "plist")
    let arrayOfDicts = NSArray(contentsOfFile: path!)!
    var array = [Walk]()
    for i in 0..<arrayOfDicts.count {
      let walk = Walk.convertDictToWalk(arrayOfDicts[i] as! [String : AnyObject])
      array.append(walk)
    }
    return array as Array
    }()
  
  var history = [DayData]()
  var currentTotalDistance: CGFloat {
    return CGFloat(history[0].totalDistance)
  }
  let distanceUnit = Locale.current.usesMetricSystem ? "km" : "mi"
  
  override func viewDidLoad() {
    super.viewDidLoad()
    if !loadSavedData() {
      loadDayData()
    }
    
    // activate session *after* loading data, so receiver has somewhere to store data
    if (WCSession.isSupported()) {
//      print("Session supported")
      session = WCSession.default
      session!.delegate = self;
      session!.activate()
    } else {
      print("Session not supported")
    }
  }
  
  // MARK: - Table view data source
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return walks.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "WalkCell", for: indexPath)
    let walk = walks[(indexPath as NSIndexPath).row]
    cell.textLabel!.text = walk.walkTitle
    let formattedString = String(format:"%.1f", walk.completions(currentTotalDistance))
    if distanceUnit == "km" {
      cell.detailTextLabel!.text = walk.location + ": \(Int(walk.goal))km completed \(formattedString) times"
    } else {
      cell.detailTextLabel!.text = walk.location + ": \(Int(walk.goal.imperial()))mi completed \(formattedString) times"
    }
    
    return cell
  }
  
  // MARK: - Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "showWalk" {
      if let indexPath = self.tableView.indexPathForSelectedRow {
        let walk = walks[(indexPath as NSIndexPath).row]
        let walkController = segue.destination as! WalkViewController
        walkController.title = walk.walkTitle
        walkController.walk = walk
        walkController.distanceUnit = distanceUnit
        walkController.completions = walk.completions(currentTotalDistance)
        walkController.completionString = String(format:"%.1f", walkController.completions)
      }
    }
    
    if segue.identifier == "showHistory" {
      let historyController = segue.destination as! HistoryTableViewController
      historyController.history = history
      historyController.distanceUnit = distanceUnit
    }
  }
  
  // MARK: Watch Connectivity
  
  func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any]) {
    history[0].steps = userInfo["steps"] as! Int
    history[0].totalSteps = userInfo["totalSteps"] as! Int
    history[0].distance = userInfo["distance"] as! Double
    history[0].totalDistance = userInfo["totalDistance"] as! Double
    if let dayEnded = userInfo["dayEnded"] as? Bool, dayEnded == true {
      history.insert(DayData(), at: 0)
      history[0].totalSteps = history[1].totalSteps
      history[0].totalDistance = history[1].totalDistance
    }
    saveData()
    
    DispatchQueue.main.async {
      self.tableView.reloadData()
    }
  }
  
  // WCSessionDelegate methods
  
  func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    
  }
  
  func sessionDidBecomeInactive(_ session: WCSession) {
    
  }
  
  func sessionDidDeactivate(_ session: WCSession) {
    
  }
  
  // MARK: DayData persistence
  
  var savedDataPath: String {
    let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
    let docPath = paths.first!
    // is this NS hack still needed?
    return docPath.NS.appendingPathComponent("SavedData")
  }
  
  func loadSavedData() -> Bool {
    if let data = try? Data(contentsOf: URL(fileURLWithPath: savedDataPath)) {
      let savedData = NSKeyedUnarchiver.unarchiveObject(with: data) as! [DayData]
      history = savedData
      return true
    } else {
      return false
    }
  }
  
  func saveData() {
    if NSKeyedArchiver.archiveRootObject(history, toFile: savedDataPath) {
      print("data archived")
    } else {
      print("data not archived")
    }
  }
  
  // MARK: DayData
  // sample data from my Activity history
  // won't need this when watch is sending pedometer data
  
  func loadDayData() {
    var day = Date()
    history.append(DayData(date: day, steps: 0, distance: 0, totalSteps: 50258, totalDistance: 22.64))
    let secondsPerDay:TimeInterval = 86400
    day = day.addingTimeInterval(-secondsPerDay)
    history.append(DayData(date: day, steps: 1706, distance: 1.26, totalSteps: 50258, totalDistance: 22.64))
    day = day.addingTimeInterval(-secondsPerDay)
    history.append(DayData(date: day, steps: 7895, distance: 5.44, totalSteps: 48552, totalDistance: 21.38))
    day = day.addingTimeInterval(-secondsPerDay)
    history.append(DayData(date: day, steps: 3438, distance: 1.63, totalSteps: 40657, totalDistance: 15.94))
    day = day.addingTimeInterval(-secondsPerDay)
    history.append(DayData(date: day, steps: 2784, distance: 1.8, totalSteps: 37219, totalDistance: 14.31))
    day = day.addingTimeInterval(-secondsPerDay)
    history.append(DayData(date: day, steps: 2698, distance: 1.6, totalSteps: 34435, totalDistance: 12.51))
    day = day.addingTimeInterval(-secondsPerDay)
    history.append(DayData(date: day, steps: 100, distance: 0.08, totalSteps: 31737, totalDistance: 10.91))
    day = day.addingTimeInterval(-secondsPerDay)
    history.append(DayData(date: day, steps: 5985, distance: 1.89, totalSteps: 31637, totalDistance: 10.83))
    day = day.addingTimeInterval(-secondsPerDay)
    history.append(DayData(date: day, steps: 4814, distance: 1.84, totalSteps: 25652, totalDistance: 8.94))
    day = day.addingTimeInterval(-secondsPerDay)
    history.append(DayData(date: day, steps: 8291, distance: 5.65, totalSteps: 20838, totalDistance: 7.1))
    day = day.addingTimeInterval(-secondsPerDay)
    history.append(DayData(date: day, steps: 1205, distance: 0.48, totalSteps: 12547, totalDistance: 1.45))
    day = day.addingTimeInterval(-secondsPerDay)
    history.append(DayData(date: day, steps: 10199, distance: 0.78, totalSteps: 11342, totalDistance: 0.97))
    day = day.addingTimeInterval(-secondsPerDay)
    history.append(DayData(date: day, steps: 1143, distance: 0.19, totalSteps: 1143, totalDistance: 0.19))
  }
  
}
