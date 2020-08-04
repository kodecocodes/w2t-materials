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

class VideoClipProvider {
  
  /// For convenience and share common code. This is the key in a message request
  /// sent by the watch app to the phone, requesting poster image. The value to
  /// this key is from clipReferences dictionary that maps to a video clip.
  static let WCPosterImageRequestKey = "WCPosterImageRequestKey"
  
  /// An array of URL to video assets in the app bundle.
  let clips: [URL]
  
  let quotes: [String] = [
    "Whoever said you can't buy happiness forgot little puppies.",
    "Buy a pup and your money will buy love unflinching.",
    "A puppy plays with every pup he meets",
    "People have been asking me if I was going to have kids, and I had puppies instead.",
    "When you feel lousy, puppy therapy is indicated.",
    "The only creatures that are evolved enough to convey pure love are dogs and infants."
  ]
  
  /// A dictionary representation of video assets. Keys are name of
  /// video clips as String, and values are URL pointing to assets
  /// in the app bundle.
  let clipReferences: [String: URL]
  
  init () {
    
    /// Video clips in the bundle are named sequentially.
    /// To make the code more generic, here you refactor the minimum
    /// and maximum index so that assets can be loaded in a loop.
    let minIndex = 1
    let maxIndex = 3
    
    // Initialize array of clips.
    var files: [URL] = []
    for index in stride(from: minIndex, through: maxIndex, by: 1) {
      let file = Bundle.main.url(forResource: "clip\(index)", withExtension: "mp4")!
      files.append(file)
    }
    clips = files
    
    // Initialize the reference map.
    var references: [String: URL] = [:]
    for clip in clips {
      references[clip.lastPathComponent] = clip
    }
    clipReferences = references
  }
  
}
