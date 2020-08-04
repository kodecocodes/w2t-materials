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
import CoreLocation
import WatchConnectivity

class InterfaceController: WKInterfaceController {
  
  private let locationAccessUnauthorizedMessage = "Locations Disabled\n\nEnable locations for this app via the Settings in your iPhone to see meetups near you!"
  private let pendingAccessMessage = "Grant location access to Meetup Finder on your iPhone to see meetup groups in your vicinity."
  
  /// The WKInterfaceGroup that's displayed when there's no content and instead
  /// you want to display a message to user, e.g. "No Meetups found", or
  /// "Location service is disabled", etc.
  @IBOutlet private var messageContentGroup: WKInterfaceGroup!
  @IBOutlet private var messageLabel: WKInterfaceLabel!
  
  /// The WKInterfaceGroup that's displayed when there're meetups. It contains the WKInterfaceTable.
  @IBOutlet private var meetupsContentGroup: WKInterfaceGroup!
  @IBOutlet private var interfaceTable: WKInterfaceTable!
  
  private let interfaceModel = MainInterfaceModel()
  private let meetupRequestManager = MeetupRequestManager()
  private let locationManager = CLLocationManager()
  private var session: WCSession?
  private var lastQueriedLocation: CLLocation?
  
  override func awake(withContext context: Any?) {
    super.awake(withContext: context)
    startSession()
    locationManager.allowsBackgroundLocationUpdates = true
    locationManager.delegate = self
  }
  
  override func willActivate() {
    super.willActivate()
    
    // Then ask location manager to give you an updated location.
    // If the new location is significantly different, you'll dispatch
    // another request.
    let authorizationStatus = CLLocationManager.authorizationStatus()
    handleLocationServicesAuthorizationStatus(authorizationStatus)
    
    // If there is a valid last known location - usually set either via
    // session(_:, didReceiveApplicationContext:) of WCSessionDelegate,
    // query data for that.
    if let lastQueriedLocation = lastQueriedLocation {
      queryMeetupsForLocation(lastQueriedLocation)
    }
  }
  
  func handleLocationServicesAuthorizationStatus(_ status: CLAuthorizationStatus) {
    switch status {
    case .notDetermined:
      print("handleLocationServicesAuthorizationStatus: .undetermined")
      handleLocationServicesStateNotDetermined()
    case .restricted, .denied:
      print("handleLocationServicesAuthorizationStatus: .restricted, .denied")
      handleLocationServicesStateUnavailable()
    case .authorizedAlways, .authorizedWhenInUse:
      print("handleLocationServicesAuthorizationStatus: .authorizedAlways, .authorizedWhenInUse")
      handleLocationServicesStateAvailable(status)
    }
  }
  
  func handleLocationServicesStateNotDetermined() {
    updateVisibilityOfInterfaceGroups()
    messageLabel.setText(pendingAccessMessage)
    locationManager.requestWhenInUseAuthorization()
  }
  
  func handleLocationServicesStateUnavailable() {
    interfaceModel.state = MainInterfaceState.notAuthorized
    updateVisibilityOfInterfaceGroups()
    messageLabel.setText(locationAccessUnauthorizedMessage)
  }
  
  func handleLocationServicesStateAvailable(_ status: CLAuthorizationStatus) {
    updateVisibilityOfInterfaceGroups()
    showLoadingMessageIfApplicable()
    switch status {
    case .authorizedAlways:
      locationManager.startUpdatingLocation()
    case .authorizedWhenInUse:
      locationManager.requestLocation()
    default:
      break
    }
  }
  
  override func didDeactivate() {
    super.didDeactivate()
  }
  
  override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
    let meetup = interfaceModel.meetups[rowIndex]
    pushController(withName: "DetailInterfaceController", context: meetup)
  }
  
  // MARK: Helper
  
  private func updateInterfaceWithMeetups(_ meetups: [Meetup]) {
    // Initialize, add or remove rows from the Interface Table
    // based on current number of meetups and the new count of meetups.
    let currentCount = interfaceModel.meetups.count
    let newCount = meetups.count
    let rowType = "MeetupRowController"
    
    // Not all conditions may require the following values.
    // They're here to refactor common code.
    let diff = newCount - currentCount
    let range = Range(uncheckedBounds:(lower: currentCount, upper: currentCount + diff))
    let indexSet = IndexSet(integersIn: range)
    
    // Update row count of the table.
    performBlock { () -> Void in
      if currentCount == 0 {
        // Initialize table.
        self.interfaceTable.setNumberOfRows(newCount, withRowType: rowType)
      } else if currentCount > newCount {
        // Add new rows.
        self.interfaceTable.insertRows(at: indexSet, withRowType: rowType)
      } else if currentCount < newCount {
        // Remove extra rows.
        self.interfaceTable.removeRows(at: indexSet)
      }
      
      // Update content of rows.
      self.performBlock { () -> Void in
        for (index, meetup) in meetups.enumerated() {
          guard let rowController = self.interfaceTable.rowController(at: index) as? MeetupRowController else { continue }
          rowController.meetupGroupNameLabel.setText(meetup.group.name)
          rowController.meetupLocationLabel.setText(meetup.location.city + ", " + meetup.location.state)
          rowController.meetupMembersLabel.setText("\(meetup.group.numberOfMembers)")
          rowController.containerGroup.setBackgroundColor(meetup.group.color)
        }
      }
    }
    
    // Update interface model.
    interfaceModel.meetups = meetups
    if newCount == 0 {
      interfaceModel.state = .noContent
      messageLabel.setText("No Meetup groups\nare found ;[")
    } else {
      interfaceModel.state = .meetupContent
    }
    performBlock { () -> Void in
      self.updateVisibilityOfInterfaceGroups()
    }
  }
  
  /// Show 'Loading...' in the message label if applicable. That's there's been no
  /// content before, now the controller is loading content. 
  /// Otherwise does nothing, e.g. a refresh or reload.
  private func showLoadingMessageIfApplicable() {
    switch interfaceModel.state {
    case .error: fallthrough
    case .noContent: fallthrough
    case .notAuthorized:
      messageLabel.setText("Loading...")
    default:
      break
    }
  }
  
  /// Toggles appearance of top-level interface elements
  private func updateVisibilityOfInterfaceGroups() {
    switch self.interfaceModel.state {
    case .error: fallthrough
    case .noContent:
      messageContentGroup.setHidden(false)
      meetupsContentGroup.setHidden(true)
    case .notAuthorized:
      messageContentGroup.setHidden(false)
      meetupsContentGroup.setHidden(true)
    case .meetupContent:
      messageContentGroup.setHidden(true)
      meetupsContentGroup.setHidden(false)
    }
  }
  
  private func queryMeetupsForLocation(_ location: CLLocation) {
    // Early termination. Don't query backend if location hasn't changed significantly.
    let isSignificantChange = isLocationChangedSignificantly(location)
    if isSignificantChange == false {
      print("New query to meetups ignored because current location hasn't changed significantly.")
      return
    }
    
    lastQueriedLocation = location
    interfaceModel.loading = true
    showLoadingMessageIfApplicable()
    
    let coordinate = location.coordinate
    let lon = Double(coordinate.longitude)
    let lat = Double(coordinate.latitude)
    let requestModel = MeetupGroupRequestModel(latitude: lat, longitude: lon, radius: MeetupQueryRadius, pages: MeetupQueryPages, searchText: "iOS")
    
    weak var weakSelf = self
    meetupRequestManager.fetchMeetupGroupsWithModel(model: requestModel) { (meetups, error) -> Void in
      var nonnilMeetups = [Meetup]()
      if let meetups = meetups {
        nonnilMeetups = meetups
      }
      weakSelf?.interfaceModel.loading = false
      weakSelf?.updateInterfaceWithMeetups(nonnilMeetups)
    }
  }
  
  func isLocationChangedSignificantly(_ updatedLocation: CLLocation) -> Bool {
    guard let lastQueriedLocation = lastQueriedLocation else { return true }
    let distance = lastQueriedLocation.distance(from: updatedLocation)
    return distance > CLLocationDistance(MeetupSignificantDistanceChange)
  }
}

// MARK: WCSessionDelegate

extension InterfaceController: WCSessionDelegate {
  
  private func startSession() {
    session = WCSession.default
    session?.delegate = self
    session?.activate()
  }
  
  func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    let description = error?.localizedDescription ?? "nil"
    print("Activation did complete: \(activationState), error: \(description)")
  }
  
  func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
    print("Received application context: (applicationContext)")
    guard let data = applicationContext["lastQueriedLocation"] as? Data else { return }
    guard let location = NSKeyedUnarchiver.unarchiveObject(with: data) as? CLLocation else { return }
    queryMeetupsForLocation(location)
  }
}

// MARK: CoreLocation

extension InterfaceController: CLLocationManagerDelegate {
  
  // MARK: Delegate callbacks
  
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    handleLocationServicesAuthorizationStatus(status)
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    print("Did update locations: \(locations)")
    guard let mostRecentLocation = locations.last else { return }
    queryMeetupsForLocation(mostRecentLocation)
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("CL failed: \(error)")
    if interfaceModel.loading == false || interfaceModel.state != .meetupContent {
      interfaceModel.state = .error
      updateVisibilityOfInterfaceGroups()
      messageLabel.setText("Failed to get a valid location.")
    } else {
      print("CL failed but ignore the error because interface controlelr is already loading data with a valid location.")
    }
  }
}
