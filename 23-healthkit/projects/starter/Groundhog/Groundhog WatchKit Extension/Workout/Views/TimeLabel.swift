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

import Foundation
import WatchKit

extension WKInterfaceLabel {
  func setTimeInterval(_ interval: TimeInterval) {
    self.setText(interval.elapsedTimeString())
  }
}

extension TimeInterval {
  
  func elapsedTimeString() -> String {
    let h = UInt(self / 3600)
    let m = UInt(self / 60) % 60
    let s = UInt(self.truncatingRemainder(dividingBy: 60))
    
    var formattedTime: String
    
    if (h > 0) {
      formattedTime = String(format: "%lu:%02lu:%02lu", h, m, s)
    } else if (m > 0) {
      formattedTime = String(format: "%lu:%02lu", m, s)
    } else {
      formattedTime = String(format: ":%02lu", s)
    }
    return formattedTime;
  }
  
  func longElapsedTimeString() -> String {
    let h = UInt(self / 3600)
    let m = UInt(self / 60) % 60
    let s = UInt(self.truncatingRemainder(dividingBy: 60))
    
    return String(format: "%lu:%02lu:%02lu", h, m, s)
  }
  
  func elapsedTimeImage() -> UIImage {
    let timeString = self.elapsedTimeString()
    
    let imageSize = CGSize(width: 110, height: 50)
    var image: UIImage
    
    UIGraphicsBeginImageContext(imageSize)
    
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = .right
    var fontAttributes: [NSAttributedStringKey:AnyObject] = [NSAttributedStringKey.foregroundColor : UIColor.white]
    fontAttributes[NSAttributedStringKey.font] = UIFont(name: "Avenir", size: CGFloat(40.0))
    fontAttributes[NSAttributedStringKey.paragraphStyle] = paragraphStyle
    
    let attrString = NSAttributedString(string: timeString, attributes: fontAttributes)
    attrString.draw(in: CGRect(origin: CGPoint(x: 0, y: 0), size: imageSize))
    
    image = UIGraphicsGetImageFromCurrentImageContext()!
    
    UIGraphicsEndImageContext()
    
    return image
  }
}
