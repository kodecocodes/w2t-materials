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
import WatchKit

protocol ConfigurationControllerDelegate: class {

  /// This method is called when a configuration is saved by the controller
  func configurationController(_ controller: ConfigurationController,
    didUpdateConfiguration configuration: PopulationConfiguration)
  
  /// This method is called when a configuration is saved by the controller
  func configurationController(_ controllerDidCancel: ConfigurationController)
}

class ConfigurationContext {
  weak var delegate: ConfigurationControllerDelegate?
  var configuration: PopulationConfiguration?
}


class ConfigurationController : WKInterfaceController {
  
  // MARK: - ****** Models ******
  
  weak var delegate: ConfigurationControllerDelegate?
  var localConfiguration: PopulationConfiguration?
  
  // MARK: - ****** UI ******
  
  @IBOutlet var countryPicker: WKInterfacePicker!
  @IBOutlet var genderPicker: WKInterfacePicker!
  @IBOutlet var dateMonthPicker: WKInterfacePicker!
  @IBOutlet var dateYearPicker: WKInterfacePicker!
  
  // MARK: - ****** Lifecycle ******
  
  override func awake(withContext context: Any?) {
    super.awake(withContext: context)
    
    // Configure the Country Picker
    countryPicker.setItems(countryOptions.map { (country) -> WKPickerItem in
      let item = WKPickerItem()
      item.title = country
      return item
      })
    
    // Configure the Gender Picker
    genderPicker.setItems(Gender.allValues.map{ (gender) -> WKPickerItem in
      let item = WKPickerItem()
      item.title = gender.rawValue
      return item
      })
    
    // Date Pickers
    dateMonthPicker.setItems(monthOptions.map { (month) -> WKPickerItem in
      let item = WKPickerItem()
      item.title = month
      return item
      })
    dateYearPicker.setItems(yearOptions.map { (year) -> WKPickerItem in
      let item = WKPickerItem()
      item.title = "\(year)"
      return item
      })
    
    guard let context = context as? ConfigurationContext else {
      localConfiguration = PopulationConfiguration()
      countryPicker.setSelectedItemIndex(0)
      genderPicker.setSelectedItemIndex(0)
      return
    }
    
    delegate = context.delegate

    if let configuration = context.configuration {
      localConfiguration = configuration
    } else {
      localConfiguration = PopulationConfiguration()
    }
  
    if let index = countryOptions.index(of: localConfiguration!.country) {
      countryPicker.setSelectedItemIndex(index)
    } else {
      countryPicker.setSelectedItemIndex(0)
    }
    
    if let index = Gender.allValues.index(of: localConfiguration!.gender) {
      genderPicker.setSelectedItemIndex(index)
    } else {
      genderPicker.setSelectedItemIndex(0)
    }
    
    if let index = yearOptions.index(of: localConfiguration!.dobYear) {
      dateYearPicker.setSelectedItemIndex(index)
    } else {
      dateYearPicker.setSelectedItemIndex(0)
    }
    dateMonthPicker.setSelectedItemIndex(localConfiguration!.dobMonth-1)
}
  

  // MARK: - ****** Actions ******
  
  @IBAction func save(_ sender: AnyObject?) {
    if let delegate = delegate {
      delegate.configurationController(self, didUpdateConfiguration: localConfiguration!)
    }
  }
  
  @IBAction func cancel(_ sender: AnyObject?) {
    if let delegate = delegate {
      delegate.configurationController(self)
    }
  }
  
  @IBAction func pickGender(_ value: Int) {
    localConfiguration?.gender = Gender.allValues[value]
  }
  
  @IBAction func pickCountry(_ value: Int) {
    localConfiguration?.country = countryOptions[value]
  }
  
  @IBAction func pickYear(_ value: Int) {
    localConfiguration?.dobYear = yearOptions[value]
  }

  @IBAction func pickMonth(_ value: Int) {
    localConfiguration?.dobMonth = value + 1
  }
}
