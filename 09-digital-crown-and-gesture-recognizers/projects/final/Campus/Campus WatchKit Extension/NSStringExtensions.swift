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

extension NSString {
  
  func draw(at point: CGPoint, angle: CGFloat, withAttributes attributes: [NSAttributedStringKey: AnyObject]) {
    
    let textSize: CGSize = self.size(withAttributes: attributes)
    
    // sizeWithAttributes is only effective with single line NSString text
    // use boundingRectWithSize for multi line text
    
    let context: CGContext = UIGraphicsGetCurrentContext()!
    
    let transformation: CGAffineTransform = CGAffineTransform(translationX: point.x, y: point.y)
    let rotation: CGAffineTransform = CGAffineTransform(rotationAngle: angle)
    
    context.concatenate(transformation)
    context.concatenate(rotation)
    
    self.draw(at: CGPoint(x: -1 * textSize.width, y: 0), withAttributes: attributes)
    
    context.concatenate(rotation.inverted())
    context.concatenate(transformation.inverted())
    
  }
  
}
