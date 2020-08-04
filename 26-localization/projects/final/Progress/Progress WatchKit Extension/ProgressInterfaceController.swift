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
      self.setTitle(NSLocalizedString("oneWeekTitle",
                                      value: "7-day",
                                      comment: "label at the top of report for past 7 days"))
    case "month":
      dayCount = 30
      self.setTitle(NSLocalizedString("oneMonthTitle",
                                      value: "30-day",
                                      comment: "label at the top of report for past 30 days"))
    default:
      self.setTitle(NSLocalizedString("oneDayTitle",
                                      value: "Today",
                                      comment: "label at the top of report for just today"))
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
    // 1
    let formattedStartDate =
      dateFormatter.string(from: summary.startDate)
    // 2
    let preamble = String(
      format: NSLocalizedString("dateStartLabelFormat",
                                value: "beginning %@",
                                comment: "start of a date range: beginning 7/11/11"),
      formattedStartDate)
    // 3
    let title = dayCount > 1 ? preamble : formattedStartDate
    dateLabel.setText(title)
  }
  
  func updateRevenueLabels(){
    // 1
    let totalRevenue =
      currencyFormatter.string(from:
        NSNumber(value: summary.totalRevenue))
    statusLabel.setText(totalRevenue)
    // 2
    guard let totalGoal =
      currencyFormatter.string(from:
        NSNumber(value: summary.totalGoal)) else {
          return
    }
    // 3
    let totalGoalText = String(
      format: NSLocalizedString("totalGoalLabel",
                                value: "of %@",
                                comment: "before the total amount, like: of $500"),
      totalGoal).uppercased()
    goalLabel.setText(totalGoalText)
  }
  
  func updateUnitLabels(){
    guard let formattedTotalUnits =
      numberFormatter.string(from:
        NSNumber(value: summary.totalUnits)) else {
          return
    }
    let totalUnitsText = String(
      format: NSLocalizedString("totalUnitsLabelFormat",
                                value: "%@ units",
                                comment: "describing the total number of units sold"),
      formattedTotalUnits)
    unitsLabel.setText(totalUnitsText)
    let avgSellingPrice =
      summary.totalRevenue / Double(summary.totalUnits)
    let formattedAvgPrice =
      currencyFormatter.string(from:
        NSNumber(value: avgSellingPrice))
    averageSellingPriceLabel.setText(formattedAvgPrice)
  }
  
  func updateProgressImage(){
    goalGroup.setBackgroundImageNamed("ring")
    let endAnimationFrame = Int(summary.goalProgress * Double(ringAnimationFrames))
    goalGroup.startAnimatingWithImages(in: NSRange(location: 0, length: endAnimationFrame), duration: 0.6, repeatCount: 1)
  }
}
