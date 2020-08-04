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


@IBDesignable class PageInterfaceController: WKInterfaceController {
  
  var stock: Stock!
  
  var graphHeightRatio: CGFloat = 0.875 // default also set in interface builder
  var detailsHeightRatio: CGFloat = 0.125 // default also set in interface builder
  
  var screenSize: CGSize {
    return self.contentFrame.size // for convenience
  }
  
  @IBOutlet var graphImage: WKInterfaceImage!
  @IBOutlet var detailsGroup: WKInterfaceGroup!
  @IBOutlet var changeLabel: WKInterfaceLabel!
  @IBOutlet var tickerSymbolLabel: WKInterfaceLabel!
  
  override func awake(withContext context: Any?) {
    super.awake(withContext: context)
    
    if let context = context as? Stock {
      self.stock = context
    }
    
  }
  
  override func willActivate() {
    super.willActivate()
    
    updateForAccessibility()
    
    changeLabel.setText("\(stock.changeCharacter) \(stock.changePercentAsString)")
    
    changeLabel.setTextColor(stock.changeColor)
    
    tickerSymbolLabel.setText(stock.tickerSymbol)
    
    generateImage()
  }
  
  func generateImage() {
	DispatchQueue.global(qos: .default).async {
    
      let graphGenerator = GraphGenerator(settings: WatchGraphGeneratorSettings())
      
      let height = self.graphHeightRatio * self.screenSize.height
      
      let graphRect = CGRect(x: 0, y: 0, width: self.screenSize.width, height: height)
      
      let image = graphGenerator.image(graphRect, with: self.stock.last5days)
      
      DispatchQueue.main.async {
        self.graphImage.setImage(image)
      }
    }
  }
  
  func updateForAccessibility() {
    
  }
  
  func makeLayoutAccessible() {
    
  }
  
  func makeGraphAccessible() {
    
  }
  
  func makeGroupAccessible(){
    
  }
  
  func imageRegionFrameForTrailingIndex(_ trailingIndex: Int) -> CGRect {
    return CGRect()
  }
  
  func summaryForTrailingIndex(_ trailingIndex: Int) -> String {
    return String()
  }
  
  func percentageChangeForVoiceOver(from previous: Double, to current: Double) -> String {
    return String()
  }
  
}
