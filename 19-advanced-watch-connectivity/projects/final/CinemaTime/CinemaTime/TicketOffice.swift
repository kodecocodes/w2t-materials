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

class TicketOffice {
  
  static let sharedInstance = TicketOffice()
  
  lazy var movies: NSArray = {
    if let plistURL = Bundle.main
      .url(forResource: "movies", withExtension: "plist"),
      let array = NSArray(contentsOf: plistURL) {
        return array
    }
    return NSArray()
  }()
  
  lazy var allMovies: [Movie] = {
    var movies = [Movie]()
    for item in self.movies {
      let section = item as! NSDictionary
      let moviesInSection = section["movies"] as! NSArray
      for movieDictionary in moviesInSection {
        let time = section["time"] as! String
        let movie = Movie(dictionary: movieDictionary as! NSDictionary, time: time)
        movies.append(movie)
      }
    }
    return movies
  }()
  
  let kPurchasedTickets = "PurchasedTickets"
  lazy var defaults = UserDefaults.standard
  
  func movieTicketIsAlreadyPurchased(_ id:String) -> Bool {
    guard let purchasedIDs = purchasedMovieTicketIDs() else {
      return false
    }
    return purchasedIDs.filter({return $0 == id}).count > 0
  }
  
  func purchaseTicketForMovie(_ id: String) {
    var purchasedTickets = defaults.object(forKey: kPurchasedTickets) as? [String]
    if purchasedTickets == nil {
      purchasedTickets = [String]()
    }

    if !movieTicketIsAlreadyPurchased(id) {
      purchasedTickets?.append(id)
    }
    defaults.set(purchasedTickets, forKey: kPurchasedTickets)
    defaults.synchronize()
  }
  
  func purchaseTicketsForMovies(_ ids: [String]) {
    for id in ids {
      purchaseTicketForMovie(id)
    }
  }
  
  func purchasedMovieTicketIDs() -> [String]? {
    return defaults.object(forKey: kPurchasedTickets) as? [String]
  }
  
  func purchasedMovies() -> [Movie]? {
    guard let purchasedIDs = purchasedMovieTicketIDs() else {
      return nil
    }
    
    var purchasedMovies = [Movie]()
    for purchasedMovieID in purchasedIDs {
      if let movie = allMovies.filter({return purchasedMovieID == $0.id}).first {
        purchasedMovies.append(movie)
      }
    }
    return purchasedMovies.sorted(by: {$0.time.localizedCaseInsensitiveCompare($1.time) == ComparisonResult.orderedAscending})
  }
  
  // Movie Ratings
  
  func rateMovie(_ movieID: String, rating: String) {
    let key = "rating_\(movieID)"
    defaults.set(rating, forKey: key)
    defaults.synchronize()
  }
  
  func movieRatingForID(_ movieID: String) -> String {
    let key = "rating_\(movieID)"
    return defaults.object(forKey: key) as? String ?? "☆☆☆☆☆"
  }
}
