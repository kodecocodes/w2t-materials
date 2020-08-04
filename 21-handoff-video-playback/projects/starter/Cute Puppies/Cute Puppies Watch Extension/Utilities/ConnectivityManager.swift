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

import Foundation
import WatchConnectivity

protocol ConnectivityManagerDelegate {
  func connectivityManagerDidUpdate()
}

/// Connectivity Manager refactors code related to WatchConnectivity to handle
/// sending request for poster images, receiving response from parent app and 
/// store them locally on the watch. On completion of every file received, it
/// notifies its delegate.
class ConnectivityManager: NSObject {
  
  /// The WatchConnectivity session to query poster images if needed.
  fileprivate var session: WCSession?
  
  /// A reference map to update poster images for each video clip after
  /// receiving them from the phone app.
  fileprivate let references = VideoClipProvider().clipReferences
  
  fileprivate let delegate: ConnectivityManagerDelegate
  
  init(delegate: ConnectivityManagerDelegate) {
    self.delegate = delegate
    super.init()
  }
  
  func startSession() {
    session = WCSession.default
    session!.delegate = self
    session!.activate()
  }
  
  func requestPosterImages(withSession session: WCSession) {
    let clips = VideoClipProvider().clips
    let preferences = UserDefaults.standard
    for clip in clips {
      
      let key = clip.lastPathComponent
      let hasPosterImage = preferences.bool(forKey: key)
      guard hasPosterImage == false else { continue }
      
      let message = [VideoClipProvider.WCPosterImageRequestKey : clip.lastPathComponent]
      print("⌚️ WCSession is sending message \(message)...")
      session.sendMessage(message, replyHandler: nil, errorHandler: { (error: Error) in
        print("⌚️ WCSession encountered error sending or receiving message: \(error)")
      })
    }
  }
}

extension ConnectivityManager: WCSessionDelegate {
  
  func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    print("⌚️ WCSession activationDidCompleteWith: \(String(describing: activationState)) - error: \(String(describing: error?.localizedDescription))")
    guard activationState == .activated else { return }
    requestPosterImages(withSession: session)
  }
  
  func sessionReachabilityDidChange(_ session: WCSession) {
    print("⌚️ WCSession sessionReachabilityDidChange: \(session)")
    guard session.isReachable else { return }
    requestPosterImages(withSession: session)
  }
  
  func session(_ session: WCSession, didReceive file: WCSessionFile) {
    print("⌚️ WCSession received file: \(file)")
    guard let name = file.metadata?[VideoClipProvider.WCPosterImageRequestKey] as? String else { return }
    
    let fileManager = FileManager.default
    let userDocuments = fileManager.urls(for: .documentDirectory, in: .userDomainMask).last!
    let destination = userDocuments.appendingPathComponent(name)
    do {
      try fileManager.moveItem(at: file.fileURL, to: destination)
      let preference = UserDefaults.standard
      preference.set(true, forKey: name)
    }
    catch {}
    
    delegate.connectivityManagerDidUpdate()
  }
  
}
