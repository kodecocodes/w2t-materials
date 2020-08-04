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

class CentralViewController: UIViewController {
  
  @IBOutlet weak var textView: UITextView!
  var centralManager: CBCentralManager!
  var discoveredPeripheral: CBPeripheral?

  var textCharacteristic: CBCharacteristic?
  var data = Data()
  var mapCharacteristic: CBCharacteristic? {
    didSet {
      if let _ = self.mapCharacteristic {
        navigationItem.rightBarButtonItem?.title = "Map Me"
      }
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    centralManager = CBCentralManager(delegate: self, queue: nil)

    // Set up rightBarButtonItem to map user's location on peripheral
    let rightButton = UIBarButtonItem(title: "wait...", style: .plain, target: self,
       action: #selector(CentralViewController.mapUserLocation))
    navigationItem.rightBarButtonItem = rightButton
  }

  override func viewWillDisappear(_ animated: Bool) {
    centralManager.stopScan()
    super.viewWillDisappear(animated)
  }

  // MARK: - Bar button action
  // Send instruction to peripheral, to open Maps at user's location
  @objc func mapUserLocation() {
    guard let characteristic = mapCharacteristic else { return }
    discoveredPeripheral?.writeValue(Data(bytes: [1]), for: characteristic, type: .withoutResponse)
  }

  // MARK: - Helper methods

  func scan() {
    centralManager.scanForPeripherals(withServices: [TextOrMapServiceUUID], options: [CBCentralManagerScanOptionAllowDuplicatesKey: NSNumber(value: true as Bool)])
  }

  func cleanup() {
    guard discoveredPeripheral?.state != .disconnected,
      let services = discoveredPeripheral?.services else {
        centralManager.cancelPeripheralConnection(discoveredPeripheral!)
        return
    }
    for service in services {
      if let characteristics = service.characteristics {
        for characteristic in characteristics {
          if characteristic.uuid.isEqual(textCharacteristicUUID) {
            if characteristic.isNotifying {
              discoveredPeripheral?.setNotifyValue(false, for: characteristic)
              return
            }
          }
        }
      }
    }
    centralManager.cancelPeripheralConnection(discoveredPeripheral!)
  }

}

// MARK: - Central Manager delegate
extension CentralViewController: CBCentralManagerDelegate {

  func centralManagerDidUpdateState(_ central: CBCentralManager) {
    switch central.state {
    case .poweredOn: scan()
    case .poweredOff, .resetting: cleanup()
    default: return
    }
  }

  func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
    guard RSSI_range.contains(RSSI.intValue) && discoveredPeripheral != peripheral else { return }

    discoveredPeripheral = peripheral
    central.connect(peripheral, options: [:])
  }

  func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
    if let error = error { print(error.localizedDescription) }
    cleanup()
  }

  func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
    central.stopScan()
    data.removeAll()
    peripheral.delegate = self
    peripheral.discoverServices([TextOrMapServiceUUID])
  }

  func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
    if (peripheral == discoveredPeripheral) {
      cleanup()
    }
    scan()
  }

}

// MARK: - Peripheral Delegate
extension CentralViewController: CBPeripheralDelegate {

  func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
    if let error = error {
      print(error.localizedDescription)
      cleanup()
      return
    }

    guard let services = peripheral.services else { return }
    for service in services {
      peripheral.discoverCharacteristics([textCharacteristicUUID, mapCharacteristicUUID], for: service)
    }
  }

  func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
    if let error = error {
      print(error.localizedDescription)
      cleanup()
      return
    }

    guard let characteristics = service.characteristics else { return }
    for characteristic in characteristics {
      if characteristic.uuid == textCharacteristicUUID {
        textCharacteristic = characteristic
        peripheral.setNotifyValue(true, for: characteristic)
      } else if characteristic.uuid == mapCharacteristicUUID {
        mapCharacteristic = characteristic
      }
    }
  }

  func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
    if let error = error {
      print(error.localizedDescription)
      return
    }

    if characteristic == textCharacteristic {
      guard let newData = characteristic.value else { return }
      let stringFromData = String(data: newData, encoding: .utf8)

      if stringFromData == "EOM" {
        textView.text = String(data: data, encoding: .utf8)
        data.removeAll()
      } else {
        data.append(newData)
      }
    }
  }

  func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
    if let error = error { print(error.localizedDescription) }
    guard characteristic.uuid == textCharacteristicUUID else { return }
    if characteristic.isNotifying {
      print("Notification began on \(characteristic)")
    } else {
      print("Notification stopped on \(characteristic). Disconnecting...")
    }
  }

  // Stub to stop run-time warning
  func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {}

}
