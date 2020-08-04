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


protocol GraphGeneratorSettings {
  
  // elements
  var drawBackgroundGradient: Bool { get }
  var drawUnderGraphGradient: Bool { get }
  var drawGridlines: Bool { get }
  var drawPoints: Bool { get }
  
  // colors
  var graphLineColor: UIColor { get }
  var gridlineMajorColor: UIColor { get }
  var gridlineMinorColor: UIColor { get }
  var underGraphGradientTopColor: CGColor { get }
  var underGraphGradientBottomColor: CGColor { get }
  var backgroundGradientTopColor: CGColor { get }
  var backgroundGradientBottomColor: CGColor { get }
  
  // corners
  var backgroundGradientCornerRadius: Int { get }
  
  // line width
  var gridlineWidth: CGFloat { get }
  var graphLineWidth: CGFloat { get }
  var pointSize: CGFloat { get }
  
  // insets
  var gridlineHorizontalInsets: CGFloat { get }
  var graphHorizontalInsets: CGFloat { get }
  var topInset: CGFloat { get }
  var bottomInset: CGFloat { get }
}

struct GraphGenerator {
  
  let settings: GraphGeneratorSettings
  
  func image(_ rect: CGRect, with data: [Double]) -> UIImage {
        
    UIGraphicsBeginImageContextWithOptions(rect.size, false, 0);
    
    draw(rect, with: data)
    
    let image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image!
  }
  
  func draw(_ rect: CGRect, with data: [Double]){
    let width = rect.width
    let height = rect.height
    
    let context = UIGraphicsGetCurrentContext()
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let colorLocations:[CGFloat] = [0.0, 1.0]
    
    
    // calculate an x point
    let columnXPoint = { (column:Int) -> CGFloat in
      //Calculate gap between points
      let spacer = (width - self.settings.graphHorizontalInsets*2 - 4) /
        CGFloat((data.count - 1))
      var x:CGFloat = CGFloat(column) * spacer
      x += self.settings.graphHorizontalInsets + 2
      return x
    }
    
    // calculate a y point
    let graphHeight = height - settings.topInset - settings.bottomInset
    let maxValue = CGFloat(data.max()!)
    let minValue = CGFloat(data.min()!)
    let range = maxValue - minValue
    let columnYPoint = { (graphPoint: CGFloat) -> CGFloat in
      var y:CGFloat = (CGFloat(graphPoint) - minValue) / range * graphHeight
      y = graphHeight + self.settings.topInset - y // Flip the graph
      return y
    }
    
    if settings.drawBackgroundGradient {
      
      // set up background clipping area
      let path = UIBezierPath(roundedRect: rect,
        byRoundingCorners: UIRectCorner.allCorners,
        cornerRadii: CGSize(width: settings.backgroundGradientCornerRadius, height: settings.backgroundGradientCornerRadius))
      path.addClip()
      let colors = [settings.backgroundGradientTopColor, settings.backgroundGradientBottomColor] as CFArray
      let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: colorLocations)
      
      // draw the gradient
      let startPoint = CGPoint.zero
      let endPoint = CGPoint(x:0, y: height)
      context?.drawLinearGradient(gradient!, start: startPoint, end: endPoint, options: [])
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
    graphPath.move(to: CGPoint(x:columnXPoint(0),
      y:columnYPoint(CGFloat(data[0]))))
    
    //add points for each item in the graphPoints array
    //at the correct (x, y) for the point
    for i in 1..<data.count {
      let nextPoint = CGPoint(x:columnXPoint(i),
        y:columnYPoint(CGFloat(data[i])))
      graphPath.addLine(to: nextPoint)
    }
    
    // Create the clipping path for the graph gradient
    
    if settings.drawUnderGraphGradient {
      
      // save the state of the context (commented out for now)
      context?.saveGState()
      
      // make a copy of the path
      let clippingPath = graphPath.copy() as! UIBezierPath
      
      // add lines to the copied path to complete the clip area
      clippingPath.addLine(to: CGPoint(
        x: columnXPoint(data.count - 1),
        y:height))
      clippingPath.addLine(to: CGPoint(
        x:columnXPoint(0),
        y:height))
      clippingPath.close()
      
      // add the clipping path to the context
      clippingPath.addClip()
      
      let highestYPoint = columnYPoint(maxValue)
      let startPoint = CGPoint(x: settings.graphHorizontalInsets, y: highestYPoint)
      let endPoint = CGPoint(x: settings.graphHorizontalInsets, y:height)
      
      // setup the gradient
      let colors = [settings.underGraphGradientTopColor, settings.underGraphGradientBottomColor] as CFArray
      let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: colorLocations)
      context?.drawLinearGradient(gradient!, start: startPoint, end: endPoint, options: [])
      context?.restoreGState()
      
    }
    
    // draw the line on top of the clipped gradient
    graphPath.lineWidth = settings.graphLineWidth
    graphPath.stroke()
    
    if settings.drawPoints {
      
      // draw the circles on top of graph stroke
      for i in 0..<data.count {
        var point = CGPoint(x:columnXPoint(i), y:columnYPoint(CGFloat(data[i])))
        point.x -= settings.pointSize / 2
        point.y -= settings.pointSize / 2
        
        let circle = UIBezierPath(ovalIn:
          CGRect(origin: point,
            size: CGSize(width: settings.pointSize, height: settings.pointSize)))
        circle.fill()
      }
    }

  }
}
