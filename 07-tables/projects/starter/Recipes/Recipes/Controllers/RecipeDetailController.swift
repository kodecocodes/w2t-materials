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

enum RecipeDetailSelection: Int {
  case ingredients = 0, steps
}

class RecipeDetailController: UIViewController {

  var recipe: Recipe?
  var initialController: RecipeDetailSelection = .ingredients
  
  @IBOutlet weak var segmentedControl: UISegmentedControl!

  lazy var ingredientsController: RecipeIngredientsController! = {
    let controller = self.storyboard?.instantiateViewController(withIdentifier: "RecipeIngredientsController") as? RecipeIngredientsController
    controller?.recipe = self.recipe
    controller?.tableView.contentInset = self.tableInsets
    return controller
  }()

  lazy var stepsController: RecipeDirectionsController! = {
    let controller = self.storyboard?.instantiateViewController(withIdentifier: "RecipeDirectionsController") as? RecipeDirectionsController
    controller?.recipe = self.recipe
    controller?.tableView.contentInset = self.tableInsets
    return controller
  }()

  // don't rely on automaticallyAdjustsScrollViewInsets since we're swapping child controllers
  var tableInsets: UIEdgeInsets {
    var insets = UIEdgeInsets.zero
    if let nav = navigationController {
      insets.top = nav.navigationBar.bounds.height
      insets.top += 20 // status bar
    }
    if let tab = tabBarController {
      insets.bottom = tab.tabBar.bounds.height
    }
    return insets
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    segmentedControl.selectedSegmentIndex = initialController.rawValue
    updateSelectedController(initialController)
  }

  @IBAction func onSegmentChange(_ sender: UISegmentedControl) {
    if let index = RecipeDetailSelection(rawValue: sender.selectedSegmentIndex) {
      updateSelectedController(index)
    } else {
      print("Unsupported recipe detail selection \(sender.selectedSegmentIndex)")
      abort()
    }
  }

  func updateSelectedController(_ selected: RecipeDetailSelection) {
    switch selected {
    case .ingredients:
      addSubViewController(ingredientsController)
      stepsController.removeFromSuperViewController()
      break
    case .steps:
      addSubViewController(stepsController)
      ingredientsController.removeFromSuperViewController()
      break
    }
  }

}
