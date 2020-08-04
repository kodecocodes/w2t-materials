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

class DetailViewController: UIViewController {
  
  let ringAnimationFrames = 180
  
  var day: Day!
  
  @IBOutlet weak var statusLabel: UILabel!
  @IBOutlet weak var unitsLabel: UILabel!
  @IBOutlet weak var averageSellingPriceLabel: UILabel!
  @IBOutlet weak var statusImage: UIImageView!
  @IBOutlet weak var goalLabel: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .short
    
    self.title = dateFormatter.string(from: day.date as Date)
    
    let currencyFormatter = NumberFormatter()
    currencyFormatter.numberStyle = .currency
    currencyFormatter.maximumFractionDigits = 0
    
    statusLabel.text = currencyFormatter.string(from: NSNumber(value: day.status))
    
    goalLabel.text = "OF " + currencyFormatter.string(from: NSNumber(value: day.goal))!
    
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .decimal
    
    unitsLabel.text = numberFormatter.string(from: NSNumber(value: day.units))! + " units"
    
    averageSellingPriceLabel.text = currencyFormatter.string(from: NSNumber(value: day.averageSellingPrice))
    
    statusImage.image = UIImage(named: "iosring" + String(Int(day.status / day.goal * Double(ringAnimationFrames))))
  }
  
  
}
