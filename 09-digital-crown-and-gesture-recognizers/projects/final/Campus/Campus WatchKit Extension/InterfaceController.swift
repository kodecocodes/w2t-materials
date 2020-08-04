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

enum InteractionMode: String {
  case move, zoom, inspect
  mutating func next() {
    switch self {
    case .move:
      self = .zoom
    case .zoom:
      self = .inspect
    case .inspect:
      self = .move
    }
  }
}

class InterfaceController: WKInterfaceController {
  
  var isDrawing = false
  let graphGenerator = GraphGenerator(settings: WatchGraphGeneratorSettings())
  @IBOutlet var graphImage: WKInterfaceImage!
  var interactionMode: InteractionMode! {
    didSet {
      switch interactionMode! {
      case .move, .zoom:
        self.setTitle(
          "[\(interactionMode.rawValue.capitalized) mode]")
        highlightedPointIndex = nil
      case .inspect:
        highlightedPointIndex = preparedData().count / 2
      }
      generateImage()
    }
  }
  var accumulatedDigitalCrownDelta = 0.0
  var offset = 0.0
  var zoom = 1.0
  var highlightedPointIndex: Int? {
    didSet {
      if highlightedPointIndex != nil {
        self.setTitle(stringFromHighlightedIndex())
      }
    }
  }
  var previousPanPoint: CGPoint?
  
  override func awake(withContext context: Any?) {
    super.awake(withContext: context)
    
    interactionMode = .move
    crownSequencer.delegate = self
  }
  
  override func willActivate() {
    super.willActivate()
    
    generateImage()
    crownSequencer.focus()
  }
  
  // Preparing data
  
  func stringFromHighlightedIndex() -> String {
    // 1
    let data = preparedData()
    let census = data[highlightedPointIndex!]
    // 2
    let dateFormatter = DateFormatter()
    dateFormatter.timeStyle = .short
    let dateString = dateFormatter.string(from: census.timestamp)
    // 3
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .decimal
    let numberString = numberFormatter.string(from: NSNumber(value:
      census.attendance))!
    return "\(dateString): \(numberString)"
  }
  
  func preparedData() -> [Census] {
    // 1
    let dataCount = Int(round(Double(measurementsPerDay) * zoom))
    let dataCountOffset = Int(round(Double(measurementsPerDay) * self.offset))
    // 2
    let minRange = censuses.count - dataCount - dataCountOffset
    let maxRange = censuses.count - dataCountOffset
    
    var data = [Census]()
    for x in minRange..<maxRange {
      if x < censuses.count && x >= 0 {
        data.append(censuses[x])
      }
    }
    return data
  }
  
  func preparedDemarcations() -> [GraphDemarcation] {
    let censusesAroundMidnight = preparedData().enumerated().filter() {
      index, element in
      let date = element.timestamp
      let maxDate = date.roundedToMidnight().adding(minutes: measurementIntervalMinutes / 2)
      let minDate = date.roundedToMidnight().adding(minutes: -measurementIntervalMinutes / 2)
      return date >= minDate && date <= maxDate
    }
    let demarcations: [GraphDemarcation] = censusesAroundMidnight.map() {
      index, element in
      let formatter = DateFormatter()
      formatter.dateStyle = .short
      return GraphDemarcation(title: formatter.string(from: element.timestamp), index: index)
    }
    return demarcations
  }
  
  func generateImage() {
    // Avoid drawing the graph when there's no data or when a draw is already in progress
    guard !preparedData().isEmpty && !isDrawing else {
      return
    }
    
    isDrawing = true
    
    DispatchQueue.global(qos: .background).async {
      
      let data = self.preparedData().map{Double($0.attendance)}
      
      let demarcations = self.preparedDemarcations()
      
      let image = self.graphGenerator.image(self.contentFrame.size, with:
        data, highlight: self.highlightedPointIndex, demarcations:
        demarcations)
      
      DispatchQueue.main.async {
        self.graphImage.setImage(image)
        self.isDrawing = false
      }
    }
  }
  
  // Handling interactions
  
  func handleInteraction(_ delta: Double) {
    // 1
    accumulatedDigitalCrownDelta = 0
    // 2
    switch interactionMode! {
    case .move:
      // 1
      var newOffset = offset + delta
      // 2
      let maxOffset: Double = Double(daysOfRecord) - 1
      let minOffset: Double = 0
      // 3
      if newOffset > maxOffset {
        newOffset = maxOffset
      } else if newOffset < minOffset {
        newOffset = minOffset
      }
      // 4
      offset = newOffset
    case .zoom:
      // 1
      var newZoom = zoom + delta
      // 2
      let maxZoom = 3.0
      let minZoom = 0.1
      // 3
      if newZoom > maxZoom {
        newZoom = maxZoom
      } else if newZoom < minZoom {
        newZoom = minZoom
      }
      zoom = newZoom
    case .inspect:
      // 1
      let direction = delta > 0 ? 1 : -1
      // 2
      var newIndex = highlightedPointIndex! + direction
      // 3
      let count = preparedData().count
      if newIndex >= count {
        newIndex = count - 1
      } else if newIndex < 0 {
        newIndex = 0 }
      highlightedPointIndex! = newIndex
    }
    // 3
    generateImage()
  }
  
  func reset() {
    offset = 0
    zoom = 1
    generateImage()
  }
  
  // Force Touch Menu
  
  @IBAction func zoomMenuItemPressed() {
    interactionMode = .zoom
  }
  @IBAction func movMenuItemPressed() {
    interactionMode = .move
  }
  @IBAction func inspectMenuItemPressed() {
    interactionMode = .inspect
  }
  @IBAction func resetMenuItemPressed() {
    reset()
  }
  
  @IBAction func tapGestureRecognized(_ sender: Any) {
    interactionMode.next()
  }
  
  @IBAction func panGestureRecognized(_ sender: Any) {
    // 1
    guard let panGesture = sender as? WKPanGestureRecognizer else {
      return
    }
    // 2
    switch panGesture.state {
    // 3
    case .began:
      previousPanPoint = panGesture.locationInObject()
    // 4
    case .changed:
      guard let previousPanPoint = previousPanPoint else {
        return
      }
      let currentPanPoint = panGesture.locationInObject()
      let deltaX = currentPanPoint.x - previousPanPoint.x
      // 5
      let percentageChange = deltaX / self.contentFrame.size.width
      handleInteraction(Double(percentageChange))
      self.previousPanPoint = currentPanPoint
    // 6
    default:
      previousPanPoint = nil
      break
    }
  }
}

extension InterfaceController: WKCrownDelegate {
  func crownDidRotate(_ crownSequencer: WKCrownSequencer?,
                      rotationalDelta: Double) {
    accumulatedDigitalCrownDelta += rotationalDelta
    // 1
    let threshold = 0.05
    // 2
    guard abs(accumulatedDigitalCrownDelta) > threshold else {
      return
    }
    // 3
    handleInteraction(accumulatedDigitalCrownDelta)
  }
  
  func crownDidBecomeIdle(_ crownSequencer: WKCrownSequencer?) {
    handleInteraction(accumulatedDigitalCrownDelta)
  }
  
}
