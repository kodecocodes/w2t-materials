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
import UserNotifications

extension Int {
  static func randomInt(_ min: Int, max:Int) -> Int {
    return min + Int(arc4random_uniform(UInt32(max - min + 1)))
  }
}

class InterfaceController: WKInterfaceController {
  
  @IBOutlet var table: WKInterfaceTable!
  
  override func awake(withContext context: Any?) {
    super.awake(withContext: context)
    setupTable()
    registerUserNotificationSettings()
    scheduleLocalNotification()
  }
  
  func setupTable() {
    let numberOfCatImages = 20
    table.setNumberOfRows(numberOfCatImages, withRowType: "CatRowType")
    for index in 1...numberOfCatImages {
      if let controller = table.rowController(at: index-1) as? CatImageRowController {
        let catImageName = String(format: "cat%02d", arguments: [index])
        controller.catImage.setImageNamed(catImageName)
      }
    }
  }
}

// Notification Methods

extension InterfaceController {
  
  func registerUserNotificationSettings() {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { (granted, error) in
      if granted {
        let viewCatsAction = UNNotificationAction(identifier: "viewCatsAction", title: "More Cats!", options: .foreground)
        let pawsomeCategory = UNNotificationCategory(identifier: "Pawsome", actions: [viewCatsAction], intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([pawsomeCategory])
        UNUserNotificationCenter.current().delegate = self
        print("⌚️⌚️⌚️Successfully registered notification support")
      } else {
        print("⌚️⌚️⌚️ERROR: \(String(describing: error?.localizedDescription))")
      }
    }
  }
  
  func scheduleLocalNotification() {
    
    UNUserNotificationCenter.current().getNotificationSettings { (settings) in
      if settings.alertSetting == .enabled {
        
        let catImageName = String(format: "cat images/local_cat%02d",
                                  arguments: [Int.randomInt(1, max: 20)])
        let catImageURL = Bundle.main.url(forResource: catImageName, withExtension: "jpg")
        let notificationAttachment = try! UNNotificationAttachment(identifier: catImageName, url: catImageURL!, options: .none)
        
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "Pawsome"
        notificationContent.subtitle = "Guess what time it is"
        notificationContent.body = "Pawsome time!"
        notificationContent.categoryIdentifier = "Pawsome"
        notificationContent.attachments = [notificationAttachment]
        
        var date = DateComponents()
        date.minute = 30
        let notificationTrigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)

        
        let notificationRequest = UNNotificationRequest(identifier: "Pawsome", content: notificationContent, trigger: notificationTrigger)
        
        UNUserNotificationCenter.current().add(notificationRequest) { (error) in
          if let error = error {
            print("⌚️⌚️⌚️ERROR:\(error.localizedDescription)")
          } else {
            print("⌚️⌚️⌚️Local notification was scheduled")
          }
        }
      } else {
        print("⌚️⌚️⌚️Notification alerts are disabled")
      }
    }
  }
}

// Notification Center Delegate
extension InterfaceController: UNUserNotificationCenterDelegate {
  func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    completionHandler([.alert, .sound])
  }
  
  func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
    completionHandler()
  }
}
