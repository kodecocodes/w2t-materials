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

import Foundation

final class DayData: NSObject {
  var date = Date()
  var steps = 0
  var distance = 0.0
  var totalSteps = 0
  var totalDistance = 0.0
  
  convenience init(date: Date, steps: Int, distance: Double, totalSteps: Int, totalDistance: Double) {
    self.init()
    self.date = date
    self.steps = steps
    self.distance = distance
    self.totalSteps = totalSteps
    self.totalDistance = totalDistance
  }
}

// MARK: NSCoding
extension DayData: NSCoding {
  private struct CodingKeys {
    static let date = "date"
    static let steps = "steps"
    static let distance = "distance"
    static let totalSteps = "totalSteps"
    static let totalDistance = "totalDistance"
  }
  
  convenience init(coder aDecoder: NSCoder) {
    let date = aDecoder.decodeObject(forKey: CodingKeys.date) as! Date
    let steps = aDecoder.decodeInteger(forKey: CodingKeys.steps)
    let distance = aDecoder.decodeDouble(forKey: CodingKeys.distance)
    let totalSteps = aDecoder.decodeInteger(forKey: CodingKeys.totalSteps)
    let totalDistance = aDecoder.decodeDouble(forKey: CodingKeys.totalDistance)
    self.init(date: date, steps: steps, distance: distance, totalSteps: totalSteps, totalDistance: totalDistance)
  }
  
  func encode(with encoder: NSCoder) {
    encoder.encode(date, forKey: CodingKeys.date)
    encoder.encode(steps, forKey: CodingKeys.steps)
    encoder.encode(distance, forKey: CodingKeys.distance)
    encoder.encode(totalSteps, forKey: CodingKeys.totalSteps)
    encoder.encode(totalDistance, forKey: CodingKeys.totalDistance)
  }
}
