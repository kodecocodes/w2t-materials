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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  
  /// The WatchConnectivity session to send poster images if needed.
  private var session: WCSession?
  
  /// A reference map to create poster images for each video clip and
  /// send them to the watch app.
  private let references = VideoClipProvider().clipReferences
  
  /// A convenient getter that returns a pointer to the root interface
  /// controller of the app.
  private var appRootViewController: BrowserViewController {
    return (window!.rootViewController as! UINavigationController).viewControllers.first! as! BrowserViewController
  }
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
    if WCSession.isSupported() {
      session = WCSession.default
      session!.delegate = self
      session!.activate()
    }
    return true
  }
  
  // MARK: Handoff
  
  func application(_ application: UIApplication, willContinueUserActivityWithType userActivityType: String) -> Bool {
    return true
  }
  
  func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
    print("Received: \(userActivity.userInfo ?? [:])")
    guard
      let userInfo = userActivity.userInfo,
      let version = userInfo[Handoff.version.key] as? Int,
      version == Handoff.version.number
      else { return false }
    let err =  NSError(domain: "foo", code: NSKeyValueValidationError, userInfo: [:])
    self.application(application, didFailToContinueUserActivityWithType: userActivity.activityType, error: err)
    appRootViewController.restoreUserActivityState(userActivity)
    return true
  }
  
  func application(_ application: UIApplication, didFailToContinueUserActivityWithType userActivityType: String, error: Error) {
    print("Handoff Error: \(error.localizedDescription)")
    let error = error as NSError
    guard error.code != NSUserCancelledError else {
      return
    }
    
    let message = "The connection to your other device may have been interrupted. Please try again."
    let title = "Handoff Error"
    
    let alertController = UIAlertController(dismissOnlyAlertWithTitle: title, message: message) as UIViewController
    appRootViewController.present(alertController, animated: true, completion: nil)
  }
}

// MARK: WatchConnectivity

extension AppDelegate: WCSessionDelegate {
  
  func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    print("📱 WCSession activationDidCompleteWith: \(activationState.rawValue)")
  }
  
  func sessionDidBecomeInactive(_ session: WCSession) {
    print("📱 WCSession sessionDidBecomeInactive.")
  }
  
  func sessionDidDeactivate(_ session: WCSession) {
    print("📱 WCSession sessionDidDeactivate.")
  }
  
  func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
    
    print("📱 WCSession received message: \(message)")
    
    guard let value = message[VideoClipProvider.WCPosterImageRequestKey] as? String else {
      print("📱 WCSession message not handled.")
      return
    }
    
    guard let URL = references[value] else {
      print("📱 WCSession message not handled.")
      return
    }
    
    guard let directory = session.watchDirectoryURL else {
      print("📱 WCSession failed to get watch directory URL.")
      return
    }
    
    let newSize = CGSize(width: 312.0, height: 234.0)
    let file = directory.appendingPathComponent(value)
    
    VideoUtilities.snapshot(fromMovieAtURL: URL, resizeTo: newSize) { (image) in
      print("📱 WCSession sending image \(image) at \(file).")
      let data = UIImagePNGRepresentation(image)!
      try! data.write(to: file)
      session.transferFile(file, metadata: [VideoClipProvider.WCPosterImageRequestKey: value])
    }
  }
  
  func session(_ session: WCSession, didFinish fileTransfer: WCSessionFileTransfer, error: Error?) {
    print("📱 WCSession didFinish fileTransfer \(fileTransfer) - \(String(describing: error?.localizedDescription))")
  }
}

