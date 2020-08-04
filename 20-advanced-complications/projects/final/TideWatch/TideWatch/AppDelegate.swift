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
import WatchConnectivity

let PhoneUpdatedDataNotification = "PhoneUpdatedDataNotification"
let WatchUpdatedDataNotification = "WatchUpdatedDataNotification"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, WCSessionDelegate {
  
  var window: UIWindow?
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]?) -> Bool {
    // Override point for customization after application launch.
    setupWatchConnectivity()
    setupNotificationCenter()
    return true
  }
  
  // MARK: - Notification Center
  private func setupNotificationCenter() {
    let notificationCenter = NotificationCenter.default
    notificationCenter.addObserver(forName: NSNotification.Name(rawValue: PhoneUpdatedDataNotification), object: nil, queue: nil) { notification in
      self.sendUpdatedDataToWatch(notification)
    }
  }
  
  private func sendUpdatedDataToWatch(_ notification: Notification) {
    if WCSession.isSupported() {
      let session = WCSession.default
      if session.isWatchAppInstalled,
        let conditions = notification.userInfo?["conditions"]
          as? TideConditions, let isNewStation =
          (notification.userInfo?["newStation"]
          as? NSNumber)?.boolValue {
        do {
          let data =
            NSKeyedArchiver.archivedData(withRootObject: conditions)
          let dictionary = ["data": data]
          // Transfer complications info
          if isNewStation {
            session.transferCurrentComplicationUserInfo(dictionary)
          } else {
            try session.updateApplicationContext(dictionary)
          }
        } catch {
          print("ERROR: \(error)")
        }
      }
    }
  }
  
  // MARK: - Watch Connectivity
  private func setupWatchConnectivity() {
    if WCSession.isSupported() {
      let session = WCSession.default
      session.delegate = self
      session.activate()
    }
  }

  func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    if let error = error {
      NSLog("Error activiting: \(error)")
    }
  }

  func sessionDidDeactivate(_ session: WCSession) {

  }

  func sessionDidBecomeInactive(_ session: WCSession) {
    
  }
  
  func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
    if let data = applicationContext["data"] as? Data {
      if let tideConditions = NSKeyedUnarchiver.unarchiveObject(with: data) as? TideConditions {
        TideConditions.saveConditions(tideConditions)
        DispatchQueue.main.async {
          let notificationCenter = NotificationCenter.default
          notificationCenter.post(name: Notification.Name(rawValue: WatchUpdatedDataNotification), object: self, userInfo:["conditions":tideConditions])
        }
      }
    }
  }
}

