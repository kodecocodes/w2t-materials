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

class ComplicationController: NSObject, CLKComplicationDataSource {

  // MARK: Register
  func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Swift.Void) {
    // 1
    if complication.family == .utilitarianSmall {
      // 2
      let smallFlat = CLKComplicationTemplateUtilitarianSmallFlat()
      // 3
      smallFlat.textProvider = CLKSimpleTextProvider(text: "+2.6m")
      // 4
      smallFlat.imageProvider = CLKImageProvider(
        onePieceImage: UIImage(named: "tide_high")!)
      // 5
      handler(smallFlat)
    } else if complication.family == .utilitarianLarge {
      let largeFlat = CLKComplicationTemplateUtilitarianLargeFlat()
      largeFlat.textProvider = CLKSimpleTextProvider(
        text: "Rising, +2.6m", shortText:"+2.6m")
      largeFlat.imageProvider = CLKImageProvider(
        onePieceImage: UIImage(named: "tide_high")!)

      handler(largeFlat)
    }
  }

  // MARK: Provide Data
  public func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
    let conditions = TideConditions.loadConditions()
    guard let waterLevel = conditions.currentWaterLevel else {
      // No data is cached yet
      handler(nil)
      return
    }

    let tideImageName: String
    switch waterLevel.situation {
    case .High: tideImageName = "tide_high"
    case .Low: tideImageName = "tide_low"
    case .Rising: tideImageName = "tide_rising"
    case .Falling: tideImageName = "tide_falling"
    default: tideImageName = "tide_high"
    }

    // 1
    if complication.family == .utilitarianSmall {
      let smallFlat = CLKComplicationTemplateUtilitarianSmallFlat()
      smallFlat.textProvider = CLKSimpleTextProvider(
        text: waterLevel.shortTextForComplication)
      smallFlat.imageProvider = CLKImageProvider(
        onePieceImage: UIImage(named: tideImageName)!)

      // 2
      handler(CLKComplicationTimelineEntry(
        date: waterLevel.date, complicationTemplate: smallFlat))
    } else {
      let largeFlat = CLKComplicationTemplateUtilitarianLargeFlat()
      largeFlat.textProvider = CLKSimpleTextProvider(
        text: waterLevel.longTextForComplication,
        shortText:waterLevel.shortTextForComplication)
      largeFlat.imageProvider = CLKImageProvider(
        onePieceImage: UIImage(named: tideImageName)!)

      handler(CLKComplicationTimelineEntry(
        date: waterLevel.date, complicationTemplate: largeFlat))
    }
  }

  // MARK: Time Travel
  func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Swift.Void) {
    handler([])
  }

}
