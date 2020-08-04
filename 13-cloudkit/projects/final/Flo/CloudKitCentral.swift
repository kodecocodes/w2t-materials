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
import CloudKit

class CloudKitCentral {

  // MARK: Class singleton
  static let sharedCKCInstance = CloudKitCentral()
  class func sharedInstance() -> CloudKitCentral {
    return sharedCKCInstance
  }

  // MARK: - CloudKit container
  let container: CKContainer
  let privateDB: CKDatabase
  let zoneID: CKRecordZoneID
  let recordType: String

  let privateSubscriptionId: String
  var token: CKServerChangeToken?
  var tokenData: Data? {
    guard let token = token else { return nil }
    return NSKeyedArchiver.archivedData(withRootObject: token)
  }
  // qos is .userInitiated to pull changes, .utility for push updates
  var qos: QualityOfService = .utility

  init() {
    // Reader TODO: change containerIdentifier to your container's name
    let containerIdentifier = "iCloud.com.raywenderlich.Flo"
    self.container = CKContainer(identifier: containerIdentifier)
    self.privateDB = container.privateCloudDatabase
    self.zoneID = CKRecordZoneID(zoneName: "Drinks", ownerName: CKCurrentUserDefaultName)
    self.recordType = "DrinkEvent"
    self.privateSubscriptionId = "new-drink-event"

    print("CloudKitCentral zoneCreated \(self.createdCustomZone)")
  }

  // MARK: - Flags stored locally, to persist across launches
  var subscribedToPrivateChanges = false
  var createdCustomZone = false

  // MARK: - Handlers defined by view/interface controller
  var alertUserToSignIn: (() -> Void)?
  var updateLocalData: ((CKRecord) -> Void)?
  var cacheLocalData: ((_ object: AnyObject, _ key: String) -> Void)?

  // MARK: - iCloud account availability
  var iCloudAccountIsAvailable = false
  func checkiCloudAccountStatus() {
    container.accountStatus() { accountStatus, error in
      if let error = error {
        print("accountStatus ERROR: \(error.localizedDescription)")
      } else {
        switch accountStatus {
        case .available:
          print("Account is available")
          self.iCloudAccountIsAvailable = true
          if !self.createdCustomZone { self.createZone() }
        case .noAccount:
          print("No Account")
          if let alertUserToSignIn = self.alertUserToSignIn { alertUserToSignIn() }
        case .couldNotDetermine:
          print("Could not determine account")
        case .restricted:
          print("Restricted account")
        }
      }
    }
  }

}

// MARK: - CloudKit operations
extension CloudKitCentral {

  func createZone() {
    let createZoneOp = CKModifyRecordZonesOperation(recordZonesToSave: [CKRecordZone(zoneID: zoneID)], recordZoneIDsToDelete: [])
    createZoneOp.modifyRecordZonesCompletionBlock = { _, _, error in
      if let error = error {
        print("createZonesOp ERROR: \(error.localizedDescription)")
      } else {
        self.createdCustomZone = true
        print("createZonesOp success")
      }
    }
    privateDB.add(createZoneOp)
  }
  
  // Save DrinkEvent record; subscribe to changes after saving first record, which creates record type
  func saveDate(_ date: Date, viaWC: Bool) {
    print("saveDate: subscribedToPrivateChanges flag \(subscribedToPrivateChanges)")
    let record = CKRecord(recordType: recordType, zoneID: zoneID)
    record["date"] = date as NSDate
    privateDB.save(record) { _, error in
      if let error = error {
        print("saveDate to \(self.zoneID) ERROR \(error.localizedDescription)")
      } else {
        print("saveDate to \(self.zoneID) success")
        if viaWC, let update = self.updateLocalData {
          update(record)
        }
        #if os(iOS)
          if !self.subscribedToPrivateChanges {
            self.subscribeToChanges()
          }
        #endif
      }
    }
  }
  
  // watchOS 3, 4 don't support CKSubscriptions
  // Subscription operation fails if record type doesn't exist
  #if os(iOS)
  func subscribeToChanges() {
    let newDrinkEventSubscription = CKDatabaseSubscription(subscriptionID: privateSubscriptionId)
    let notificationInfo = CKNotificationInfo()
    notificationInfo.shouldSendContentAvailable = true // silent notification
    newDrinkEventSubscription.notificationInfo = notificationInfo
    newDrinkEventSubscription.recordType = "DrinkEvent"

    let createSubscriptionOperation = CKModifySubscriptionsOperation(subscriptionsToSave: [newDrinkEventSubscription], subscriptionIDsToDelete: [])
    createSubscriptionOperation.qualityOfService = .utility
    
    createSubscriptionOperation.modifySubscriptionsCompletionBlock = { subscriptions, _, error in
      if let error = error {
        print("createSubscriptionOperation ERROR \(error.localizedDescription)")
      } else {
        print("createSubscriptionOperation success \(String(describing: subscriptions))")

        self.subscribedToPrivateChanges = true
        if let cacheSuccess = self.cacheLocalData {
          cacheSuccess(true as AnyObject, LocalCache.subscriptionsSaved.rawValue)
        }
      }
    }
    privateDB.add(createSubscriptionOperation)
  }
  #endif
  
  // Method called by application(_:didReceiveRemoteNotification:fetchCompletionHandler)
  // where fetchCompletionHandler is (UIBackgroundFetchResult) -> Void
  // callback argument is fetchCompletionHandler with argument UIBackgroundFetchResult.newData
  // Also called by View/InterfaceController at startup, with locally-cached token, qos .userInitiated
  func fetchDatabaseChanges(_ callback: @escaping () -> Void) {
    let changesOperation = CKFetchDatabaseChangesOperation(previousServerChangeToken: token)
    changesOperation.fetchAllChanges = true
    
    // qos is .userInitiated to pull changes, .utility for push updates
    changesOperation.qualityOfService = qos
    
    // Block to handle zones with changed records
    changesOperation.recordZoneWithIDChangedBlock = { zoneID in
      let queryOperation = CKFetchRecordZoneChangesOperation(recordZoneIDs: [zoneID], optionsByRecordZoneID: nil)
      
      queryOperation.fetchAllChanges = true
      queryOperation.recordChangedBlock = { record in
        if let update = self.updateLocalData {
          update(record)
        }
      }
      self.privateDB.add(queryOperation)
      #if os(iOS)
      if !self.subscribedToPrivateChanges {
        self.subscribeToChanges()
      }
      #endif
    }
    
    // Block to save intermediate change tokens
    changesOperation.changeTokenUpdatedBlock = { newToken in
      self.token = newToken
    }
    
    // Block to handle operation completion
    changesOperation.fetchDatabaseChangesCompletionBlock = {
      (newToken: CKServerChangeToken?, more: Bool, error: Error?) -> Void in
      if let error = error {
        print(error.localizedDescription)
      } else {
        // Cache final token
        self.token = newToken
        if let cacheLocalData = self.cacheLocalData, let tokenData = self.tokenData {
          cacheLocalData(tokenData as AnyObject, "changeToken")
        }
        
        // push: fetchCompletionHandler with argument UIBackgroundFetchResult.newData
        // pull: status message or empty handler
        callback()
      }
    }
    
    privateDB.add(changesOperation)
  }
  
}
