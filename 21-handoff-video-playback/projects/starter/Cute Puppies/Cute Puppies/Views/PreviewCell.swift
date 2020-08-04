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
import AVFoundation

class PreviewCell: UICollectionViewCell {
  
  // MARK: Public - properties
  
  /// The default cell identifier set in the interface builder, for convenience.
  static let IBIdentifier = "PreviewCellIdentifier"
  
  /// The asset to be displayed by the receiver.
  var asset: AVAsset? {
    didSet {
      updateImageView()
    }
  }
  
  var footnote: String? {
    didSet {
      textLabel.text = footnote
    }
  }
  
  // MARK: Private - properties
  
  @IBOutlet private var textLabel: UILabel!
  @IBOutlet private var imageView: UIImageView!
  @IBOutlet private var loadingIndicator: UIActivityIndicatorView!
  @IBOutlet private var playIcon: UIImageView!
  
  // MARK: Life Cycle
  
  override func awakeFromNib() {
    super.awakeFromNib()
    loadingIndicator.startAnimating()
  }
  
  // MARK: Private
  
  /// Updates the poster image from the asset property of the receiver.
  private func updateImageView() {
    
    guard  let asset = self.asset else {
      imageView.image = nil
      loadingIndicator.stopAnimating()
      playIcon.isHidden = true
      return
    }
    
    loadingIndicator.startAnimating()
    
    VideoUtilities.snapshot(fromMovie: asset, resizeTo: VideoUtilities.OriginalSize) { (image) in
      self.loadingIndicator.stopAnimating()
      self.playIcon.isHidden = false
      self.imageView.image = image
    }
  }
}
