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

struct PopulationConfiguration {
  var gender: Gender = .Male
  var dobYear: Int = (yearOptions.last! - 25)
  var dobMonth: Int = 1
  var country: String = countryOptions.first!

  var dobString:String {
    return String(format: "%d-%02ld-01", dobYear, dobMonth)
  }
}

let monthOptions: [String] = {
  return dateFormatter.shortStandaloneMonthSymbols
} ()

let yearOptions: [Int] = {
  let thisYear = Calendar.current.component(.year, from: Date())
  return (1950...(thisYear-1)).map { $0 }
} ()

let countryOptions: [String] = {
  return [
    "World",
    "United States",
    "Afghanistan",
    "Algeria",
    "Arab Rep of Egypt",
    "Argentina",
    "Bangladesh",
    "Brazil",
    "Canada",
    "China",
    "Colombia",
    "Dem Peoples Rep of Korea",
    "Dem Rep of Congo",
    "Ethiopia",
    "France",
    "Germany",
    "Ghana",
    "India",
    "Indonesia",
    "Iraq",
    "Islamic Republic of Iran",
    "Italy",
    "Japan",
    "Kenya",
    "Malaysia",
    "Mexico",
    "Morocco",
    "Mozambique",
    "Myanmar",
    "Nepal",
    "Nigeria",
    "Pakistan",
    "Peru",
    "Philippines",
    "Poland",
    "RB-de-Venezuela",
    "Rep of Korea",
    "Rep of Yemen",
    "Russian Federation",
    "Saudi Arabia",
    "South Africa",
    "Spain",
    "Sudan",
    "Tanzania",
    "Thailand",
    "Turkey",
    "Uganda",
    "Ukraine",
    "United Kingdom",
    "Uzbekistan",
    "Vietnam"
  ]
} ()

enum Gender: String, Decodable {
  case Female = "Female"
  case Male = "Male"
  case All = "All"

  static let allValues = [Female, Male, All]

  var genderNoun: String {
    switch self {
    case .Female: return "women"
    case .Male:   return "men"
    case .All:    return "people"
    }
  }

  var serviceKey: String {
    switch self {
    case .Female: return "female"
    case .Male:   return "male"
    case .All:    return "unisex"
    }
  }

  init?(serviceKey: String) {
    switch serviceKey {
    case "female":
      self = .Female
    case "male":
      self = .Male
    case "unisex":
      self = .All
    default:
      return nil
    }
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let gender = try container.decode(String.self)
    self = Gender(serviceKey: gender)!
  }
}

