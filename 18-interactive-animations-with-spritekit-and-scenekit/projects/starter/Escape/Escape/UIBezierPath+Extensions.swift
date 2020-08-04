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

/// Adapted by Rob http://stackoverflow.com/users/1271826/rob to Swift
/// From https://github.com/jnfisher/ios-curve-interpolation
/// See http://spin.atomicobject.com/2014/05/28/ios-interpolating-points/

import SpriteKit

extension UIBezierPath {
  
  /// Create smooth UIBezierPath using Hermite Spline
  ///
  /// This requires at least two points.
  ///
  /// - parameter hermiteInterpolatedPoints: The array of CGPoint values.
  /// - parameter closed:                    Whether the path should be closed or not
  ///
  /// - returns:  An initialized `UIBezierPath`, or `nil` if an object could not be created for some reason (e.g. not enough points).
  
  convenience init?(hermiteInterpolatedPoints points:[CGPoint], closed: Bool) {
    self.init()
    
    guard points.count > 1 else { return nil }
    
    let numberOfCurves = closed ? points.count : points.count - 1
    
    var previousPoint: CGPoint? = closed ? points.last : nil
    var currentPoint:  CGPoint  = points[0]
    var nextPoint:     CGPoint? = points[1]
    
    move(to: currentPoint)
    
    for index in 0 ..< numberOfCurves {
      let endPt = nextPoint!
      
      var mx: CGFloat
      var my: CGFloat
      
      if previousPoint != nil {
        mx = (nextPoint!.x - currentPoint.x) * 0.5 + (currentPoint.x - previousPoint!.x)*0.5
        my = (nextPoint!.y - currentPoint.y) * 0.5 + (currentPoint.y - previousPoint!.y)*0.5
      } else {
        mx = (nextPoint!.x - currentPoint.x) * 0.5
        my = (nextPoint!.y - currentPoint.y) * 0.5
      }
      
      let ctrlPt1 = CGPoint(x: currentPoint.x + mx / 3.0, y: currentPoint.y + my / 3.0)
      
      previousPoint = currentPoint
      currentPoint = nextPoint!
      let nextIndex = index + 2
      if closed {
        nextPoint = points[nextIndex % points.count]
      } else {
        nextPoint = nextIndex < points.count ? points[nextIndex % points.count] : nil
      }
      
      if nextPoint != nil {
        mx = (nextPoint!.x - currentPoint.x) * 0.5 + (currentPoint.x - previousPoint!.x) * 0.5
        my = (nextPoint!.y - currentPoint.y) * 0.5 + (currentPoint.y - previousPoint!.y) * 0.5
      }
      else {
        mx = (currentPoint.x - previousPoint!.x) * 0.5
        my = (currentPoint.y - previousPoint!.y) * 0.5
      }
      
      let ctrlPt2 = CGPoint(x: currentPoint.x - mx / 3.0, y: currentPoint.y - my / 3.0)
      
      addCurve(to: endPt, controlPoint1: ctrlPt1, controlPoint2: ctrlPt2)
    }
    
    if closed { close() }
  }
  
  /// Create smooth UIBezierPath using Catmull-Rom Splines
  ///
  /// This requires at least four points.
  ///
  /// - parameter catmullRomInterpolatedPoints: The array of CGPoint values.
  /// - parameter closed:                       Whether the path should be closed or not
  /// - parameter alpha:                        The alpha factor to be applied to Catmull-Rom spline.
  ///
  /// - returns:  An initialized `UIBezierPath`, or `nil` if an object could not be created for some reason (e.g. not enough points).
  
  convenience init?(catmullRomInterpolatedPoints points:[CGPoint], closed: Bool, alpha: Float) {
    self.init()
    
    guard points.count > 3 else { return nil }
    
    assert(alpha >= 0 && alpha <= 1.0, "Alpha must be between 0 and 1")
    
    let endIndex = closed ? points.count : points.count - 2
    
    let startIndex = closed ? 0 : 1
    
    let kEPSILON: Float = 1.0e-5
    
    move(to: points[startIndex])
    
    for index in startIndex ..< endIndex {
      let nextIndex = (index + 1) % points.count
      let nextNextIndex = (nextIndex + 1) % points.count
      let previousIndex = index < 1 ? points.count - 1 : index - 1
      
      let point0 = points[previousIndex]
      let point1 = points[index]
      let point2 = points[nextIndex]
      let point3 = points[nextNextIndex]
      
      let d1 = hypot(Float(point1.x - point0.x), Float(point1.y - point0.y))
      let d2 = hypot(Float(point2.x - point1.x), Float(point2.y - point1.y))
      let d3 = hypot(Float(point3.x - point2.x), Float(point3.y - point2.y))
      
      let d1a2 = powf(d1, alpha * 2)
      let d1a  = powf(d1, alpha)
      let d2a2 = powf(d2, alpha * 2)
      let d2a  = powf(d2, alpha)
      let d3a2 = powf(d3, alpha * 2)
      let d3a  = powf(d3, alpha)
      
      var controlPoint1: CGPoint, controlPoint2: CGPoint
      
      if fabs(d1) < kEPSILON {
        controlPoint1 = point2
      } else {
        let a = 2 * d1a2 + 3 * d1a * d2a + d2a2
        let b = 3 * d1a * (d1a + d2a)
        controlPoint1 = (point2 * d1a2 - point0 * d2a2 + point1 * a) / b
      }
      
      if fabs(d3) < kEPSILON {
        controlPoint2 = point2
      } else {
        let a = 2 * d3a2 + 3 * d3a * d2a + d2a2
        let b = 3 * d3a * (d3a + d2a)
        controlPoint2 = (point1 * d3a2 - point3 * d2a2 + point2 * a) / b
      }
      
      addCurve(to: point2, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
    }
    
    if closed { close() }
  }
  
}

// Some functions to make the Catmull-Rom splice code a little more readable.
// These multiply/divide a `CGPoint` by a scalar and add/subtract one `CGPoint`
// from another.

private func * (lhs: CGPoint, rhs: Float) -> CGPoint {
  return CGPoint(x: lhs.x * CGFloat(rhs), y: lhs.y * CGFloat(rhs))
}

private func / (lhs: CGPoint, rhs: Float) -> CGPoint {
  return CGPoint(x: lhs.x / CGFloat(rhs), y: lhs.y / CGFloat(rhs))
}
