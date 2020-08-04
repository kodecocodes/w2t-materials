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

class Stock {
  let companyName: String
  let tickerSymbol: String
  let last5days: [Double]
  
  let numberFormatter = NumberFormatter()
  
  var change: Double {
    let first = last5days.first!
    let last = last5days.last!
    return last - first
  }
  var changePercent: Double {
    return change / last5days.first!
  }
  var changePercentAsString: String {
    numberFormatter.numberStyle = .percent
    numberFormatter.minimumFractionDigits = 2
    numberFormatter.maximumFractionDigits = 2
    return numberFormatter.string(from: NSNumber(value:
      changePercent))!
  }
  var changeCharacter: String {
    return change > 0 ? "△" : "▽"
  }
  var changeColor: UIColor {
    return change > 0 ? UIColor(hex: 0x4CD964) : UIColor(hex: 0xFF3B30)
  }
  var minPriceAsString: String {
    numberFormatter.numberStyle = .currency
    numberFormatter.maximumFractionDigits = 0
    return numberFormatter.string(from: NSNumber(value:
      last5days.min()!))!
  }
  var maxPriceAsString: String {
    numberFormatter.numberStyle = .currency
    numberFormatter.maximumFractionDigits = 0
    return numberFormatter.string(from: NSNumber(value: last5days.max()!))!
  }
  
  init(companyName: String, tickerSymbol: String, last5days: [Double]) {
    self.companyName = companyName
    self.tickerSymbol = tickerSymbol
    self.last5days = last5days
  }
  
}

var stocks = [
  Stock(companyName: "Google", tickerSymbol: "GOOG", last5days: [657.50, 664.56, 661.43, 659.66, 658.27]),
  Stock(companyName: "Tesla", tickerSymbol: "TSLA", last5days: [266.15, 266.79, 263.82, 264.82, 253.01]),
  Stock(companyName: "Apple", tickerSymbol: "AAPL", last5days: [121.30, 122.37,	122.99, 123.38, 122.77]),
  Stock(companyName: "Facebook", tickerSymbol: "FB", last5days: [94.01, 95.21,	96.99, 95.29, 94.17]),
  Stock(companyName: "Amazon", tickerSymbol: "AMZN", last5days: [536.15, 536.76, 529.00, 526.03, 531.41])
]
