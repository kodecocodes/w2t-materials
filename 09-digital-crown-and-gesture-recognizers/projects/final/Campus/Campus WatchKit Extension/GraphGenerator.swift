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

struct GraphDemarcation { // to draw a vertical gridline, mark each day at midnight
  let title: String
  let index: Int
}

protocol GraphGeneratorSettings {
  
  // elements
  var drawBackgroundGradient: Bool { get }
  var drawUnderGraphGradient: Bool { get }
  var drawGridlines: Bool { get }
  var drawPoints: Bool { get }
  var drawLine: Bool { get }
  var drawPointStroke: Bool { get }
  
  // colors
  var graphLineColor: UIColor { get }
  var gridlineMajorColor: UIColor { get }
  var gridlineMinorColor: UIColor { get }
  var demarcationTitleColor: UIColor { get }
  var underGraphGradientColors: [CGColor] { get }
  var backgroundGradientColors: [CGColor] { get }
  var pointGradientColors: [CGColor] { get }
  var pointStrokeGradientColors: [CGColor] { get }
  var highlightedPointGradientColors: [CGColor] { get }
  var highlightedPointOutsetColor: UIColor { get }
  
  // corners
  var backgroundGradientCornerRadius: Int { get }
  
  // line width
  var gridlineWidth: CGFloat { get }
  var graphLineWidth: CGFloat { get }
  var pointSize: CGFloat { get }
  var pointStrokeWidth: CGFloat { get }
  var highlightedPointSize: CGFloat { get }
  var highlightedPointStrokeWidth: CGFloat { get }
  var highlightedPointStrokeDashes: [CGFloat] { get }
  var demarcationTitleFontSize: CGFloat { get }
  var demarcationTitleRotationAngle: CGFloat { get }
  
  // insets
  var gridlineHorizontalInsets: CGFloat { get }
  var graphHorizontalInsets: CGFloat { get }
  var topInset: CGFloat { get }
  var bottomInset: CGFloat { get }
  var highlightedPointStrokeOutset: CGFloat { get }
}

struct GraphGenerator {
  
  let settings: GraphGeneratorSettings
  
  func image(_ size: CGSize, with data: [Double], highlight highlightedIndex: Int? = nil, demarcations: [GraphDemarcation]? = nil) -> UIImage {
    
    UIGraphicsBeginImageContextWithOptions(size, true, 0) // opaque for performance
    
    draw(size, with: data, highlight: highlightedIndex, demarcations: demarcations)
    
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    //    // Quartz Framework (not available in WatchKit yet)
    //    let format = UIGraphicsImageRendererFormat()
    //    format.scale = 1 // use pixels instead of points
    //    format.opaque = true // NOT transparent
    //
    //    let renderer = UIGraphicsImageRenderer(size: size, format: format)
    //    let image = renderer.image { imageRendererContext in
    //      draw(context: imageRendererContext.cgContext, size: size, with: data, highlight: highlightedIndex, demarcations: demarcations)
    //    }
    
    return image!
  }
  
  func draw(_ size: CGSize, with data: [Double], highlight highlightedIndex: Int? = nil, demarcations: [GraphDemarcation]? = nil){
    let width = size.width
    let height = size.height
    let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: size)
    
    guard let context = UIGraphicsGetCurrentContext() else {
      return
    }
    
    let colorSpace = context.colorSpace
    let colorLocations:[CGFloat] = [0.0, 1.0]
    
    // calculate an x of point
    func pointX(column: Int) -> CGFloat {
      //Calculate gap between points
      let spacer = (width - self.settings.graphHorizontalInsets*2 - 4) /
        CGFloat((data.count - 1))
      var x:CGFloat = CGFloat(column) * spacer
      x += self.settings.graphHorizontalInsets + 2
      return x
    }
    
    // calculate a y of point
    let graphHeight = height - settings.topInset - settings.bottomInset
    let maxValue = CGFloat(data.max()!)
    let minValue = CGFloat(data.min()!)
    let range = maxValue - minValue
    func pointY(for value: CGFloat) -> CGFloat {
      var y: CGFloat = (CGFloat(value) - minValue) / range * graphHeight
      y = graphHeight + self.settings.topInset - y // Flip the graph
      return y
    }
    
    if settings.drawBackgroundGradient {
      
      // set up background clipping area
      let path = UIBezierPath(roundedRect: rect,
                              byRoundingCorners: UIRectCorner.allCorners,
                              cornerRadii: CGSize(width: settings.backgroundGradientCornerRadius, height: settings.backgroundGradientCornerRadius))
      path.addClip()
      let colors = settings.backgroundGradientColors
      let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: colorLocations)
      
      // draw the gradient
      let startPoint = CGPoint.zero
      let endPoint = CGPoint(x:0, y: height)
      context.drawLinearGradient(gradient!, start: startPoint, end: endPoint, options: [])
    }
    
    if settings.drawGridlines {
      
      // path for gridlines to be drawn underneath everything
      var linePath = UIBezierPath()
      
      // top major gridline
      linePath.move(to: CGPoint(x:settings.gridlineHorizontalInsets, y: settings.topInset))
      linePath.addLine(to: CGPoint(x: width - settings.gridlineHorizontalInsets,
                                   y: settings.topInset))
      
      // center major gridline
      linePath.move(to: CGPoint(x: settings.gridlineHorizontalInsets,
                                y: graphHeight/2 + settings.topInset))
      linePath.addLine(to: CGPoint(x:width - settings.gridlineHorizontalInsets,
                                   y:graphHeight/2 + settings.topInset))
      
      // bottom major gridline
      linePath.move(to: CGPoint(x: settings.gridlineHorizontalInsets,
                                y:height - settings.bottomInset))
      linePath.addLine(to: CGPoint(x:width - settings.gridlineHorizontalInsets,
                                   y:height - settings.bottomInset))
      
      // demarcations | vertical gridlines
      if let demarcations = demarcations {
        for demarcation in demarcations {
          linePath.move(to: CGPoint(x: pointX(column: demarcation.index),
                                    y: settings.topInset))
          linePath.addLine(to: CGPoint(x: pointX(column: demarcation.index),
                                       y: graphHeight + settings.topInset))
          let text = NSString(string: demarcation.title)
          let textAttributes: [NSAttributedStringKey: AnyObject] = [
            NSAttributedStringKey.foregroundColor: settings.demarcationTitleColor,
            NSAttributedStringKey.font: UIFont.systemFont(ofSize: settings.demarcationTitleFontSize)
          ]
          text.draw(at: CGPoint(x: pointX(column: demarcation.index),
                                y: settings.topInset * 2),
                    angle: settings.demarcationTitleRotationAngle,
                    withAttributes: textAttributes)
        }
      }
      
      // stroke major gridlines
      settings.gridlineMajorColor.setStroke()
      linePath.lineWidth = settings.gridlineWidth
      linePath.stroke()
      
      linePath = UIBezierPath() // reset to empty
      
      // top quarter minor gridline
      linePath.move(to: CGPoint(x: settings.gridlineHorizontalInsets,
                                y: graphHeight/4 + settings.topInset))
      linePath.addLine(to: CGPoint(x:width - settings.gridlineHorizontalInsets,
                                   y:graphHeight/4 + settings.topInset))
      
      // bottom quarter minor gridline
      linePath.move(to: CGPoint(x: settings.gridlineHorizontalInsets,
                                y: graphHeight/4*3 + settings.topInset))
      linePath.addLine(to: CGPoint(x:width - settings.gridlineHorizontalInsets,
                                   y:graphHeight/4*3 + settings.topInset))
      
      
      // stroke minor gridlines
      settings.gridlineMinorColor.setStroke()
      linePath.lineWidth = settings.gridlineWidth
      linePath.stroke()
    }
    
    // draw the graph on top of the gridlines
    settings.graphLineColor.setFill()
    settings.graphLineColor.setStroke()
    
    //set up the points line
    let graphPath = UIBezierPath()
    //go to start of line
    graphPath.move(to: CGPoint(x: pointX(column: 0),
                               y: pointY(for: CGFloat(data[0]))))
    
    //add points for each item in the graphPoints array
    //at the correct (x, y) for the point
    for i in 1..<data.count {
      let nextPoint = CGPoint(x: pointX(column: i),
                              y: pointY(for: CGFloat(data[i])))
      graphPath.addLine(to: nextPoint)
    }
    
    // Create the clipping path for the graph gradient
    
    if settings.drawUnderGraphGradient {
      
      context.saveGState()
      let clippingPath = graphPath.copy() as! UIBezierPath
      
      // add lines to the copied path to complete the clip area to the bottom of the screen
      clippingPath.addLine(to: CGPoint(
        x: pointX(column: data.count - 1),
        y: height))
      clippingPath.addLine(to: CGPoint(
        x: pointX(column: 0),
        y: height))
      clippingPath.close()
      clippingPath.addClip()
      let highestYPoint = pointY(for: maxValue)
      let startPoint = CGPoint(x: settings.graphHorizontalInsets, y: highestYPoint)
      let endPoint = CGPoint(x: settings.graphHorizontalInsets, y: height)
      let colors = settings.underGraphGradientColors
      let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: colorLocations)
      context.drawLinearGradient(gradient!, start: startPoint, end: endPoint, options: [])
      context.restoreGState()
      
    }
    
    if settings.drawLine {
      // draw the line on top of the clipped gradient
      graphPath.lineWidth = settings.graphLineWidth
      graphPath.stroke()
    }
    
    func pointPathForColumn(_ index: Int) -> UIBezierPath {
      var point = CGPoint(x: pointX(column: index), y: pointY(for: CGFloat(data[index])))
      let pointSize = index != highlightedIndex ? settings.pointSize : settings.highlightedPointSize
      
      point.x -= pointSize / 2
      point.y -= pointSize / 2
      
      return UIBezierPath(ovalIn:
        CGRect(origin: point,
               size: CGSize(width: pointSize, height: pointSize)))
    }
    
    if settings.drawPoints {
      
      // draw the circles on top of graph stroke
      for i in 0..<data.count {
        
        guard i != highlightedIndex else {
          continue // skip this iteration and move to next x column
        }
        
        let circle = pointPathForColumn(i)
        
        // draw point gradient fill
        context.saveGState()
        let clippingPath = circle.copy() as! UIBezierPath
        clippingPath.addClip()
        let startPoint = CGPoint(x: circle.bounds.origin.x, y: circle.bounds.origin.y)
        let endPoint = CGPoint(x: circle.bounds.origin.x, y: circle.bounds.origin.y + circle.bounds.size.height)
        let colors = settings.pointGradientColors
        let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: colorLocations)
        context.drawLinearGradient(gradient!, start: startPoint, end: endPoint, options: [])
        context.restoreGState()
        
        if settings.drawPointStroke && i != highlightedIndex {
          // draw point gradient stroke
          context.saveGState()
          context.addPath(circle.cgPath)
          context.setLineWidth(settings.pointStrokeWidth)
          context.replacePathWithStrokedPath()
          context.clip()
          let gradient = CGGradient(colorsSpace: colorSpace, colors: settings.pointStrokeGradientColors as CFArray, locations: colorLocations)
          let strokeStartPoint = CGPoint(x: startPoint.x, y: startPoint.y - settings.pointStrokeWidth)
          let strokeEndPoint = CGPoint(x: endPoint.x, y: endPoint.y + settings.pointStrokeWidth)
          context.drawLinearGradient(gradient!, start: strokeStartPoint, end: strokeEndPoint, options: [])
          context.restoreGState()
        }
        
      }
      
      if highlightedIndex != nil {
        // draw highlighted point
        
        let innerCircle = pointPathForColumn(highlightedIndex!)
        
        // draw the outset path
        let outsetPathOrigin = CGPoint(x: innerCircle.bounds.origin.x - settings.highlightedPointStrokeOutset / 2,
                                       y: innerCircle.bounds.origin.y - settings.highlightedPointStrokeOutset / 2)
        let outsetPathSize = CGSize(width: innerCircle.bounds.size.width + settings.highlightedPointStrokeOutset,
                                    height: innerCircle.bounds.size.height + settings.highlightedPointStrokeOutset)
        let outsetPath = UIBezierPath(ovalIn: CGRect(origin: outsetPathOrigin, size: outsetPathSize))
        settings.highlightedPointOutsetColor.setFill()
        outsetPath.fill()
        
        // draw the filled gradient
        let strokePathOrigin = CGPoint(x: outsetPath.bounds.origin.x - settings.highlightedPointStrokeWidth / 2,
                                       y: outsetPath.bounds.origin.y - settings.highlightedPointStrokeWidth / 2)
        let strokePathSize = CGSize(width: outsetPath.bounds.size.width + settings.highlightedPointStrokeWidth,
                                    height: outsetPath.bounds.size.height + settings.highlightedPointStrokeWidth)
        let dashedStrokePath = UIBezierPath(ovalIn: CGRect(origin: strokePathOrigin, size: strokePathSize))
        context.saveGState()
        context.addPath(dashedStrokePath.cgPath)
        context.setLineWidth(settings.highlightedPointStrokeWidth)
        context.setLineDash(phase: 0, lengths: settings.highlightedPointStrokeDashes)
        context.replacePathWithStrokedPath()
        context.addPath(innerCircle.cgPath)
        context.clip()
        let gradient = CGGradient(colorsSpace: colorSpace, colors: settings.highlightedPointGradientColors as CFArray, locations: colorLocations)
        let strokeStartPoint = CGPoint(x: strokePathOrigin.x, y: strokePathOrigin.y - settings.highlightedPointStrokeWidth)
        let strokeEndPoint = CGPoint(x: strokePathOrigin.x, y: strokePathOrigin.y + size.height + settings.highlightedPointStrokeWidth)
        context.drawLinearGradient(gradient!, start: strokeStartPoint, end: strokeEndPoint, options: [])
        context.restoreGState()
      }
    }
    
  }
}
