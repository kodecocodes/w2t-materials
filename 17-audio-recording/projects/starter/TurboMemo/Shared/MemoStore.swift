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
#if os(iOS)
  import AVFoundation
#endif

/// A protocol to communicate with interested objects when there is a change in MemoStore.
public protocol MemoStoreObserver {
  
  func memoStore(store: MemoStore, didUpdateMemos memos: [VoiceMemo])
  
}

public class MemoStore: NSObject {
  
  // MARK: Memo collection
  
  /// Adds a BaseMemo or any of its subclasses to the collection.
  public func add(memo: VoiceMemo) {
    memos[memo.date] = memo
    broadcastAssociatedFile(for: memo)
    broadcastStoreUpdate()
  }
  
  /// Removes a BaseMemo or any of its subclasses from the collection.
  public func removeMemo(_ memo: VoiceMemo) {
    memos[memo.date] = nil
    broadcastStoreUpdate()
  }
  
  /// Returns an array of BaseMemo or any of its subclasses sorted by date of creation.
  public func sortedMemos(ordered: ComparisonResult) -> [VoiceMemo] {
    let allMemos = memos.values
    let sorted = allMemos.sorted { return $0.date.compare($1.date) == ordered }
    return sorted
  }
  
  // MARK: Life Cycle
  
  private let platformIdentifier: String = {
    #if os(watchOS)
      return "⌚️"
    #else
      return "📱"
    #endif
  }()
  
  private var memos: [Date: VoiceMemo] = [:]
  
  private let operationQueue: OperationQueue = {
    let queue = OperationQueue()
    queue.maxConcurrentOperationCount = 1
    return queue
  }()
  
  public static let shared = MemoStore()
  
  private var session: WCSession?
  
  override init() {
    super.init()
    
    if WCSession.isSupported() {
      let session = WCSession.default
      session.delegate = self
      session.activate()
    }
    
    readLogs { [weak self] () -> Void in
      self?.notifyObserversWithUpdateMemos()
    }
  }
  
  // MARK: Private store file read and write handling
  
  /// Read and restore log collection from disk. Upon completion it will notify observers.
  private func readLogs(completion: @escaping () -> ()) {
    // Read logs from disk in the background.
    weak var weakSelf = self
    operationQueue.addOperation { () -> Void in
      guard let weakSelf = weakSelf else { return }
      guard let data = try? Data.init(contentsOf: weakSelf.storedLogsURL) else { return }
      guard let unarchived = NSKeyedUnarchiver.unarchiveObject(with: data) as? [Date: VoiceMemo] else { return }
      weakSelf.updateMemos(with: unarchived)
      
      // Notfiy observers on the main thread.
      OperationQueue.main.addOperation({ () -> () in
        completion()
      })
    }
  }
  
  /// Saves log collection to disk.
  private func saveMemos() {
    weak var weakSelf = self
    let memosToSave = memos
    operationQueue.addOperation { () -> Void in
      guard let weakSelf = weakSelf else { return }
      let dataRepresentation = NSKeyedArchiver.archivedData(withRootObject: memosToSave)
      try? dataRepresentation.write(to: weakSelf.storedLogsURL, options: .atomic)
    }
  }
  
  /// Returns the URL to the stored logs in user documents directory.
  private let storedLogsURL: URL = {
    var url: URL = FileManager.default.userDocumentsDirectory
    url = url.appendingPathComponent("turbo-memo.plist")
    return url
  }()
  
  // MARK: Helpers
  
  /// Update the dictionary of memo on self with the given newMemos dictionary. Objects with the same key will be overwritten.
  private func updateMemos(with newMemos: [Date: VoiceMemo]) {
    for (key, memo) in newMemos {
      memos[key] = memo
    }
  }
  
  /// An internal (private) helper method to notify observers when there is a change in the store.
  private func notifyObserversWithUpdateMemos() {
    weak var weakSelf = self
    operationQueue.addOperation { () -> Void in
      guard let weakSelf = weakSelf else { return }
      let sorted = weakSelf.sortedMemos(ordered: .orderedDescending)
      OperationQueue.main.addOperation({ () -> () in
        for (_, observer) in weakSelf.observers {
          observer.memoStore(store: weakSelf, didUpdateMemos: sorted)
        }
      })
    }
  }
  
  /// Synchronizes the current store with new ones. Deletes extras and requests those that are missing.
  private func synchronizeMemos(with newMemos: [Date: VoiceMemo]) {
    weak var weakSelf = self
    operationQueue.addOperation { () -> () in
      guard let weakSelf = weakSelf else { return }
      
      // 1. Find out what's been deleted.
      var deletedMemos: [VoiceMemo] = []
      for (key, memo) in weakSelf.memos {
        if newMemos[key] == nil {
          deletedMemos.append(memo)
        }
      }
      
      // 2. Remove associated files of those memos that are deleted.
      for memo in deletedMemos {
        try? FileManager.default.removeItem(at: memo.url)
      }
      
      // 3. Find out if there are new memos that are missing associated file.
      for (date, memo) in newMemos {
        let fileName = memo.url.lastPathComponent
        let fileURL = FileManager.default.userDocumentsDirectory.appendingPathComponent(fileName)
        let hasFile = FileManager.default.fileExists(atPath: fileURL.relativePath)
        
        // If associate file doesn't exist, send a message.
        // Don't need the replyHandler as the file comes back via file transfer.
        if !hasFile {
          print("Synchronizing: Sending request for file: \(fileName)")
          weakSelf.sendSynchronization(request: MemoStoreCommunicationKey.sendMemo, dates: [date])
        }
      }
      
      weakSelf.memos.removeAll()
      weakSelf.updateMemos(with: newMemos)
      weakSelf.save()
    }
  }
  
  // MARK: WatchConnectivity
  
  private enum MemoStoreCommunicationKey: String {
    case unknwon  = ""
    case memos    = "memos"
    case addMemo  = "added-memo"
    case sendMemo = "send-memo"
    case sync     = "sync"
  }
  
  /// A private helper to broadcast only addition of a memo.
  private func broadcastAssociatedFile(for memo: VoiceMemo) {
    guard let session = session else { return }
    performBroadcastWithSession(session: session) { () -> () in
      let data = NSKeyedArchiver.archivedData(withRootObject: memo)
      let metadata = [MemoStoreCommunicationKey.addMemo.rawValue: data]
      session.transferFile(memo.url, metadata: metadata)
      print("Addition of a memo broadcasted via transferFile.")
    }
  }
  
  /// A private helper to broadcast a store update, either because a memo was deleted or to synchronize.
  private func broadcastStoreUpdate() {
    guard let session = session else { return }
    performBroadcastWithSession(session: session) { () -> () in
      var memosToBroadcast: [Date: VoiceMemo] = [:]
      for (key, memo) in self.memos {
        memosToBroadcast[key] = memo
      }
      let data = NSKeyedArchiver.archivedData(withRootObject: memosToBroadcast)
      session.transferUserInfo([MemoStoreCommunicationKey.memos.rawValue: data])
      print("Store update broadcasted via transferUserInfo.")
    }
  }
  
  private func sendSynchronization(request: MemoStoreCommunicationKey, dates: [Date]) {
    guard let session = session else { return }
    performBroadcastWithSession(session: session, blockToBroadcast: { () -> () in
      print("Send synchronization request: \(request.rawValue)")
      session.sendMessage([request.rawValue: dates], replyHandler: nil, errorHandler: nil)
    })
  }
  
  /// A private helper to conditionally perform a broadcast via a session.
  private func performBroadcastWithSession(session: WCSession, blockToBroadcast block: () -> ()) {
    #if os(iOS)
      if session.isReachable {
        block()
      }
    #else
      block()
    #endif
  }
  
  // MARK: Operations
  
  private var observers: [String: MemoStoreObserver] = [:]
  
  /// Register an observer to get notified when there's a change in the store.
  public func registerObserver(_ observer: Any) {
    let identifier = String(describing: observer)
    guard let observer = observer as? MemoStoreObserver else { return }
    observers[identifier] = observer
    let sorted = sortedMemos(ordered: .orderedDescending)
    observer.memoStore(store: self, didUpdateMemos: sorted)
  }
  
  /// Unregister an observer.
  public func unregisterObserver(_ observer: Any) {
    let identifier = String(describing: observer)
    guard let _ = observer as? MemoStoreObserver else { return }
    observers[identifier] = nil
  }
  
  /// Save memos and broadcast an update notification to interested objects.
  public func save() {
    saveMemos()
    notifyObserversWithUpdateMemos()
  }
}

// MARK: WCSessionDelegate

extension MemoStore: WCSessionDelegate {
  
  public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    print("session:activationDidCompleteWith: \(activationState.toDebugString)")
    if activationState == .activated {
      self.session = session
    } else {
      self.session = nil
    }
  }
  
  /** ------------------------- iOS App State For Watch ------------------------ */
  
  #if os(iOS)
  public func sessionDidBecomeInactive(_ session: WCSession) {
  print("\(platformIdentifier) sessionDidBecomeInactive")
  }
  
  public func sessionDidDeactivate(_ session: WCSession) {
  print("\(platformIdentifier) sessionDidDeactivate")
  }
  
  public func sessionWatchStateDidChange(_ session: WCSession) {
  print("\(platformIdentifier) sessionWatchStateDidChange - paired:\(session.isPaired), installed:\(session.isWatchAppInstalled)")
  }
  #endif
  /** ------------------------- Interactive Messaging ------------------------- */
  
  public func sessionReachabilityDidChange(_ session: WCSession) {
    print("\(platformIdentifier) session:sessionReachabilityDidChange: - is reachable? \(session.isReachable)")
  }
  
  public func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
    print("\(platformIdentifier) session:didReceiveMessage:\n\t\(message)")
  }
  
  public func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Swift.Void) {
    print("\(platformIdentifier) session:didReceiveMessage:replyHandler\n\t\(message)")
    for (key, value) in message {
      let request = MemoStoreCommunicationKey(rawValue: key) ?? .unknwon
      switch request {
        
      // Send specific memos.
      case .sendMemo:
        if let dates = value as? [Date] {
          for date in dates {
            if let memo = memos[date] {
              broadcastAssociatedFile(for: memo)
            }
          }
        }
        
      // Sync (send) all memos.
      case .sync:
        broadcastStoreUpdate()
      default:
        print("Received unrecognized request:\n\t\(request)")
      }
    }
  }
  
  public func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
    print("session:didReceiveMessageData: \(messageData)")
  }
  
  public func session(_ session: WCSession, didReceiveMessageData messageData: Data, replyHandler: @escaping (Data) -> Swift.Void) {
    print("\(platformIdentifier) session:didReceiveMessageData:replyHandler\n\t\(messageData)")
  }
  
  /** -------------------------- Background Transfers ------------------------- */
  
  public func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
    print("\(platformIdentifier) session:didReceiveApplicationContext:\n\t\(applicationContext)")
  }
  
  public func session(_ session: WCSession, didFinish userInfoTransfer: WCSessionUserInfoTransfer, error: Error?) {
    print("\(platformIdentifier) session:didFinishUserInfoTransfer:\n\t\(userInfoTransfer)")
  }
  
  public func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
    print("\(platformIdentifier) session:didReceiveUserInfo:\n\t\(userInfo)")
    guard let data = userInfo[MemoStoreCommunicationKey.memos.rawValue] as? Data else { return }
    guard let dictionary = NSKeyedUnarchiver.unarchiveObject(with: data) as? [Date: VoiceMemo] else { return }
    synchronizeMemos(with: dictionary)
  }
  
  public func session(_ session: WCSession, didFinish fileTransfer: WCSessionFileTransfer, error: Error?) {
    print("\(platformIdentifier) session:didFinishFileTransfer:\n\t\(String(describing: fileTransfer))\n\tError: \(String(describing:error))")
  }
  
  public func session(_ session: WCSession, didReceive file: WCSessionFile) {
    print("\(platformIdentifier) session:didReceiveFile:\n\t\(file.fileURL.lastPathComponent)\nmetadata:\n\t\(String(describing: file.metadata))")
    
    guard let data = file.metadata?[MemoStoreCommunicationKey.addMemo.rawValue] as? Data else { return }
    guard let newMemo = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as? VoiceMemo else { return }
    
    let url = file.fileURL
    let destination = FileManager.default.moveToUserDocuments(itemAt: url, renameTo: nil)
    print("\(platformIdentifier) FileManager.default.moveToUserDocuments:\n\t\(destination!)")
    
    memos[newMemo.date] = newMemo
    save()
  }
}

extension WCSessionActivationState {
  var toDebugString: String {
    switch self {
    case .activated: return "activated"
    case .inactive: return "inactive"
    case .notActivated: return "not activated"
    }
  }
}
