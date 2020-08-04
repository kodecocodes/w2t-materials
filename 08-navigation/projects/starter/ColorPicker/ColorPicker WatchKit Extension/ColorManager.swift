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

class ColorManager {
  static let defaultManager = ColorManager()
  
  let availableColors = [
    UIColor(red: 0.941176471, green: 0.098039216, blue: 0.08627451, alpha: 1),
    UIColor(red: 0.984313725, green: 0.6, blue: 0, alpha: 1),
    UIColor(red: 0.952941176, green: 0.933333333, blue: 0, alpha: 1),
    UIColor(red: 0, green: 0.603921569, blue: 0.266666667, alpha: 1),
    UIColor(red: 0.215686275, green: 0.317647059, blue: 0.650980392, alpha: 1),
    UIColor(red: 0.780392157, green: 0.094117647, blue: 0.568627451, alpha: 1)
  ]
  var selectedColor: UIColor
  
  init() {
    selectedColor = availableColors.first!
  }
}

public extension UIColor {
  var hexString: String {
    var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0
    getRed(&r, green: &g, blue: &b, alpha: nil)
    
    let strings: [String] = [r, g, b].map { f in
      let i = Int(f * 255.0)
      let str = NSString(format: "%2X", i).trimmingCharacters(in: CharacterSet.whitespaces)
      if str.characters.count == 1 {
        return "0" + str
      } else {
        return str
      }
    }
    
    return strings.reduce("", { return $0 + $1 })
  }
  
  var rgbString: String {
    var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0
    getRed(&r, green: &g, blue: &b, alpha: nil)
    r *= 255
    g *= 255
    b *= 255
    return "r: \(Int(r)), g: \(Int(g)), b: \(Int(b))"
  }
  
  var hslString: String {
    var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0
    getHue(&h, saturation: &s, brightness: &b, alpha: nil)
    h *= 360
    s *= 100
    b *= 100
    return "h: \(Int(h)), s: \(Int(s))%, l: \(Int(b))%"
  }
  
  private func adjust(amount: CGFloat) -> UIColor {
    var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
    if getHue(&h, saturation: &s, brightness: &b, alpha: &a) {
      return UIColor(hue: h,
                     saturation: a,
                     brightness: min(1, max(0, b * amount)),
                     alpha: a)
    } else {
      return self
    }
  }
  
  func lighterColor() -> UIColor {
    return adjust(amount: 1.25)
  }
  
  func darkerColor() -> UIColor {
    return adjust(amount: 0.75)
  }
  
}
