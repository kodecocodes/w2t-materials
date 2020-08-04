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

import ClockKit

final class ComplicationController: NSObject, CLKComplicationDataSource {
  
  // MARK: Register
  func getPlaceholderTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
    if complication.family == .utilitarianSmall {
      let smallFlat = CLKComplicationTemplateUtilitarianSmallFlat()
      smallFlat.textProvider = CLKSimpleTextProvider(text: "+2.6m")
      smallFlat.imageProvider = CLKImageProvider(onePieceImage: UIImage(named: "tide_high")!)
      
      handler(smallFlat)
    }
    else if complication.family == .utilitarianLarge {
      let largeFlat = CLKComplicationTemplateUtilitarianLargeFlat()
      largeFlat.textProvider = CLKSimpleTextProvider(text: "Rising, +2.6m", shortText:"+2.6m")
      largeFlat.imageProvider = CLKImageProvider(onePieceImage: UIImage(named: "tide_high")!)
      
      handler(largeFlat)
    }
  }
  
  // MARK: Provide Data
  func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
    let tideConditions = TideConditions.loadConditions()
    
    guard let waterLevel = tideConditions.currentWaterLevel else {
      // No data is cached yet
      handler(nil)
      return
    }
    
    handler(timelineEntryFor(waterLevel, family: complication.family))
    saveDisplayedStation(tideConditions.station)
  }
  
  // MARK: Time Travel
  func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
    handler([])
  }

  // MARK: Template Creation
  func timelineEntryFor(_ waterLevel: WaterLevel, family: CLKComplicationFamily) -> CLKComplicationTimelineEntry? {
    let tideImageName: String
    switch waterLevel.situation {
    case .High: tideImageName = "tide_high"
    case .Low: tideImageName = "tide_low"
    case .Rising: tideImageName = "tide_rising"
    case .Falling: tideImageName = "tide_falling"
    default: tideImageName = "tide_high"
    }
    
    if family == .utilitarianSmall {
      let smallFlat = CLKComplicationTemplateUtilitarianSmallFlat()
      smallFlat.textProvider = CLKSimpleTextProvider(text: waterLevel.shortTextForComplication)
      smallFlat.imageProvider = CLKImageProvider(onePieceImage: UIImage(named: tideImageName)!)
      return CLKComplicationTimelineEntry(date: waterLevel.date, complicationTemplate: smallFlat)
    } else if family == .utilitarianLarge{
      let largeFlat = CLKComplicationTemplateUtilitarianLargeFlat()
      largeFlat.textProvider = CLKSimpleTextProvider(text: waterLevel.longTextForComplication, shortText:waterLevel.shortTextForComplication)
      largeFlat.imageProvider = CLKImageProvider(onePieceImage: UIImage(named: tideImageName)!)
      return CLKComplicationTimelineEntry(date: waterLevel.date, complicationTemplate: largeFlat)
    }
    return nil
  }
}

// MARK: Displayed Data
extension ComplicationController {
  private func loadDisplayedStation() -> MeasurementStation? {
    if let data = try? Data(contentsOf: URL(fileURLWithPath: storePath)) {
      let station = NSKeyedUnarchiver.unarchiveObject(with: data) as! MeasurementStation
      return station
    }
    return nil
  }
  
  fileprivate func saveDisplayedStation(_ displayedStation: MeasurementStation) {
    NSKeyedArchiver.archiveRootObject(displayedStation, toFile: storePath)
  }
  
  private var storePath: String {
    let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
    let docPath = paths.first!
    return (docPath as NSString).appendingPathComponent("CurrentStation")
  }
}
