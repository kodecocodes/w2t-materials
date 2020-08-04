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

import Foundation
import WatchKit
import WatchConnectivity
import CoreMotion

// WatchConnectivity requires NSObject
class PedometerData: NSObject, WCSessionDelegate {
  let pedometer = CMPedometer()
  
  // sample pedometer data: set these two properties to zero
  var totalSteps = 0
  var totalDistance: CGFloat = 0.0
  
  var steps = 0
  var distance: CGFloat = 0.0
  var prevTotalSteps = 0
  var prevTotalDistance: CGFloat = 0.0
  let distanceUnit = Locale.current.usesMetricSystem ? "km" : "mi"

  var appStartDate: Date!
  var startOfDay: Date!
  var endOfDay: Date!
  let calendar = Calendar()
  
  var session: WCSession?
  
  override init() {
    super.init()
    
    if (WCSession.isSupported()) {
      session = WCSession.default
      session!.delegate = self
      session!.activate()
    }
    
    setStartAndEndOfDay()
    if !loadSavedData() {
      appStartDate = startOfDay
      saveData()
      startLiveUpdates()
    }
  }
  
  func setStartAndEndOfDay() {
    startOfDay = calendar.startOfToday as Date!
    endOfDay = calendar.startOfNextDay(startOfDay)
  }
  
  // MARK: Pedometer Data
  enum PedometerDataType { case live, history }
  func updateProperties(from data: CMPedometerData, ofType type: PedometerDataType) {
    switch type {
    case .live:  // 1
      totalSteps = data.numberOfSteps.intValue
      steps = totalSteps - prevTotalSteps
      if let rawDistance = data.distance?.intValue, rawDistance > 0 {
          totalDistance = CGFloat(rawDistance) / 1000.0
          distance = totalDistance - prevTotalDistance
      }
    case .history:  // 2
      steps = data.numberOfSteps.intValue
      totalSteps = steps + prevTotalSteps
      if let rawDistance = data.distance?.intValue, rawDistance > 0 {
          distance = CGFloat(rawDistance) / 1000.0
          totalDistance = distance + prevTotalDistance
      }
    }
  }
  
  func startLiveUpdates() {
    guard CMPedometer.isStepCountingAvailable() else { return }
    pedometer.startUpdates(from: appStartDate) { data, error in
      if let data = data {
        // 1
        if self.calendar.isDate(data.endDate, afterDate: self.endOfDay) {
          // 2
          self.pedometer.stopUpdates()
          // 3
          self.queryHistory(from: self.startOfDay, to: self.endOfDay)
          return
        }
        self.updateProperties(from: data, ofType: .live)
        self.sendData(false)
      }
    }
  }
  
  func queryHistory(from start: Date, to end: Date) {
    guard CMPedometer.isStepCountingAvailable() else {
      return
    }
    pedometer.queryPedometerData(from: start, to: end) { data, error in
      if let data = data {
        self.updateProperties(from: data, ofType: .history)
        self.sendData(true)
        // update and save day-dependent properties
        self.setStartAndEndOfDay()
        self.prevTotalSteps = self.totalSteps
        self.prevTotalDistance = self.totalDistance
        self.saveData()
        
        self.startLiveUpdates()
      }
    }
  }
  
  // MARK: - Watch Connectivity
  
  func sendData(_ dayEnded: Bool) {
    guard let session = session else {
      return
    }
    let applicationDict: [String : Any] = ["dayEnded": dayEnded, "steps":steps,
      "distance":distance, "totalSteps": totalSteps,
      "totalDistance": totalDistance]
    session.transferUserInfo(applicationDict)
  }
  
  // WCSessionDelegate method
  
  func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    
  }
  
  // MARK: - Data Persistence
  
  func saveData() {
    UserDefaults.standard.set(appStartDate, forKey: "appStartDate")
    UserDefaults.standard.set(startOfDay, forKey: "startOfDay")
    UserDefaults.standard.set(endOfDay, forKey: "endOfDay")
    UserDefaults.standard.set(prevTotalSteps, forKey: "prevTotalSteps")
    UserDefaults.standard.set(prevTotalDistance, forKey: "prevTotalDistance")
  }
  
  func loadSavedData() -> Bool {
    guard let savedAppStartDate = UserDefaults.standard.object(forKey: "appStartDate") as? Date else {
      return false
    }
    appStartDate = savedAppStartDate
    let savedStartOfDay = UserDefaults.standard.object(forKey: "startOfDay") as! Date
    let savedEndOfDay = UserDefaults.standard.object(forKey: "endOfDay") as! Date
    if calendar.isDate(calendar.now, afterDate: savedEndOfDay) {
      // query history to finalize data for missing day
      queryHistory(from: savedStartOfDay, to: savedEndOfDay)
    } else {
      prevTotalSteps = UserDefaults.standard.object(forKey: "prevTotalSteps") as! Int
      prevTotalDistance = UserDefaults.standard.object(forKey: "prevTotalDistance") as! CGFloat
      startLiveUpdates()
    }
    
    return true
  }
  
}
