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

class RecipeIngredientsController: UITableViewController {

  @IBOutlet weak var bannerView: UIImageView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!

  var selectedIngredientPaths = [IndexPath]()
  var recipe: Recipe?
  var originalHeaderHeight: CGFloat = 0

  override func viewDidLoad() {
    super.viewDidLoad()

    originalHeaderHeight = headerHeightConstraint.constant

    titleLabel.text = recipe?.name
    if let url = recipe?.imageURL {
      bannerView.sd_setImage(with: url)
    }
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    tableView.reloadData()
  }

  // MARK: UITableViewDataSource

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return recipe?.ingredients.count ?? 0
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeIngredientsCell", for: indexPath) as UITableViewCell

    if let item = recipe?.ingredients[(indexPath as NSIndexPath).row] {
      let text = "\(item.quantity) \(item.name)"

		var attributes: [NSAttributedStringKey: Any] = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 17)];

      // lighten and strikethrough the ingredient if we have added it
      if selectedIngredientPaths.contains(indexPath) {
		attributes[NSAttributedStringKey.foregroundColor] = UIColor.lightGray
		attributes[NSAttributedStringKey.strikethroughStyle] = NSUnderlineStyle.styleSingle.rawValue
      } else {
		attributes[NSAttributedStringKey.foregroundColor] = UIColor.black
      }

      cell.textLabel?.attributedText = NSAttributedString(string: text, attributes: attributes)
    }

    return cell
  }

  // MARK: UITableViewDelegate

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if let index = selectedIngredientPaths.index(of: indexPath) {
      selectedIngredientPaths.remove(at: index)
    } else {
      selectedIngredientPaths.append(indexPath)
    }
    tableView.reloadData()
  }

  // MARK: UIScrollViewDelegate

  override func scrollViewDidScroll(_ scrollView: UIScrollView) {
    headerHeightConstraint.constant = originalHeaderHeight - scrollView.contentOffset.y
  }

}
