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
import WatchConnectivity

class MovieDetailInterfaceController: WKInterfaceController {
  
  @IBOutlet var movieTitle: WKInterfaceLabel!
  @IBOutlet var time: WKInterfaceLabel!
  @IBOutlet var director: WKInterfaceLabel!
  @IBOutlet var actors: WKInterfaceLabel!
  @IBOutlet var rating: WKInterfaceLabel!
  @IBOutlet var synopsis: WKInterfaceLabel!
  @IBOutlet var buyButton: WKInterfaceButton!
  @IBOutlet var movieTicket: WKInterfaceImage!
  
  var movie: Movie!
    
  lazy var documentsDirectory: String = {
    return NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first!
    }()
  
  lazy var movieTicketFilePath: String = { [unowned self] in
    return self.documentsDirectory + "/QR\(self.movie.id).png"
    }()
  
  var movieTicketImage: UIImage? {
    get {
      return UIImage(contentsOfFile: self.movieTicketFilePath)
    }
  }
  
  // MARK: - Lifecycle
  
  override func awake(withContext context: Any?) {
    super.awake(withContext: context)
    
    if let context = context as? Movie {
      movie = context
      
      setTitle(movie.title)
      movieTitle.setText(movie.title)
      time.setText(movie.time)
      director.setText(movie.director)
      actors.setText(movie.actors)
      synopsis.setText(movie.synopsis)
      
      if TicketOffice.sharedInstance.movieTicketIsAlreadyPurchased(movie.id) {
        buyButton.setHidden(true)
        if let image = movieTicketImage {
          self.movieTicket.setImage(image)
        } else {
          requestTicketForPurchasedMovie(movie)
        }
      } else {
        buyButton.setHidden(false)
      }
    }
  }
  
  override func didAppear() {
    super.didAppear()
    rating.setText(TicketOffice.sharedInstance.movieRatingForID(movie.id))
  }
  
  // MARK: - Segue
  
  override func contextForSegue(withIdentifier segueIdentifier: String) -> Any? {
    return movie
  }
  
  // MARK:
  
  private func saveMovieTicketAndUpdateDisplay(_ movieTicket: Data) {
    DispatchQueue.main.async(execute: { () -> Void in
      do {
        try movieTicket.write(to: URL(fileURLWithPath: self.movieTicketFilePath))
      } catch {
        print("ERROR: Could not write to \(self.movieTicketFilePath)")
      }
      self.movieTicket.setImage(self.movieTicketImage)
    })
  }
  
  private func showReachabilityError() {
    let tryAgain = WKAlertAction(title: "Try Again", style: .default, handler: { () -> Void in })
    let cancel = WKAlertAction(title: "Cancel", style: .cancel, handler: { () -> Void in })
    self.presentAlert(withTitle: "Your iPhone is not reachable.", message: "You movie ticket cannot be shown because your iPhone is not currently connected to your phone. Please ensure your iPhone is on and within range of your Watch.", preferredStyle: WKAlertControllerStyle.alert, actions:[tryAgain, cancel])
  }
}

// MARK: - Watch Connectivity

extension MovieDetailInterfaceController {

  func requestTicketForPurchasedMovie(_ movie: Movie) {
    // TODO: Update to request movie ticket image from phone
  }
}
