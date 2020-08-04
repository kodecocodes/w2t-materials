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

let drinksGoal = 8.0
let π:CGFloat = .pi

@IBDesignable
class CounterView: UIView {

  @IBInspectable var counter: Double = 0.0 {
    didSet {
      if counter >= drinksGoal {
        // change drinks arc color green to indicate >8 glasses
        drinksArcColor = UIColor(red: 43/256.0, green: 159/256.0, blue: 50/256.0, alpha: 1.0)
      } else {
        drinksArcColor = UIColor(red: 36/256.0, green: 186/256.0, blue: 254/256.0, alpha: 1.0)
      }
    }
  }
  @IBInspectable var baseArcColor: UIColor = UIColor.gray
  @IBInspectable var drinksArcColor: UIColor = UIColor.blue
  
  override func draw(_ rect: CGRect) {
    
    // 1
    let center = CGPoint(x:bounds.width/2, y: bounds.height/2)
    
    // 2
    let radius: CGFloat = max(bounds.width, bounds.height)
    
    // 3
    let arcWidth: CGFloat = 20
    
    // Draw the base grayed-out arc
    // 4
    let startAngle: CGFloat = 3 * π / 4
    let endAngle: CGFloat = π / 4
    
    // 5
    let path = UIBezierPath(arcCenter: center,
      radius: radius/2 - arcWidth/2,
      startAngle: startAngle,
      endAngle: endAngle,
      clockwise: true)
    
    // 6
    path.lineWidth = arcWidth
    baseArcColor.setStroke()
    path.stroke()
    
    //Draw the partial/full blue/green drinks arc
    
    //First calculate the difference between the two angles
    //ensuring it is positive
    let angleDifference: CGFloat = 2 * π - startAngle + endAngle
    
    //then calculate the arc for each single glass
    let arcLengthPerGlass = angleDifference / CGFloat(drinksGoal)
    
    //then multiply out by the actual glasses drunk
    //but stop at 8 glasses
    let numberToDraw = counter < Double(drinksGoal) ? counter : Double(drinksGoal)
    let outlineEndAngle = arcLengthPerGlass * CGFloat(numberToDraw) + startAngle
    
    //Draw the drinks arc
    let drinksArcPath = UIBezierPath(arcCenter: center,
      radius: radius/2 - arcWidth/2,
      startAngle: startAngle,
      endAngle: outlineEndAngle,
      clockwise: true)
    
    drinksArcPath.lineWidth = arcWidth
    drinksArcColor.setStroke()
    drinksArcPath.stroke()
  }
}
