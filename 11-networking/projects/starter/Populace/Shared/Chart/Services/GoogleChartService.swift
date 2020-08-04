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

import Foundation
import UIKit

class GoogleChartService : WebService {
  // http://chart.googleapis.com/chart?chs=250x150&cht=bvs&chco=4D89F9,C6D9FD&chd=t:10,50,60,80,40|50,60,100,40,20&chds=0,160&chbh=a
  fileprivate let baseURL = URL(string: "http://chart.googleapis.com")!

  init () {
    super.init(rootURL: baseURL)
  }
  
  
  /**
  Gets a Google Stacked Bar Graph Chart Image from two arrays of Integers
  - parameter size: The size of the image to get
  - parameter bottomSeries: An array of integer values for the bottom stack (Required)
  - parameter bottomColor: The color for the bottom data series
  - parameter topSeries: An array of integer values for the top stack (Optional)
  - parameter topColor: The color for the top data series (Optional)
  - parameter completion: A completion block that returns the image or an error
  */
  func getStackedBarChart(_ size: CGSize,
    bottomSeries: [Int], bottomColor: UIColor,
    topSeries: [Int]?, topColor: UIColor?,
    completion: @escaping (_ image:UIImage?, _ error:Error?) -> Void ) {
    // TODO - Implement Functionality
  }

  /// This method creates the GCharts size (chs) query string parameter
  internal func sizeParameterString(_ size: CGSize) -> String {
    return "chs=\(Int(size.width))x\(Int(size.height))"
  }
  
  /// This method creates a series color query string for up to 2 data series
  internal func seriesColorParameterString(_ color1: UIColor, color2: UIColor?) -> String {
    var colorsString = "chco=\(color1.hexString)"
    
    if let color2 = color2 {
      colorsString += ",\(color2.hexString)"
    }
    return colorsString
  }
  
  /// This method creates a series data query string for up to 2 arrays of data
  internal func seriesParameterString(_ series1: [Int], series2: [Int]?) -> String {
    var parameters = "chd=t:\(seriesString(series1))"
    
    if let series2 = series2 {
      parameters += "|\(seriesString(series2))"
    }
    
    return parameters
  }
  
  /// This method takes an array of Ints and converts it to a comma separated String
  internal func seriesString(_ series:[Int]) -> String {
    let intStringArray = series.map { (intValue) -> String in
      return "\(intValue)"
    }
    
    let intStringNSArray = intStringArray as NSArray
    return intStringNSArray.componentsJoined(by: ",")
  }
  
  /// This method creates a chart max height range based on up to 2 data series
  internal func seriesMaxValueString(_ series1: [Int], series2: [Int]?) -> String {
    var maxValue = 0
    maxValue += series1.max()!
    
    if let series2 = series2 {
      maxValue += series2.max()!
    }
    
    return "chds=0,\(maxValue)"
  }
}
