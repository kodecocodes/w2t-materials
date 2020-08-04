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

protocol ConfigurationControllerDelegate: class {
  
  /// This method is called when a configuration is saved by the controller
  func configurationController(_ controller: ConfigurationViewController,
    didUpdateConfiguration configuration: PopulationConfiguration)
  
  /// This method is called when a configuration is saved by the controller
  func configurationController(_ controllerDidCancel: ConfigurationViewController)
}


class ConfigurationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
  
  // MARK: - ****** Models ******
  
  weak var delegate: ConfigurationControllerDelegate?
  var localConfiguration: PopulationConfiguration?
  
  // MARK: - ****** UI ******
  
  @IBOutlet var table: UITableView!
  @IBOutlet var datePicker: UIPickerView!
  
  
  // MARK: - ****** Lifecycle ******

  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    if localConfiguration == nil {
      localConfiguration = PopulationConfiguration()
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
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
  

  // MARK: - ****** UIPickerViewDelegate ******

  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    if component == 0 {
      localConfiguration?.dobMonth = row + 1
    } else {
      localConfiguration?.dobYear = yearOptions[row]
    }
  }
  
  
  // MARK: - ****** UIPickerViewDataSource ******

  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 2
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    if component == 0 {
      return monthOptions.count
    } else {
      return yearOptions.count
    }
  }
  
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    if component == 0 {
      return monthOptions[row]
    } else {
      return "\(yearOptions[row])"
    }
  }
  
  // MARK: - ****** Table view data source ******
  
  let kGenderSection = 0
  let kCountrySection = 1
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch section {
    case kGenderSection:
      return Gender.allValues.count
    case kCountrySection:
      return countryOptions.count
    default: return 0
    }
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if section == kGenderSection {
      return "Select Your Gender"
    } else if section == kCountrySection {
      return "Select Your Country of Birth"
    }
    return nil
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCell(withIdentifier: "OptionCell", for: indexPath)
    if (indexPath as NSIndexPath).section == kGenderSection {
      cell.textLabel?.text = Gender.allValues[(indexPath as NSIndexPath).row].rawValue
      if let index = Gender.allValues.index(of: localConfiguration!.gender) , index == (indexPath as NSIndexPath).row {
        genderSelectedIndex = index
        cell.accessoryType = .checkmark
      } else {
        cell.accessoryType = .none
      }
    } else {
      cell.textLabel?.text = countryOptions[(indexPath as NSIndexPath).row]
      if let index = countryOptions.index(of: localConfiguration!.country) , index == (indexPath as NSIndexPath).row {
        countrySelectedIndex = index
        cell.accessoryType = .checkmark
      } else {
        cell.accessoryType = .none
      }
    }
    
    return cell
  }

  
  // MARK: - UITableViewDelegate
  
  var genderSelectedIndex = 0
  var countrySelectedIndex = 0
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    var previousItemIndex: Int
    
    // Get the correct index and set values
    if (indexPath as NSIndexPath).section == kGenderSection {
      previousItemIndex = genderSelectedIndex
      genderSelectedIndex = (indexPath as NSIndexPath).row
      localConfiguration?.gender = Gender.allValues[genderSelectedIndex]
    } else {
      previousItemIndex = countrySelectedIndex
      countrySelectedIndex = (indexPath as NSIndexPath).row
      localConfiguration?.country = countryOptions[countrySelectedIndex]
    }

    // Remove the old checkmark
    let cell = tableView.cellForRow(at: IndexPath(row: previousItemIndex, section: (indexPath as NSIndexPath).section))
    cell?.accessoryType = .none
    
    // Set the new checkmark
    let newCell = tableView.cellForRow(at: indexPath)
    newCell?.accessoryType = .checkmark
    
  }
}
