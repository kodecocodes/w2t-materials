/**
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
import MapKit

class WalkViewController: UIViewController {
  
  @IBOutlet weak var image: UIImageView!
  @IBOutlet weak var goalLabel: UILabel!
  @IBOutlet weak var progressBarView: ProgressBarView!
  @IBOutlet weak var walkLabel: UILabel!
  @IBOutlet weak var infoTextView: UITextView!
  
  var walk: Walk?
  var distanceUnit = "km"
  var completions: CGFloat = 0.0
  var completionString = ""
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if let walk = walk {
      image.image = UIImage(named: walk.imageName)
      
      if distanceUnit == "km" {
        let formattedString = String(format:"%.2f", walk.goal)
        goalLabel.text = "Goal: \(formattedString)km completed \(completionString) times"
      } else {
        let formattedString = String(format:"%.2f", walk.goal.imperial())
        goalLabel.text = "Goal: \(formattedString)mi completed \(completionString) times"
      }
      
      // progress bar shows color-coded progress towards the next completion
      progressBarView.update(completions.fraction())
      
      walkLabel.text = walk.walkTitle
      infoTextView.text = walk.info
    }
  }
  
  @IBAction func openMaps(_ sender: AnyObject) {
    let launchOptions = [MKLaunchOptionsMapTypeKey: MKMapType.hybrid.rawValue]
    // 2015/09/27 Xcode 7A220: doesn't open on simulator 6 plus or 6s
    walk!.mapItem().openInMaps(launchOptions: launchOptions)
  }
  
}
