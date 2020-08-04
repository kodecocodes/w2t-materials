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

@objc(TideConditions)
final class TideConditions: NSObject {
  fileprivate static let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyyMMdd"
    return dateFormatter
    }()
  
  var station: MeasurementStation {
    didSet {
      if oldValue != station {
        waterLevels = []
        averageWaterLevel = 0
      }
    }
  }
  var waterLevels: [WaterLevel] = []
  var averageWaterLevel: Double = 0
  
  var currentWaterLevel: WaterLevel? {
    guard waterLevels.count > 0 else { return nil }
    let currentDate = Date()
    for waterLevel in waterLevels {
      if waterLevel.date.compare(currentDate) != .orderedAscending {
        return waterLevel
      }
    }
    return nil
  }
  
  init(station: MeasurementStation) {
    self.station = station
    super.init()
  }
}

// MARK: Tide Situations
extension TideConditions {
  enum TideSituation: String {
    case High, Low, Rising, Falling, Unknown
  }
  
  func computeTideSituations() {
    let totalWaterLevel = self.waterLevels.reduce(0.0) { (result, waterLevel) -> Double in
      return result + waterLevel.height
    }
    averageWaterLevel = totalWaterLevel / Double(waterLevels.count)
    
    for (i, value) in waterLevels.enumerated() {
      let height = value.height
      if i == 0 { // First data point
        let nextHeight = waterLevels[i+1].height
        value.situation = height > nextHeight ? .Falling : .Rising
        continue
      } else if i == waterLevels.count-1 { // Last data point
        let prevHeight = waterLevels[i-1].height
        value.situation = prevHeight > height ? .Falling : .Rising
        continue
      }
      let prevHeight = waterLevels[i-1].height
      let nextHeight = waterLevels[i+1].height
      
      if height > prevHeight && height > nextHeight {
        value.situation = .High
      } else if height < prevHeight && height < nextHeight {
        value.situation = .Low
      } else if height < nextHeight {
        value.situation = .Rising
      } else {
        value.situation = .Falling
      }
    }
  }
}

// MARK: CO-OPS API
// http://tidesandcurrents.noaa.gov/api/
extension TideConditions {
  func loadWaterLevels(from fromDate: Date, to toDate: Date, completion:@escaping (_ success: Bool)->()) {
    var params = [
      "product": "predictions",
      "units": "metric",
      "time_zone": "gmt",
      "application": "TideWatch",
      "format": "json",
      "datum": "mllw",
      "interval": "h",
      "station": station.id
    ]
    
    params["begin_date"] = TideConditions.dateFormatter.string(from: fromDate)
    params["end_date"] = TideConditions.dateFormatter.string(from: toDate)
    
    let paramString = params.map({ "\($0.0)=\($0.1)" }).joined(separator: "&")
    let requestEndpoint = "http://tidesandcurrents.noaa.gov/api/datagetter"
    
    let urlString = [requestEndpoint, paramString].joined(separator: "?")
    
    let url = URL(string: urlString)!
    let task = URLSession.shared.dataTask(with: url) { data, _, _ in
      guard let data = data else {
        completion(false)
        return
      }
      
      guard let json = try! JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as? [String: AnyObject] else {
        completion(false)
        return
      }
      
      guard let jsonWaterLevels = json["predictions"] as? [[String: AnyObject]] else {
        completion(false)
        return
      }
      
      let allWaterLevels = jsonWaterLevels.map { json in
        WaterLevel(json: json)!
      }
      
      // Filter out so we only have -24h to 24h data points
      self.waterLevels = allWaterLevels.filter { waterLevel -> Bool in
        return waterLevel.date.compare(fromDate) == ComparisonResult.orderedDescending &&
          waterLevel.date.compare(toDate) == ComparisonResult.orderedAscending
      }
      
      self.computeTideSituations()
      
      completion(true)
      
    }
    task.resume()
  }
}

// MARK: Persistance
extension TideConditions {
  private static var storePath: String {
    let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
    let docPath = paths.first!
    return (docPath as NSString).appendingPathComponent("TideConditions")
  }
  
  static func loadConditions() -> TideConditions {
    if let data = try? Data(contentsOf: URL(fileURLWithPath: storePath)) {
      let savedConditions = NSKeyedUnarchiver.unarchiveObject(with: data) as! TideConditions
      return savedConditions
    } else {
      // Default
      let station = MeasurementStation.allStations()[0];
      return TideConditions(station: station)
    }
  }
  
  static func saveConditions(_ tideConditions:TideConditions) {
    NSKeyedArchiver.archiveRootObject(tideConditions, toFile: storePath)
  }
}

// MARK: NSCoding
extension TideConditions: NSCoding {
  private struct CodingKeys {
    static let station = "station"
    static let waterLevels = "waterLevels"
    static let averageWaterLevel = "averageWaterLevel"
  }
  
  convenience init(coder aDecoder: NSCoder) {
    let station = aDecoder.decodeObject(forKey: CodingKeys.station) as! MeasurementStation
    self.init(station: station)
    
    self.waterLevels = aDecoder.decodeObject(forKey: CodingKeys.waterLevels) as! [WaterLevel]
    self.averageWaterLevel = aDecoder.decodeDouble(forKey: CodingKeys.averageWaterLevel)
  }
  
  func encode(with encoder: NSCoder) {
    encoder.encode(station, forKey: CodingKeys.station)
    encoder.encode(waterLevels, forKey: CodingKeys.waterLevels)
    encoder.encode(averageWaterLevel, forKey: CodingKeys.averageWaterLevel)
  }
}
