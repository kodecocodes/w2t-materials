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

class ConfigureWorkoutInterfaceController: WKInterfaceController {
  
  // MARK: - ****** Models ******
  
  var workoutConfiguration: WorkoutConfiguration?
  
  
  // MARK: - ****** UI ******
  
  @IBOutlet var activePicker: WKInterfacePicker!
  @IBOutlet var restPicker: WKInterfacePicker!
  
  
  // MARK: - ****** Lifecycle ******
  
  override func awake(withContext context: Any?) {
    super.awake(withContext: context)
    
    workoutConfiguration = context as? WorkoutConfiguration
    
    // Configure the Active Time Picker
    activePicker.setItems(activeTimePickerValues.map { (interval) -> WKPickerItem in
      let item = WKPickerItem()
      item.contentImage = WKImage(image: interval.elapsedTimeImage())
      return item
    })
    
    if let index = activeTimePickerValues.index(of: (workoutConfiguration?.activeTime)!) {
      activePicker.setSelectedItemIndex(index)
    } else {
      activePicker.setSelectedItemIndex(0)
    }
    
    // Configure the Rest Time Picker
    restPicker.setItems(restTimePickerValues.map { (interval) -> WKPickerItem in
      let item = WKPickerItem()
      item.contentImage = WKImage(image: interval.elapsedTimeImage())
      return item
      })
    restPicker.setSelectedItemIndex(0)

    if let index = restTimePickerValues.index(of: (workoutConfiguration?.restTime)!) {
      restPicker.setSelectedItemIndex(index)
    } else {
      restPicker.setSelectedItemIndex(0)
    }
  }
  
  // MARK: - ****** Navigation ******
  
  override func contextForSegue(withIdentifier segueIdentifier: String) -> Any? {
    return workoutConfiguration
  }
  
  // MARK: - ****** Pickers ******
  
  let activeTimePickerValues: [TimeInterval] = {
    var intervals = [TimeInterval]()
    for time in stride(from: 10, through: 600, by: 5) {
      intervals.append(TimeInterval(time))
    }
    return intervals
  } ()
  
  let restTimePickerValues: [TimeInterval] = {
    var intervals = [TimeInterval]()
    for time in stride(from: 5, through: 120, by: 5) {
      intervals.append(TimeInterval(time))
    }
    return intervals
  } ()
  
  @IBAction func pickActiveTime(_ value: Int) {
    workoutConfiguration?.activeTime = activeTimePickerValues[value]
  }
  
  @IBAction func pickRestTime(_ value: Int) {
    workoutConfiguration?.restTime = restTimePickerValues[value]
  }
  
}
