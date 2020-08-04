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

class TicketsTableViewController: UITableViewController {
  
  var dataSource = [Movie]()
  lazy var notificationCenter: NotificationCenter = {
    return NotificationCenter.default
    }()
  var notificationObserver: NSObjectProtocol?
  
  override func viewDidLoad() {
    super.viewDidLoad()

	tableView.estimatedRowHeight = UITableViewAutomaticDimension
	tableView.rowHeight = UITableViewAutomaticDimension
    notificationObserver = notificationCenter.addObserver(forName: NSNotification.Name(rawValue: NotificaitonPurchasedMovieOnWatch), object: nil, queue: nil) { (notification:Notification) -> Void in
      self.updateDisplay()
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.updateDisplay()
  }
  
  private func updateDisplay() {
    DispatchQueue.main.async { () -> Void in
      if let movies = TicketOffice.sharedInstance.purchasedMovies() {
        self.dataSource = movies
        self.tableView.reloadData()
      }
    }
  }
  
  deinit {
    if let observer = notificationObserver {
      notificationCenter.removeObserver(observer)
    }
  }
  
  // MARK: - UITableViewDataSource
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return dataSource.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "CellPurchasedMovie", for: indexPath) as! MovieTableViewCell
    let movie = dataSource[(indexPath as NSIndexPath).row]
    cell.movie = movie
    return cell
  }
  
  // MARK: - Segue
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "SeguePurchasedToMovieDetail",
      let indexPath = tableView.indexPathForSelectedRow,
      let cell = tableView.cellForRow(at: indexPath) as? MovieTableViewCell,
      let movie = cell.movie,
      let destination = segue.destination as? MovieDetailViewController {
        destination.movie = movie
    }
  }
  
}
