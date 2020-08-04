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
import CoreBluetooth
import CoreLocation
import MapKit

class PeripheralViewController: UIViewController {
  @IBOutlet weak var textView: UITextView!
  @IBOutlet weak var advertisingSwitch: UISwitch!

  var peripheralManager: CBPeripheralManager!
  var textCharacteristic: CBMutableCharacteristic!
  var dataToSend = Data()
  var sendDataIndex = 0
  var sendingEOM = false

  var mapCharacteristic: CBMutableCharacteristic!
  var locationManager: CLLocationManager?
  var startLocation: CLLocation?

  override func viewDidLoad() {
    super.viewDidLoad()
    peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    textView.delegate = self
  }

  override func viewWillDisappear(_ animated: Bool) {
    peripheralManager.stopAdvertising()
    super.viewWillDisappear(animated)
  }

  @IBAction func switchChanged(_ sender: Any) {
    if advertisingSwitch.isOn {
      peripheralManager.startAdvertising([CBAdvertisementDataServiceUUIDsKey: [TextOrMapServiceUUID]])
    } else {
      peripheralManager.stopAdvertising()
    }
  }

  // MARK: - Helper methods

  func prepareDataAndSend() {
    guard let data = textView.text.data(using: .utf8) else { return }
    self.dataToSend = data
    sendDataIndex = 0
    sendData()
  }

  func sendData() {
    if sendingEOM {
      let didSend = peripheralManager.updateValue("EOM".data(using: .utf8)!, for: textCharacteristic, onSubscribedCentrals: nil)

      if didSend {
        sendingEOM = false
      }
      return
    }

    // Sending data, not EOM: anything left to send?
    let numberOfBytes = (dataToSend as NSData).length
    guard sendDataIndex < numberOfBytes else { return }
    var didSend = true
    while didSend {
      var amountToSend = numberOfBytes - sendDataIndex
      if amountToSend > notifyMTU {
        amountToSend = notifyMTU
      }

      let chunk = dataToSend.withUnsafeBytes{(body: UnsafePointer<UInt8>) in
        return Data(
          bytes: body + sendDataIndex,
          count: amountToSend
        )
      }
      didSend = peripheralManager.updateValue(chunk, for: textCharacteristic, onSubscribedCentrals: [])
      if !didSend { return }

      guard let stringFromData = String(data: chunk, encoding: .utf8) else { return }
      print("Sent: \(stringFromData)")
      sendDataIndex += amountToSend
      if sendDataIndex >= dataToSend.count {
        sendingEOM = true
        let eomSent = peripheralManager.updateValue("EOM".data(using: .utf8)!, for: textCharacteristic, onSubscribedCentrals: nil)
        if eomSent {
          sendingEOM = false
          print("Sent: EOM")
        }
        return
      }
    }
  }

  fileprivate func stopAdvertising() {
    guard advertisingSwitch.isOn else { return }
    advertisingSwitch.setOn(false, animated: true)
    peripheralManager.stopAdvertising()
  }

}

// MARK: - Peripheral Manager delegate
extension PeripheralViewController: CBPeripheralManagerDelegate {
  // Required protocol method
  func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
    switch peripheral.state {
    case .poweredOn:
      textCharacteristic = CBMutableCharacteristic(type: textCharacteristicUUID, properties: .notify, value: nil, permissions: .readable)
      mapCharacteristic = CBMutableCharacteristic(type: mapCharacteristicUUID, properties: .writeWithoutResponse, value: nil, permissions: .writeable)
      let service = CBMutableService(type: TextOrMapServiceUUID, primary: true)
      service.characteristics = [textCharacteristic, mapCharacteristic]
      peripheralManager.add(service)
    default: return
    }
  }

  // When a central subscribes to transfer characteristic, send data.
  func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral,
    didSubscribeTo characteristic: CBCharacteristic) {
    guard characteristic == textCharacteristic else { return }
    prepareDataAndSend()
  }

  func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
    print("Central unsubscribed from \(characteristic)")
  }

  // Called when peripheral manager is ready to send next data chunk.
  // Ensures packets arrive in the order they are sent.
  func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager) {
    sendData()
  }

  // Called when central sends write request
  // to open Maps on peripheral.
  func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
    guard let request = requests.first, request.characteristic == mapCharacteristic else {
      peripheral.respond(to: requests.first!, withResult: .attributeNotFound)
      return
    }
    map() { locationManager?.stopUpdatingLocation() }
    peripheral.respond(to: request, withResult: .success)
  }

  fileprivate func map(completionHandler: () -> Void) {
    locationManager = CLLocationManager()
    locationManager?.delegate = self
    locationManager?.desiredAccuracy = kCLLocationAccuracyBest
    locationManager?.requestWhenInUseAuthorization()
    if CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways {
      locationManager?.startUpdatingLocation()
    }
  }

}

extension PeripheralViewController: CLLocationManagerDelegate {

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    startLocation = locations.first
    if let coordinate = startLocation?.coordinate {
      let regionDistance:CLLocationDistance = 1000
      let regionSpan = MKCoordinateRegionMakeWithDistance(coordinate, regionDistance, regionDistance)
      let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary: [:]))
      let launchOptions = [MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
                           MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
      ]
      mapItem.openInMaps(launchOptions: launchOptions)
    }

  }

  private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
    if status == .authorizedWhenInUse || status == .authorizedAlways {
      locationManager?.startUpdatingLocation()
    }
  }

}

// MARK: - UITextView delegate
extension PeripheralViewController: UITextViewDelegate {

  func textViewDidBeginEditing(_ textView: UITextView) {
    let rightButton = UIBarButtonItem(title: "Done", style: .done, target: self,
      action: #selector(UIInputViewController.dismissKeyboard))
    navigationItem.rightBarButtonItem = rightButton
  }

  @objc func dismissKeyboard() {
    textView.resignFirstResponder()
    navigationItem.rightBarButtonItem = nil
    prepareDataAndSend()
  }

}
