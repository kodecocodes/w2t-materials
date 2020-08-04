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
    handler([.forward, .backward])
  }

  func getTimelineStartDate(
    for complication: CLKComplication,
    withHandler handler: @escaping (Date?) -> Swift.Void) {
    let tideConditions = TideConditions.loadConditions()
    guard let waterLevel = tideConditions.waterLevels.first else {
      // No data is cached yet
      handler(nil)
      return
    }
    handler(waterLevel.date)
  }

  func getTimelineEntries(
    for complication: CLKComplication, before date: Date,
    limit: Int, withHandler handler: @escaping
    ([CLKComplicationTimelineEntry]?) -> Swift.Void) {

    let tideConditions = TideConditions.loadConditions()

    // 1
    var waterLevels = tideConditions.waterLevels.filter {
      $0.date.compare(date) == .orderedAscending
    }

    // 2
    if waterLevels.count > limit {
      // Remove from the front
      let numberToRemove = waterLevels.count - limit
      waterLevels.removeSubrange(0..<numberToRemove)
    }

    // 3
    let entries = waterLevels.flatMap { waterLevel in
      timelineEntryFor(waterLevel, family: complication.family)
    }
    
    handler(entries)
  }

  func getTimelineEndDate(
    for complication: CLKComplication,
    withHandler handler: @escaping (Date?) -> Swift.Void) {
    let tideConditions = TideConditions.loadConditions()
    guard let waterLevel = tideConditions.waterLevels.last else {
      // No data is cached yet
      handler(nil)
      return
    }
    handler(waterLevel.date)
  }

  func getTimelineEntries(
    for complication: CLKComplication, after date: Date,
    limit: Int, withHandler handler: @escaping
    ([CLKComplicationTimelineEntry]?) -> Swift.Void) {

    let tideConditions = TideConditions.loadConditions()

    var waterLevels = tideConditions.waterLevels.filter {
      $0.date.compare(date) == .orderedDescending
    }

    if waterLevels.count > limit {
      // Remove from the back
      waterLevels.removeSubrange(limit..<waterLevels.count)
    }

    let entries = waterLevels.flatMap { waterLevel in
      return timelineEntryFor(waterLevel,
                              family: complication.family)
    }
    
    handler(entries)
  }

  func getTimelineAnimationBehavior(
    for complication: CLKComplication,
    withHandler handler: @escaping
    (CLKComplicationTimelineAnimationBehavior) -> Swift.Void) {
    handler(.grouped)
  }

  func reloadOrExtendData() {
    // 1
    let server = CLKComplicationServer.sharedInstance()
    guard let complications = server.activeComplications,
      complications.count > 0 else { return }

    // 2
    let tideConditions = TideConditions.loadConditions()
    let displayedStation = loadDisplayedStation()

    // 3
    if let id = displayedStation?.id,
      id == tideConditions.station.id {
      // 4
      // Check if there is new data
      if tideConditions.waterLevels.last?.date.compare(
        server.latestTimeTravelDate) == .orderedDescending {
        // 5
        for complication in complications  {
          server.extendTimeline(for: complication)
        }
      }
    } else {
      // 6
      for complication in complications  {
        server.reloadTimeline(for: complication)
      }
    }
    // 7
    saveDisplayedStation(tideConditions.station)
  }

  func getPrivacyBehavior(
    for complication: CLKComplication,
    withHandler handler: @escaping
    (CLKComplicationPrivacyBehavior) -> Swift.Void) {
    handler(.showOnLockScreen)
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
      return CLKComplicationTimelineEntry(date: waterLevel.date, complicationTemplate: smallFlat, timelineAnimationGroup: waterLevel.situation.rawValue)
    } else if family == .utilitarianLarge{
      let largeFlat = CLKComplicationTemplateUtilitarianLargeFlat()
      largeFlat.textProvider = CLKSimpleTextProvider(text: waterLevel.longTextForComplication, shortText:waterLevel.shortTextForComplication)
      largeFlat.imageProvider = CLKImageProvider(onePieceImage: UIImage(named: tideImageName)!)
      return CLKComplicationTimelineEntry(date: waterLevel.date, complicationTemplate: largeFlat,  timelineAnimationGroup: waterLevel.situation.rawValue)
    }
    return nil
  }
}

// MARK: Displayed Data
extension ComplicationController {
  fileprivate func loadDisplayedStation() -> MeasurementStation? {
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
