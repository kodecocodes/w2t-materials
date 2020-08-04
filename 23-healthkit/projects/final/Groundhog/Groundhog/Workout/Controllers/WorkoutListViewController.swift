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
import HealthKit

class WorkoutListViewController: UITableViewController {
  
  let workoutService = IntervalWorkoutService()
  var workouts: [IntervalWorkout]?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.refreshControl = UIRefreshControl()
    self.refreshControl?.addTarget(self, action: #selector(WorkoutListViewController.refresh(_:)), for: .valueChanged)
    
    let healthService:HealthDataService = HealthDataService()
    healthService.authorizeHealthKitAccess { (accessGranted, error) in
      DispatchQueue.main.async {
        if accessGranted {
          self.refresh(nil)
          
        } else {
          print("HK access denied! \n\(String(describing: error))")
        }
      }
    }
  }
  
  
  // MARK: - Actions
  
  @IBAction func refresh(_ sender: AnyObject?) {
    self.refreshControl?.beginRefreshing()
    self.workoutService.readIntervalWorkouts { (success, workouts, error) -> Void in
      DispatchQueue.main.async(execute: { () -> Void in
        self.refreshControl?.endRefreshing()
        self.workouts = workouts
        self.tableView.reloadData()
      })
    }
  }
  
  
  // MARK: - Table view data source
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let workouts = workouts else {return 0}
    
    return workouts.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "WorkoutCell", for: indexPath) as! WorkoutCell
    
    cell.workout = workouts![(indexPath as NSIndexPath).row]
    
    return cell
  }
  
  
  // MARK: - UITableViewDelegate
  
  override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    // Hides the empty cell row separators
    return 0.01
  }
  
  override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    // Hides the empty cell row separators
    return UIView()
  }

  
  // MARK: - Navigation
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    let vc = segue.destination as! WorkoutViewController
    vc.workoutService = workoutService
    vc.workout = workouts![(self.tableView.indexPathForSelectedRow! as NSIndexPath).row]
  }
  
}
