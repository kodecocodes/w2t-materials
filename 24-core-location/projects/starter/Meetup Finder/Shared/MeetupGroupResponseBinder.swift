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

/**

  This is a sample response.
  The response contains a dictionary of meetups.
  The key is the rank, starts from 0 to the number of pages submitted in the request.

  "0": {
    "score": 4545,
    "id": 18614627,
    "name": "Manchester iOS Meetup",
    "link": "http://www.meetup.com/Manchester-iOS-Meetup/",
    "urlname": "Manchester-iOS-Meetup",
    "description": "Some description",
    "created": 1432212532000,
    "city": "Manchester",
    "country": "US",
    "state": "NH",
    "join_mode": "open",
    "visibility": "public",
    "lat": 42.9900016784668,
    "lon": -71.47000122070312,
    "members": 34,
    "organizer": {
      "id": 139382662,
      "name": "Sam Winter",
      "bio": ""
    },
    "who": "iOS Devs",
    "timezone": "US/Eastern",
    "next_event": {
      "id": "224206057",
      "name": "Continue course on iTunesU / Discussion"
    },
    "category": {
      "id": 34,
      "name": "Tech",
      "shortname": "Tech"
    }
  }

**/

class MeetupGroupResponseBinder {
  
  private let numberFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.minimumFractionDigits = 0
    formatter.maximumFractionDigits = 0
    return formatter
    }()
  
  func bindResponse(_ response: Data) -> [Meetup] {
    let json = JSON(data: response)
    var meetups = [Meetup]()
    
    var regex: NSRegularExpression?
    do {
      let pattern = "<[^>]+>"
      regex = try NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options.caseInsensitive)
    } catch let error {
      print("Failed to create a regular expression to strip out XML tags from response: \(error)")
    }
    
    for (_, jsonGroup) in json {
      guard let groupDictionary = jsonGroup.dictionary else { continue }
      // Coordinate
      guard let lat = groupDictionary["lat"]?.double else { continue }
      guard let lon = groupDictionary["lon"]?.double else { continue }
      // Location
      guard let city = groupDictionary["city"]?.string else { continue }
      guard let state = groupDictionary["state"]?.string else { continue }
      guard let country = groupDictionary["country"]?.string else { continue }
      // Group
      guard let groupName = groupDictionary["name"]?.string else { continue }
      guard let rawDescription = groupDictionary["description"]?.string else { continue }
      let range = NSMakeRange(0, rawDescription.characters.count)
      guard let description = regex?.stringByReplacingMatches(in: rawDescription, options: NSRegularExpression.MatchingOptions.reportCompletion, range: range, withTemplate: "") else { continue }
      guard let members = groupDictionary["members"]?.int else { continue }
      // Organizer
      guard let organizerName = groupDictionary["organizer"]?.dictionary?["name"]?.string else { continue }
      // Category
      guard let categoryName = groupDictionary["category"]?.dictionary?["name"]?.string else { continue }
      // Next Event
      guard let nextEventName = groupDictionary["next_event"]?.dictionary?["name"]?.string else { continue }
      guard let linkString = groupDictionary["link"]?.string else { continue }
      
      let coordinate = Coordinate(longitude: lon, latitude: lat)
      let location = Location(country: country, state: state, city: city)
      
      let color: UIColor
      switch members {
      case 0..<20:
        color = UIColor.gray.withAlphaComponent(0.8)
      case 20..<100:
        color = UIColor.orange.withAlphaComponent(0.8)
      case 100..<1000:
        color = UIColor.themeTintColor().withAlphaComponent(0.8)
      default:
        color = UIColor.red.withAlphaComponent(0.8)
      }
      
      let formattedNumberOfMembers = numberFormatter.string(from: NSNumber(value: members)) ?? ""
      let group = Group(name: groupName, numberOfMembers: formattedNumberOfMembers, description: description, color: color)
      let organizer = Organizer(name: organizerName)
      let category = Category(name: categoryName)
      let nextEvent = Event(name: nextEventName)
      let link = URL(string: linkString)!
      
      let meetup = Meetup(organizer: organizer, group: group, coordinate: coordinate, location: location, nextEvent: nextEvent, category: category, link: link)
      meetups.append(meetup)
    }
    return meetups
  }
  
}
