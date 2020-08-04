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

class PopulationController: WKInterfaceController {

  // MARK: ****** UI Elements ******
  @IBOutlet weak var table: WKInterfaceTable!
  @IBOutlet weak var loadingGroup: WKInterfaceGroup!
  @IBOutlet weak var noConfigurationGroup: WKInterfaceGroup!

  // Track whether to update because menu closing will fire didAppear needlessly
  var updateOnAppear = false

  // MARK: ****** Models ******
  var configuration: PopulationConfiguration?
  
  var facts: [PopulationFactObject]?

  // Manages the state of the interface
  enum InterfaceState: Int {
    case noConfiguration
    case loading
    case results
  }
  
  // Configure the interface based on the state of the search process
  var interfaceStatus: InterfaceState = InterfaceState.noConfiguration {
    didSet {
      loadingGroup.setHidden(true)
      noConfigurationGroup.setHidden(true)
      
      switch interfaceStatus {
      case .noConfiguration:
        noConfigurationGroup.setHidden(false)
        break
      case .loading:
        loadingGroup.setHidden(false)
        break
      case .results:
        break
      }
    }
  }

  
  // MARK: - ****** Lifecycle ******
  
  override func awake(withContext context: Any?) {
    super.awake(withContext: context)
    
    updateOnAppear = true
  }
  
  override func didAppear() {
    super.didAppear()
    
    if updateOnAppear {
      if configuration != nil {
        refresh(nil)
      } else {
        self.interfaceStatus = .noConfiguration
      }
    }
    updateOnAppear = false
  }
  
  
  // MARK: - ****** Actions ******
  
  @IBAction func changeConfiguration(_ sender: AnyObject?) {
    let context = ConfigurationContext()
    context.delegate = self
    context.configuration = configuration
    self.presentController(withName: "ConfigurationController", context: context)
  }

  @IBAction func refresh(_ sender: AnyObject?) {

    facts = []
    
    // Clean up any old results
    let numberRows = table.numberOfRows
    if numberRows > 0 {
      table.removeRows(at: IndexSet(integersIn: Range(NSMakeRange(0, numberRows))!))
    }
    
    // Show the Loading View
    self.interfaceStatus = .loading

    // TODO - Implement Functionality
  }

  func addFactToTable (_ fact: PopulationFactObject) {
    if facts == nil {
      facts = []
    }
    facts!.append(fact)
    
    table.insertRows(at: IndexSet(integer: facts!.count-1), withRowType: "PopulationFactRowController")
    let row = table.rowController(at: facts!.count-1) as! PopulationFactRowController
    row.factObject = fact
  }
}


extension PopulationController : ConfigurationControllerDelegate {

  func configurationController(_ controller: ConfigurationController,
    didUpdateConfiguration configuration: PopulationConfiguration) {
      self.configuration = configuration
      updateOnAppear = true
      dismiss()
  }
  
  func configurationController(_ controllerDidCancel: ConfigurationController) {
    dismiss()
  }
  
}
