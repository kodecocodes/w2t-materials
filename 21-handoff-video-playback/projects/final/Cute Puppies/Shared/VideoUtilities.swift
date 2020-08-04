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

import AVFoundation
import UIKit

class VideoUtilities {
  
  /// A constant denoting that image size shouldn't be changed.
  /// Use this constant in snapshot(fromMovie:, resizeTo:, completion:) or
  /// in snapshot(fromMovieAtURL:, resizeTo:, completion:) to keep the dimension
  /// of the snapshot image the same as the moive.
  static let OriginalSize = CGSize()
  
  /// Create an snapshot of a movie asset and returns UIImage.
  /// The snapshot process is async and done on a secondary thread.
  /// Completion block is called on the main thread.
  static func snapshot(fromMovie asset: AVAsset, resizeTo newSize: CGSize, completion: @escaping (_ image: UIImage) -> Void) {
    DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
      var image = VideoUtilities.snapshotFromMovie(asset: asset)
      
      if !newSize.equalTo(VideoUtilities.OriginalSize) {
        image = VideoUtilities.resize(image: image, toSize: newSize)
      }
      DispatchQueue.main.sync(execute: {
        completion(image)
      })
    }
  }
  
  /// Create an snapshot of a movie at a given URL and returns UIImage.
  /// The snapshot process is async and done on a secondary thread.
  /// Completion block is called on the main thread.
  static func snapshot(fromMovieAtURL URL: URL, resizeTo newSize: CGSize, completion: @escaping (_ image: UIImage) -> Void) {
    let asset = AVAsset(url: URL)
    snapshot(fromMovie: asset, resizeTo: newSize, completion: completion)
  }
  
  /// A prviate method to create an snapshot of a movie and return UIImage.
  private static func snapshotFromMovie(asset: AVAsset) -> UIImage {
    let generator: AVAssetImageGenerator = AVAssetImageGenerator(asset: asset)
    generator.appliesPreferredTrackTransform = true
    
    // Make a snapshot of the frame that's halfway through the video.
    let value: Int64 = asset.duration.value / 2
    let scale = asset.duration.timescale
    let time: CMTime = CMTimeMake(value, scale)
    
    let snapshot: UIImage
    do {
      let imageRef: CGImage = try generator.copyCGImage(at: time, actualTime: nil)
      snapshot = UIImage(cgImage: imageRef)
    }
    catch {
      snapshot = UIImage()
    }
    return snapshot
  }
  
  /// Returns a new copy of the input image, resized to the given scale on the x-axis.
  /// Width to height ratio is preserved.
  static func resize(image: UIImage, toSize size: CGSize) -> UIImage {
    UIGraphicsBeginImageContextWithOptions(size, true, 1.0)
    let rect  = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
    image.draw(in: rect)
    let resizedImage = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    return resizedImage
  }
  
}
