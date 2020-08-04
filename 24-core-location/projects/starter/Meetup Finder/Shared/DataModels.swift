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
import UIKit

struct Coordinate {
  let longitude: Double
  let latitude: Double
}

struct Location {
  let country: String
  let state: String
  let city: String
}

struct Organizer {
  let name: String
}

struct Category {
  let name: String
}

struct Group {
  let name: String
  /// Formatted number of members.
  let numberOfMembers: String
  let description: String
  let color: UIColor
}

struct Event {
  let name: String
}

class Meetup {
  let organizer: Organizer
  let group: Group
  let coordinate: Coordinate
  let location: Location
  let nextEvent: Event
  let category: Category
  let link: URL
  
  init(organizer: Organizer, group: Group, coordinate: Coordinate, location: Location, nextEvent: Event, category: Category, link: URL) {
    self.organizer = organizer
    self.group = group
    self.coordinate = coordinate
    self.location = location
    self.nextEvent = nextEvent
    self.category = category
    self.link = link
  }
}
