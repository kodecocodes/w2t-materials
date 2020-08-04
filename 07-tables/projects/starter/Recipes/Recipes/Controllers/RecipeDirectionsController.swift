/*
* Copyright (c) 2016 Razeware LLC
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
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import UIKit

class RecipeDirectionsController: UITableViewController {

  var recipe: Recipe!

  // MARK: Actions

  func promptToStartTimerForStepIndex(_ stepIndex: Int) {
    let alert = UIAlertController(title: "Start a Timer", message: "Would you like to start a timer for \(recipe.timers[stepIndex]) minutes?", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    alert.addAction(UIAlertAction(title: "Start Timer", style: .default, handler: { _ in
      self.startTimerForStepIndex(stepIndex)
    }))
    present(alert, animated: true, completion: nil)
  }

  func startTimerForStepIndex(_ stepIndex: Int) {

    let userInfo: [String : Any] = [
      "category" : "timer",
      "timer" : recipe.timers[stepIndex],
      "message" : "Timer: \(recipe.steps[stepIndex])",
      "title" : recipe.name
    ]
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    appDelegate.scheduleTimerNotificationWithUserInfo(userInfo)
  }

  // MARK: UITableViewDataSource

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return recipe.steps.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeStepsCell", for: indexPath)
    let step = recipe.steps[(indexPath as NSIndexPath).row]
    cell.textLabel?.text = "\((indexPath as NSIndexPath).row+1). \(step)"
    return cell
  }

  // MARK: UITableViewDelegate

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if recipe.timers[(indexPath as NSIndexPath).row] > 0 {
      promptToStartTimerForStepIndex((indexPath as NSIndexPath).row)
    }
  }
}
