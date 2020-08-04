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

@IBDesignable
class PushButtonView: UIButton {
  
  @IBInspectable var fillColor: UIColor = UIColor.green
  @IBInspectable var isAddButton: Bool = true
  
  override func draw(_ rect: CGRect) {
    
    let path = UIBezierPath(ovalIn: rect)
    fillColor.setFill()
    path.fill()
    
    //set up the width and height variables
    //for the horizontal stroke
    let plusHeight: CGFloat = 3.0
    let plusWidth: CGFloat = min(bounds.width, bounds.height) * 0.6
    
    //create the path
    let plusPath = UIBezierPath()
    
    //set the path's line width to the height of the stroke
    plusPath.lineWidth = plusHeight
    
    //move the initial point of the path
    //to the start of the horizontal stroke
    plusPath.move(to: CGPoint(
      x:bounds.width/2 - plusWidth/2 + 0.5,
      y:bounds.height/2 + 0.5))
    
    //add a point to the path at the end of the stroke
    plusPath.addLine(to: CGPoint(
      x:bounds.width/2 + plusWidth/2 + 0.5,
      y:bounds.height/2 + 0.5))
    
    //Vertical Line
    if isAddButton {
      //move to the start of the vertical stroke
      plusPath.move(to: CGPoint(
        x:bounds.width/2 + 0.5,
        y:bounds.height/2 - plusWidth/2 + 0.5))
      
      //add the end point to the vertical stroke
      plusPath.addLine(to: CGPoint(
        x:bounds.width/2 + 0.5,
        y:bounds.height/2 + plusWidth/2 + 0.5))
    }
    
    //set the stroke color
    UIColor.white.setStroke()
    
    //draw the stroke
    plusPath.stroke()
    
  }
  
}
