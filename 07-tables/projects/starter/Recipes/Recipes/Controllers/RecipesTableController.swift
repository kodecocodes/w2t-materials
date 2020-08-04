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

class RecipesTableController: UITableViewController {

  var recipeStore = RecipeStore()

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    let identifier = segue.identifier

    if identifier == "RecipeDetailSegue" {
      // pass through the selected recipe
      if let path = tableView.indexPathForSelectedRow {
        let recipe = recipeStore.recipes[(path as NSIndexPath).row]
        let destination = segue.destination as! RecipeDetailController
        destination.recipe = recipe
      }
    }
  }

  // MARK: UITableViewDataSource

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return recipeStore.recipes.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeCell", for: indexPath) as! RecipeCell
    let recipe = recipeStore.recipes[(indexPath as NSIndexPath).row]
    cell.recipeLabel.text = recipe.name
    if let url = recipe.imageURL {
      cell.thumbnailView.sd_setImage(with: url)
    }
    return cell
  }

}
