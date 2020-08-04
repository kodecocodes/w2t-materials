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
import Foundation


class ProgressInterfaceController: WKInterfaceController {
  
  let ringAnimationFrames = 180
  let dateFormatter = DateFormatter()
  let currencyFormatter = NumberFormatter()
  let numberFormatter = NumberFormatter()
  var dayCount = 1
  var summary: Summary!
  
  @IBOutlet var goalGroup: WKInterfaceGroup!
  @IBOutlet var statusLabel: WKInterfaceLabel!
  @IBOutlet var goalLabel: WKInterfaceLabel!
  @IBOutlet var unitsLabel: WKInterfaceLabel!
  @IBOutlet var averageSellingPriceLabel: WKInterfaceLabel!
  @IBOutlet var dateLabel: WKInterfaceLabel!
  
  override func awake(withContext context: Any?) {
    super.awake(withContext: context)
    
    dateFormatter.dateStyle = .short
    
    currencyFormatter.numberStyle = .currency
    currencyFormatter.maximumFractionDigits = 0
    
    numberFormatter.numberStyle = .decimal
    
    guard let context = context as? String else {
      return
    }
    
    switch context {
    case "week":
      dayCount = 7
      self.setTitle("7-day")
    case "month":
      dayCount = 30
      self.setTitle("30-day")
    default:
      self.setTitle("Today")
    }
    
    summary = history.findSummary(dayCount)
    
  }
  
  override func willActivate() {
    super.willActivate()
    
    updateDateLabel()
    
    updateRevenueLabels()
    
    updateUnitLabels()
    
    updateProgressImage()
  }
  
  func updateDateLabel(){
    let formattedStartDate = dateFormatter.string(from: summary.startDate as Date)
    let preamble = String(format: "beginning %@", formattedStartDate)
    let title = dayCount > 1 ? preamble : formattedStartDate
    dateLabel.setText(title)
  }
  
  func updateRevenueLabels(){
    statusLabel.setText(currencyFormatter.string(from: NSNumber(value: summary.totalRevenue)))
    goalLabel.setText("OF " + currencyFormatter.string(from: NSNumber(value: summary.totalGoal))!)
  }
  
  func updateUnitLabels(){
    unitsLabel.setText(numberFormatter.string(from: NSNumber(value: summary.totalUnits))! + " units")
    let avgSellingPrice = summary.totalRevenue / Double(summary.totalUnits)
    averageSellingPriceLabel.setText(currencyFormatter.string(from: NSNumber(value: avgSellingPrice)))
  }
  
  func updateProgressImage(){
    goalGroup.setBackgroundImageNamed("ring")
    let endAnimationFrame = Int(summary.goalProgress * Double(ringAnimationFrames))
    goalGroup.startAnimatingWithImages(in: NSRange(location: 0, length: endAnimationFrame), duration: 0.6, repeatCount: 1)
  }
}
