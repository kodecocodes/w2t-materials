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

class InterfaceController: WKInterfaceController {
  
  let clipProvider = VideoClipProvider()
  let posterImageProvider = PosterImageProvider()
  
  // MARK: Properties
  
  @IBOutlet private var table: WKInterfaceTable!
  
  // MARK: Life Cycle
  
  override func awake(withContext context: Any?) {
    super.awake(withContext: context)
    initializeTable()
  }
  
  override func willActivate() {
    super.willActivate()
    updateTable()
    
    // Handoff.
    let userInfo: [AnyHashable: Any] = [
      Handoff.version.key: Handoff.version.number,
      Handoff.activityValueKey: ""
    ]
    updateUserActivity(Handoff.Activity.viewHome.stringValue,
                       userInfo: userInfo,
                       webpageURL: nil)
  }
  
  override func didDeactivate() {
    super.didDeactivate()
  }
  
  override func contextForSegue(withIdentifier segueIdentifier: String, in table: WKInterfaceTable, rowIndex: Int) -> Any? {
    return rowIndex
  }
  
  // MARK: Private - methods
  
  private func initializeTable() {
    let count = clipProvider.clips.count
    table.setNumberOfRows(count, withRowType: VideoRowController.IBIdentifier)
  }
  
  func updateTable() {
    let clips = clipProvider.clips
    for (index, clip) in clips.enumerated() {
      let rowController = table.rowController(at: index) as! VideoRowController
      let imageData = posterImageProvider.imageDataForClip(withURL: clip)
      let hasImageData = (imageData != nil)
      rowController.image.setImageData(imageData)
      rowController.image.setHidden(!hasImageData)
      rowController.textLabel.setText("Loading...")
      rowController.textLabel.setHidden(hasImageData)
    }
  }
}
