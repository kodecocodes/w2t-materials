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

struct WatchGraphGeneratorSettings: GraphGeneratorSettings {
  
  // elements
  var drawBackgroundGradient: Bool = false
  var drawUnderGraphGradient: Bool = true
  var drawGridlines: Bool = true
  var drawPoints: Bool = true
  var drawLine: Bool = false
  var drawPointStroke: Bool = true
  
  // colors
  var graphLineColor: UIColor = UIColor.white
  var gridlineMajorColor: UIColor = UIColor.white.withAlphaComponent(0.3)
  var gridlineMinorColor: UIColor = UIColor.white.withAlphaComponent(0.11)
  var demarcationTitleColor: UIColor = UIColor.white.withAlphaComponent(0.4)
  var underGraphGradientColors: [CGColor] = [UIColor(hex: 0xFE007F).cgColor, UIColor(hex: 0x8D8CFF).cgColor]
  var backgroundGradientColors: [CGColor] = [UIColor.black.cgColor]
  var pointGradientColors: [CGColor] = [UIColor.black.cgColor]
  var pointStrokeGradientColors: [CGColor] = [UIColor(hex: 0xFE007F).cgColor, UIColor(hex: 0x8D8CFF).cgColor]
  var highlightedPointGradientColors: [CGColor] = [UIColor(hex: 0x7ED321).cgColor]
  var highlightedPointOutsetColor: UIColor = UIColor.black
  
  // corners
  var backgroundGradientCornerRadius: Int = 8
  
  // line width
  var gridlineWidth: CGFloat = 1
  var graphLineWidth: CGFloat = 2
  var pointSize: CGFloat = 5
  var pointStrokeWidth: CGFloat = 1
  var highlightedPointSize: CGFloat {
    return pointSize * 3
  }
  var highlightedPointStrokeWidth: CGFloat = 1
  var highlightedPointStrokeDashes: [CGFloat] = [0, 1]
  var demarcationTitleFontSize: CGFloat = 17
  var demarcationTitleRotationAngle = -CGFloat.pi / 2
  
  // insets
  var gridlineHorizontalInsets: CGFloat {
    return pointSize / CGFloat.pi
  }
  var graphHorizontalInsets: CGFloat {
    return pointSize / CGFloat.pi
  }
  var topInset: CGFloat {
    return pointSize / 2
  }
  var bottomInset:CGFloat {
    return pointSize / 2
  }
  var highlightedPointStrokeOutset: CGFloat = 4
  
}
