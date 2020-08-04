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

class ViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate {

  @IBOutlet weak var timeLabel: UILabel!
  @IBOutlet weak var weightPicker: UIPickerView!
  @IBOutlet weak var tempLabel: UILabel!
  @IBOutlet weak var tempSlider: UISlider!

  var startTime: TimeInterval = 0
  var timer: Timer?
  var cookTime: TimeInterval = 0

  var currentCookTemp: MeatTemperature {
    return MeatTemperature(rawValue: Int(tempSlider.value))!
  }

  var currentOunces: Int {
    return weightPicker.selectedRow(inComponent: 0) + 1
  }

  @IBAction func onTempChanged(_ sender: AnyObject) {
    tempLabel.text = currentCookTemp.stringValue
  }

  @IBAction func onStartButton(_ sender: AnyObject) {
    cookTime = currentCookTemp.cookTimeForOunces(currentOunces)
    startTimer()
  }

  func startTimer() {
    stopTimer()
    startTime = floor(CACurrentMediaTime())
    timerDidFire(self)
    timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ViewController.timerDidFire(_:)), userInfo: nil, repeats: true)
  }

  func stopTimer() {
    timer?.invalidate()
  }

  @objc func timerDidFire(_ sender: AnyObject) {
    let diff = floor(CACurrentMediaTime() - startTime)
    let time = cookTime - diff
    let hour = time / (60.0 * 60.0)
    let fHour = floor(hour)
    let minute = (time - fHour * 60.0 * 60.0) / 60.0
    let fMinute = floor(minute)
    let second = time - fHour * 60.0 * 60.0 - fMinute * 60.0

    var text = ""
    if fHour > 0 {
      text += NSString(format: "%.0Fh ", fHour) as String
    }
    if fMinute > 0 {
      text += NSString(format: "%.0Fm ", fMinute) as String
    }
    text += NSString(format: "%.0Fs", second) as String

    timeLabel.text = text
  }

  //MARK: UIPickerViewDataSource

  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }

  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return 32
  }

  //MARK: UIPickerViewDelegate

  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return "\(row + 1)"
  }

}

