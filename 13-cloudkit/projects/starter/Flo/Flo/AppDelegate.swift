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
import CloudKit
import WatchConnectivity
// WatchConnectivity notifications
let NotificationDrinkDateOnWatch = "DrinkDateOnWatch"
let NotificationiPhoneDataUpdated = "iPhoneDataUpdated"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  let ckCentral = CloudKitCentral.sharedInstance()
  lazy var notificationCenter: NotificationCenter = {
    return NotificationCenter.default
  }()

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
    application.registerForRemoteNotifications()

    setupWatchConnectivity()
    setupNotificationCenter()
    
    return true
  }
  
  // MARK: - Notification Center for WC
  private func setupNotificationCenter() {
    notificationCenter.addObserver(forName: NSNotification.Name(rawValue: NotificationiPhoneDataUpdated), object: nil, queue: nil) { (notification:Notification) -> Void in
      self.sendFloDataToWatch(notification)
    }
  }

  // MARK: - CloudKit notifications
  // NOTE: remote notifications are not supported in the simulator
  func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    print("didRegisterForRemoteNotificationsWithDeviceToken \(deviceToken)")
  }
  
  func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    print("didFailToRegisterForRemoteNotificationsWithError ERROR: \(error.localizedDescription)")
  }

  func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    let notification = CKNotification(fromRemoteNotificationDictionary: userInfo as! [String : NSObject])
    if notification.subscriptionID == "new-drink-event" {
      ckCentral.qos = .utility
      ckCentral.fetchDatabaseChanges {
        completionHandler(.newData)
      }
    }
  }

}

// MARK: - Watch Connectivity
extension AppDelegate: WCSessionDelegate {
  
  func setupWatchConnectivity() {
    if WCSession.isSupported() {
      let session = WCSession.default
      session.delegate = self
      session.activate()
    }
  }
  
  func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
    if let watchDate = applicationContext["watchDate"] as? Date {
      print("didReceiveApplicationContext from Watch: \(watchDate)")
      ckCentral.saveDate(watchDate, viaWC: true)
    }
  }
  
  func sendFloDataToWatch(_ notification: Notification) {
    guard WCSession.isSupported() && WCSession.default.isWatchAppInstalled else { return }
    
    let floData = FloData.sharedInstance()
    let currentDrinkTotal = floData.drinkTotal
    print("sendFloDataToWatch drinkTotal \(floData.drinkTotal)")
    do {
      let dictionary = [LocalCache.startDate.rawValue: floData.startDate, LocalCache.drinkTotal.rawValue: currentDrinkTotal] as [String : Any]
      try WCSession.default.updateApplicationContext(dictionary as [String : AnyObject])
    } catch {
      print("sendFloDataToWatch ERROR: \(error.localizedDescription)")
    }
  }
  
  func sessionDidBecomeInactive(_ session: WCSession) {
    print("WC Session did become inactive")
  }
  
  func sessionDidDeactivate(_ session: WCSession) {
    print("WC Session did deactivate")
    WCSession.default.activate()
  }
  
  func session(_ session: WCSession, activationDidCompleteWith
    activationState: WCSessionActivationState, error: Error?) {
    if let error = error {
      print("WC Session activation failed with error: " +
        "\(error.localizedDescription)")
      return
    }
    print("WC Session activated with state: " +
      "\(activationState.rawValue)")
  }
  
}

