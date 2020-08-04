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

@objc(MeasurementStation)
final class MeasurementStation: NSObject {
  let id: String
  let name: String
  let state: String
  
  required init(id: String, name: String, state: String) {
    self.id = id
    self.name = name
    self.state = state
  }
}

// MARK: NSCoding
extension MeasurementStation: NSCoding {
  private struct CodingKeys {
    static let id = "id"
    static let name = "name"
    static let state = "state"
  }
  
  convenience init(coder aDecoder: NSCoder) {
    let id = aDecoder.decodeObject(forKey: CodingKeys.id) as! String
    let name = aDecoder.decodeObject(forKey: CodingKeys.name) as! String
    let state = aDecoder.decodeObject(forKey: CodingKeys.state) as! String
    self.init(id: id, name: name, state: state)
  }
  
  func encode(with encoder: NSCoder) {
    encoder.encode(id, forKey: CodingKeys.id)
    encoder.encode(name, forKey: CodingKeys.name)
    encoder.encode(state, forKey: CodingKeys.state)
  }
}

// MARK: Loading
extension MeasurementStation {
  class func allStations() -> [MeasurementStation] {
    guard let file = Bundle.main.path(forResource: "Stations", ofType: "plist") else { return [] }
    guard let stationStrings = NSArray(contentsOfFile: file) as? [String] else { return [] }
    
    let stations = stationStrings.map { s -> MeasurementStation in
      let components = (s as NSString).components(separatedBy: ",")
      return MeasurementStation(id: components[0], name: components[1], state: components[2])
    }
    
    return stations
  }
}
