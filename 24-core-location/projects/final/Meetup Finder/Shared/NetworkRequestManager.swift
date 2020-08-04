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

/**
 * NetworkRequestManager is responsible to handle dispatching network request,
 * manange the session, cancel tasks and handle background modes.
 **/
class NetworkRequestManager {
  
  /// Data task the receiver has dispatched so that it can be canceled later on if needed.
  private var dataTask: URLSessionDataTask?
  
  /// Maximum timeout for a network request to return from server.
  private let maximumTimeout: Int64 = 30
  
  /// Ask for a background task assertion and have the semphore either wait or release based on the state of the assertion.
  private func askForAssretionWithSemaphore(_ semaphore: DispatchSemaphore) {
    ProcessInfo.processInfo.performExpiringActivity(withReason: "network_request", using: { (expired: Bool) -> Void in
      if !expired {
        // You have a background task assertion. Good to go!
        let timeout: DispatchTime = DispatchTime.now() + Double(self.maximumTimeout) / Double(NSEC_PER_SEC)
        _ = semaphore.wait(timeout: timeout)
      } else {
        // No background task assetion.
        self.releaseAssretionWithSemaphore(semaphore)
      }
    })
  }
  
  /// Signal and release a semaphore.
  private func releaseAssretionWithSemaphore(_ semaphore: DispatchSemaphore) {
    dataTask?.cancel()
    semaphore.signal()
  }
  
  // MARK: Public
  
  /// Dispatches a request. The completion block is called on a secondary thread. This is intentional.
  func dispatchRequest(_ request: URLRequest, completion:@escaping (_ data: Data?, _ error: Error?) -> Void) {
    let state = dataTask?.state
    if let state = state , state == URLSessionTask.State.running {
      print("There's a similar network task in running state. Duplicated request is ignored.")
      return
    }
    
    // Create a semaphore for background task assertion.
    let semaphore: DispatchSemaphore = DispatchSemaphore(value: 0)
    askForAssretionWithSemaphore(semaphore)
    
    weak var weakSelf = self
    let session = URLSession.shared
    let task: URLSessionDataTask = session.dataTask(with: request, completionHandler: { (sessionData: Data?, sessionResponse: URLResponse?, sessionError: Error?) -> Void in
      let sessionError = sessionError as NSError?
      weakSelf?.dataTask = nil
      
      // Don't notify the completion block if canceled.
      var isTaskCancelled = false
      if let error = sessionError {
        isTaskCancelled = (error.code == NSURLErrorCancelled)
      }
      
      if !isTaskCancelled {
        completion(sessionData, sessionError)
      }
      
      // Release semaphore.
      weakSelf?.releaseAssretionWithSemaphore(semaphore)
    })
    
    task.resume()
    dataTask = task
  }
  
  /// Performs a given block on the main thread.
  func performBlockOnTheMainThread(_ block: @escaping () -> Void) {
    OperationQueue.main.addOperation(block)
  }
  
}
