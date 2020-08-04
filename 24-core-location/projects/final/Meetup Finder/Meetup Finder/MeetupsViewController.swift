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
import CoreLocation
import WatchConnectivity

class MeetupsViewController: UITableViewController {
  
  private let viewModel = MeetupsViewModel()
  private let meetupRequestManager = MeetupRequestManager()
  private let locationManager = CLLocationManager()
  private var session: WCSession?
  private var lastQueriedLocation: CLLocation?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Meetups"
    tableView.contentInset = UIEdgeInsets(top: -36.0, left: 0.0, bottom: 0.0, right: 0.0)
    showLoadingMessageIfApplicable()
    
    startSession()
    
    locationManager.delegate = self
    locationManager.allowsBackgroundLocationUpdates = true
    
    let authorizationStatus = CLLocationManager.authorizationStatus()
    switch authorizationStatus {
    case .notDetermined:
      locationManager.requestWhenInUseAuthorization()
    case .restricted, .denied:
      promptUserForAuthorizationStatusOtherThanAuthorized()
    case .authorizedAlways, .authorizedWhenInUse:
      showLoadingMessageIfApplicable()
      requestLocationUpdateWithAuthorizationStatus(authorizationStatus)
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let controller = segue.destination as? MeetupDetailViewController, let cell = sender as? UITableViewCell {
      let indexPath = tableView.indexPath(for: cell)!
      controller.meetup = viewModel.meetups[(indexPath as NSIndexPath).row]
    }
  }
  
  // MARK: Helper
  
  private func showNoContentMessage(_ show: Bool) {
    if show {
      showEmbeddedLabelInTableViewBackgroundWithMessage("No Meetup groups\nare found ;[")
    } else {
      tableView.backgroundView = nil
    }
  }
  
  /// Show 'Loading...' in the message label if applicable. That's there's been no
  /// content before, now the controller is loading content.
  /// Otherwise does nothing, e.g. a refresh or reload.
  private func showLoadingMessageIfApplicable() {
    switch viewModel.state {
    case .initial: fallthrough
    case .noContent:
      showEmbeddedLabelInTableViewBackgroundWithMessage("Loading...")
    default:
      break
    }
  }
  
  private func queryMeetupsFor(_ location: CLLocation) {
    // Early termination. Don't query backend if location hasn't changed significantly.
    let isSignificantChange = isLocationChangedSignificantly(location)
    if isSignificantChange == false {
      print("New query to meetups ignored because current location hasn't changed significantly.")
      return
    }
    
    lastQueriedLocation = location
    
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
      weakSelf?.viewModel.meetups = nonnilMeetups
      weakSelf?.showNoContentMessage(nonnilMeetups.count == 0)
      weakSelf?.tableView.reloadData()
    }
    
    locationManager.allowDeferredLocationUpdates(untilTraveled: MeetupSignificantDistanceChange, timeout: MeetupSignificantDistanceChangeTimeout)
  }
  
  private func promptUserForAuthorizationStatusOtherThanAuthorized() {
    let title = "Location Access Disabled"
    let message = "In order to query and see Meetup groups near you, please open this app's settings and set location access to 'When In Use'."
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    alertController.addAction(cancelAction)
    
    let openAction = UIAlertAction(title: "Open Settings", style: .default) { (action) in
      if let url = URL(string:UIApplicationOpenSettingsURLString) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
      }
    }
    alertController.addAction(openAction)
    present(alertController, animated: true, completion: nil)
    showEmbeddedLabelInTableViewBackgroundWithMessage(title + "\n\n" + message)
  }
  
  private func showEmbeddedLabelInTableViewBackgroundWithMessage(_ message: String) {
    let label = UILabel(frame: tableView.bounds)
    label.text = message
    label.textAlignment = NSTextAlignment.center
    label.textColor = UIColor.darkGray
    label.numberOfLines = 0
    tableView.backgroundView = label
  }
}

// MARK: UITableView delegate and data source

extension MeetupsViewController {
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel.meetups.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "MeetupGroupCellIdentifier", for: indexPath) as! MeetupGroupCell
    let meetup = viewModel.meetups[(indexPath as NSIndexPath).row]
    cell.nameLabel.text = meetup.group.name
    cell.locationLabel.text = meetup.location.city + ", " + meetup.location.state
    cell.membersLabel.text = "\(meetup.group.numberOfMembers)"
    return cell
  }
}

// MARK: WCSessionDelegate

extension MeetupsViewController: WCSessionDelegate {
  
  private func startSession() {
    guard WCSession.isSupported() else { return }
    session = WCSession.default
    session?.delegate = self
    session?.activate()
  }
  
  func broadcastLocationUpdate(_ location: CLLocation) {
    guard let session = session else {
      print("There's no WCSession. Probably WCSession is not supported.")
      return
    }
    guard session.activationState == .activated else {
      print("There's no active WCSession to broadcast.")
      return
    }
    
    let data = NSKeyedArchiver.archivedData(withRootObject: location)
    let context = ["lastQueriedLocation": data]
    do {
      try session.updateApplicationContext(context)
    } catch {
      print("Update application context failed.")
    }
  }
  
  func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    let description = error?.localizedDescription ?? "nil"
    print("Activation did complete: \(activationState.rawValue), error: \(description)")
  }
  
  func sessionDidBecomeInactive(_ session: WCSession) {
    print("session became inactive")
  }
  
  func sessionDidDeactivate(_ session: WCSession) {
    print("session deactivated")
  }
}

// MARK: CoreLocation

extension MeetupsViewController: CLLocationManagerDelegate {
  
  // MARK: Helpers
  
  func requestLocationUpdateWithAuthorizationStatus(_ status: CLAuthorizationStatus) {
    switch status {
    case .authorizedAlways:
      locationManager.startUpdatingLocation()
    case .authorizedWhenInUse:
      locationManager.requestLocation()
    default:
      break
    }
  }
  
  func isLocationChangedSignificantly(_ updatedLocation: CLLocation) -> Bool {
    guard let lastQueriedLocation = lastQueriedLocation else { return true }
    let distance = lastQueriedLocation.distance(from: updatedLocation)
    return distance > CLLocationDistance(MeetupSignificantDistanceChange)
  }
  
  // MARK: Delegate callbacks
  
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    switch status {
    case .authorizedAlways, .authorizedWhenInUse:
      showLoadingMessageIfApplicable()
      requestLocationUpdateWithAuthorizationStatus(status)
    case .notDetermined:
      manager.requestWhenInUseAuthorization()
    case .restricted, .denied:
      viewModel.state = MeetupsViewState.notAuthorized
      promptUserForAuthorizationStatusOtherThanAuthorized()
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let mostRecentLocation = locations.last else { return }
    print("Location update: <\(mostRecentLocation.coordinate.latitude), \(mostRecentLocation.coordinate.longitude)> @ \(mostRecentLocation.timestamp)")
    broadcastLocationUpdate(mostRecentLocation)
    queryMeetupsFor(mostRecentLocation)
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    let error = error as NSError
    if error.code == CLError.locationUnknown.rawValue { return }
    print("CL failed: \(error)")
  }
  
  func locationManager(_ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?) {
    let error = error as NSError?
    if error?.code == CLError.deferredFailed.rawValue { return }
    let description = error?.localizedDescription ?? "nil"
    print("didFinishDeferredUpdatesWithError: \(description)")
  }
  
  func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
    print("locationManagerDidPauseLocationUpdates")
  }
  
  func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
    print("locationManagerDidResumeLocationUpdates")
  }
}
