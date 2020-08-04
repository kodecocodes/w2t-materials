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

class PopulationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
  
  // MARK: ****** Models ******
  var configuration: PopulationConfiguration?
  let populationService = WorldPopulationService()
  
  var facts: [PopulationFactObject]?
  var graphImage: UIImage?

  // MARK: - ****** UI Elements ******
  @IBOutlet weak var table: UITableView!
  
  // MARK: - ****** Lifecycle ******
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.table.rowHeight = UITableViewAutomaticDimension
    
    DispatchQueue.main.async { () -> Void in
      if self.configuration != nil {
        self.refresh(nil)
      } else {
        self.changeConfiguration(nil)
      }
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // MARK: - Navigation
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    let navController = segue.destination as! UINavigationController
    let vc = navController.topViewController as! ConfigurationViewController
    vc.delegate = self
    vc.localConfiguration = configuration
  }
  
  
  // MARK: - ****** Actions ******

  @IBAction func changeConfiguration(_ sender: AnyObject?) {
    self.performSegue(withIdentifier: "EditConfigurationSegue", sender: sender)
  }
  

  @IBAction func refresh(_ sender: AnyObject?) {
    
    facts = []
    
    guard let configuration = configuration else {
      changeConfiguration(sender)
      return
    }
    
    populationService.getRankInCountry(configuration) { (rank, error) -> Void in
      print("Rank: \(String(describing: rank))\nError: \(String(describing: error?.localizedDescription))")
      guard let rank = rank else {
        return
      }
      DispatchQueue.main.async {
        self.addFactToTable(rank)
      }
    }
    
    populationService.getLifeExpectancy(configuration) { (expectancy, error) -> Void in
      print("Expectancy: \(String(describing: expectancy))\nError: \(String(describing: error?.localizedDescription))")
      guard let expectancy = expectancy else {
        return
      }
      DispatchQueue.main.async {
        self.addFactToTable(expectancy)
      }
    }
    
    populationService.getPopulationTable(configuration.dobYear, country: configuration.country) { table, error in
      print("Table: \(String(describing: table))\nError: \(String(describing: error?.localizedDescription))")
    }
  }

  func addFactToTable (_ fact: PopulationFactObject) {
    if facts == nil {
      facts = []
    }
    facts!.append(fact)
    table.reloadSections(IndexSet(integer: kFactSection), with: .automatic)
  }

  // MARK: - ****** Table view data source ******
  
  let kGraphSection = 0
  let kFactSection = 1
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch section {
    case kFactSection:
      
      guard let facts = facts else { return 0 }
      return facts.count

    case kGraphSection:
      
      if graphImage != nil {
        return 1
      } else {
        return 0
      }
      
    default: return 0
    }
  }
    
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    if (indexPath as NSIndexPath).section == kFactSection {
      let cell = tableView.dequeueReusableCell(withIdentifier: "FactCell", for: indexPath)
      cell.textLabel?.text = facts![(indexPath as NSIndexPath).row].populationFactString
      return cell
      
    } else {
      // Graph
      let graphCell = tableView.dequeueReusableCell(withIdentifier: "GraphCell", for: indexPath) as! ImageCell
      graphCell.graphImage = graphImage
      return graphCell
    }
  }
  
  // MARK: - UITableViewDelegate
  
  func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
    if (indexPath as NSIndexPath).section == kFactSection {
      return 100
    } else {
      return self.table.frame.size.width
    }
  }
  
  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    // Hides the empty cell row separators
    return 0.01
  }
  
  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    // Hides the empty cell row separators
    return UIView()
  }
}

extension PopulationViewController : ConfigurationControllerDelegate {
  func configurationController(_ controller: ConfigurationViewController, didUpdateConfiguration configuration: PopulationConfiguration) {
    self.configuration = configuration
    refresh(controller)
    self.dismiss(animated: true, completion: nil)
    
  }
  
  func configurationController(_ controllerDidCancel: ConfigurationViewController) {
    self.dismiss(animated: true, completion: nil)
  }
}
