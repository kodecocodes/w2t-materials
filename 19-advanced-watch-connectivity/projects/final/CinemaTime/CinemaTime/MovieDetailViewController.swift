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
import WatchConnectivity

class MovieDetailViewController: UIViewController {
  
  @IBOutlet weak var poster: UIImageView!
  @IBOutlet weak var movieTitle: UILabel!
  @IBOutlet weak var synopsis: UILabel!
  @IBOutlet weak var time: UILabel!
  @IBOutlet weak var director: UILabel!
  @IBOutlet weak var actors: UILabel!
  @IBOutlet weak var rating: UIButton!
  @IBOutlet weak var buyTicketButton: UIButton!
  @IBOutlet weak var QRImageView: UIImageView!
  
  var movie: Movie!
  lazy var notificationCenter: NotificationCenter = {
    return NotificationCenter.default
    }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = movie.title
    movieTitle.text = movie.title
    time.text = movie.time
    synopsis.text = movie.synopsis
    poster.image = UIImage(named: movie.poster)
    director.text = movie.director
    actors.text = movie.actors
    rating.setTitle(TicketOffice.sharedInstance.movieRatingForID(movie.id), for: UIControlState())
    if TicketOffice.sharedInstance.movieTicketIsAlreadyPurchased(movie.id) {
        let qrCode = QRCode(movie.id)
        QRImageView.image = qrCode?.image
        buyTicketButton.isHidden = true
    } else {
        QRImageView.isHidden = true
    }
  }
  
  @IBAction func butTicketWasTapped(_ sender: UIButton) {

    let alert = UIAlertController(title: "Purchase Ticket", message: "Are you sure you want to purchase 1 ticket for $8.50?", preferredStyle: .alert)
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    alert.addAction(cancelAction)
    
    let buyAction = UIAlertAction(title: "Buy", style: .default) {
      (action:UIAlertAction) -> Void in
      let ticketOffice = TicketOffice.sharedInstance
      ticketOffice.purchaseTicketForMovie(self.movie.id)
      
      
      DispatchQueue.main.async { () -> Void in
        let notificationCenter = NotificationCenter.default
        notificationCenter.post(name: Notification.Name(rawValue: NotificationPurchasedMovieOnPhone), object: self.movie.id)
      }
      
      _ = self.navigationController?.popToRootViewController(animated: true)
    }
    alert.addAction(buyAction)
    
    present(alert, animated: true, completion: nil)
  }
    
  @IBAction func ratingWasTapped(_ sender: UIButton) {
    
    let alert = UIAlertController(title: "Rate \(self.movie.title)", message: nil, preferredStyle: .actionSheet)
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    let oneAction = UIAlertAction(title: "★☆☆☆☆", style: .default) { (action:UIAlertAction) -> Void in
      self.rateMovieWithRating(action.title!)
    }
    let twoAction = UIAlertAction(title: "★★☆☆☆", style: .default) { (action:UIAlertAction) -> Void in
      self.rateMovieWithRating(action.title!)
    }
    let threeAction = UIAlertAction(title: "★★★☆☆", style: .default) { (action:UIAlertAction) -> Void in
      self.rateMovieWithRating(action.title!)
    }
    let fourAction = UIAlertAction(title: "★★★★☆", style: .default) { (action:UIAlertAction) -> Void in
      self.rateMovieWithRating(action.title!)
    }
    let fiveAction = UIAlertAction(title: "★★★★★", style: .default) { (action:UIAlertAction) -> Void in
      self.rateMovieWithRating(action.title!)
    }

    alert.addAction(oneAction)
    alert.addAction(twoAction)
    alert.addAction(threeAction)
    alert.addAction(fourAction)
    alert.addAction(fiveAction)
    alert.addAction(cancelAction)
    
    present(alert, animated: true, completion: nil)
  }
  
  private func rateMovieWithRating(_ rating: String) {
    TicketOffice.sharedInstance.rateMovie(movie.id, rating: rating)
    sendRatingToWatch(rating)
    self.rating.setTitle(rating, for: UIControlState())
  }

}

// MARK: - Watch Connectivity

extension MovieDetailViewController {
  
  func sendRatingToWatch(_ rating: String) {
    // 1
    if WCSession.isSupported() {
      // 2
      let session = WCSession.default
      if session.isWatchAppInstalled {
        // 3
        let userInfo = ["movie_id":movie.id, "rating":rating]
        session.transferUserInfo(userInfo)
      }
    }
  }
  
}
