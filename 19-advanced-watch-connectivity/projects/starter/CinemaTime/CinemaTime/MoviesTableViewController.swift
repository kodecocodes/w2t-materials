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

class MoviesTableViewController: UITableViewController {
  
  lazy var dataSource: NSArray = TicketOffice.sharedInstance.movies

  override func viewDidLoad() {
    super.viewDidLoad()

    tableView.estimatedRowHeight = UITableViewAutomaticDimension
    tableView.rowHeight = UITableViewAutomaticDimension
  }

  // MARK: - UITableViewDataSource
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return dataSource.count
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let section = dataSource[section] as? NSDictionary,
      let moviesInSection = section["movies"] as? NSArray {
        return moviesInSection.count
    }
    return 0
  }
  
  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if let sectionDictionary = dataSource[section] as? NSDictionary,
      let time = sectionDictionary["time"] as? String {
        return time
    }
    return ""
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MovieTableViewCell
    if let movie = movieForIndexPath(indexPath) {
      cell.movie = movie
    }
    return cell
  }
  
  private func movieForIndexPath(_ indexPath: IndexPath) -> Movie? {
    if let section = dataSource[(indexPath as NSIndexPath).section] as? NSDictionary,
      let moviesInSection = section["movies"] as? NSArray,
      let movie = moviesInSection[(indexPath as NSIndexPath).row] as? NSDictionary,
      let sectionDictionary = dataSource[(indexPath as NSIndexPath).section] as? NSDictionary,
      let time = sectionDictionary["time"] as? String  {
        return Movie(dictionary: movie, time: time)
    }
    return nil
  }
  
  // MARK: - Segue
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "SegueMovieDetail",
      let indexPath = tableView.indexPathForSelectedRow,
      let cell = tableView.cellForRow(at: indexPath) as? MovieTableViewCell,
      let movie = cell.movie,
      let destination = segue.destination as? MovieDetailViewController {
          destination.movie = movie
    }
  }
  
}

