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

class InterfaceController: WKInterfaceController {
  @IBOutlet weak var timer: WKInterfaceTimer!
  @IBOutlet weak var timerButton: WKInterfaceButton!
  @IBOutlet var weightPicker: WKInterfacePicker!
  @IBOutlet var temperatureLabel: WKInterfaceLabel!
  @IBOutlet var temperaturePicker: WKInterfacePicker!

  var ounces = 16
  var cookTemp = MeatTemperature.medium
  var timerRunning = false

  override func awake(withContext context: Any?) {
    super.awake(withContext: context)

    // 1
    var weightItems: [WKPickerItem] = []
    for i in 1...32 {
      // 2
      let item = WKPickerItem()
      item.title = String(i)
      weightItems.append(item)
    }
    // 3
    weightPicker.setItems(weightItems)
    // 4
    weightPicker.setSelectedItemIndex(ounces - 1)

    // 1
    var tempItems: [WKPickerItem] = []
    for i in 1...4 {
      // 2
      let item = WKPickerItem()
      item.contentImage = WKImage(imageName: "temp-\(i)")
      tempItems.append(item)
    }
    // 3
    temperaturePicker.setItems(tempItems)
    // 4
    onTemperatureChanged(0)
  }

  @IBAction func onTimerButton() {
    // 1
    if timerRunning {
      timer.stop()
      timerButton.setTitle("Start Timer")
    } else {
      // 2
      let time = cookTemp.cookTimeForOunces(ounces)
      timer.setDate(Date(timeIntervalSinceNow: time))
      timer.start()
      timerButton.setTitle("Stop Timer")
    }
    // 3
    timerRunning = !timerRunning
    scroll(to: timer, at: .top, animated: true)
  }

  override func interfaceOffsetDidScrollToTop() {
    print("User scrolled to top")
  }

  override func interfaceDidScrollToTop() {
    print("User went to top by tapping status bar")
  }

  override func interfaceOffsetDidScrollToBottom() {
    print("User scrolled to bottom")
  }

  @IBAction func onWeightChanged(_ value: Int) {
    ounces = value + 1
  }

  @IBAction func onTemperatureChanged(_ value: Int) {
    let temp = MeatTemperature(rawValue: value)!
    cookTemp = temp
    temperatureLabel.setText(temp.stringValue)
  }
}
