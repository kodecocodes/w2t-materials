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

protocol PopulationFactObject {
  var country: String {get}
  var populationFactString: String {get}
}

extension PopulationFactObject {
  var readableCountryName: String {
    switch country {
    case "World":                     return "the world"
    case "United States":             return "the United States"
    case "United Kingdom":            return "the United Kingdom"
    case "Rep of Korea":              return "South Korea"
    case "Dem Peoples Rep of Korea":  return "North Korean"
    case "Islamic Republic of Iran":  return "Iran"

    default: return country
    }
  }
}

struct PopulationRank : PopulationFactObject, Decodable {
  let gender: Gender
  let country: String
  let rank: Double

  var populationFactString: String {
    return "You are older than \(commaFormatter.string(from: NSNumber(value: rank))!) of the \(gender.genderNoun) in \(readableCountryName)."
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    gender = try container.decode(Gender.self, forKey: .gender)
    country = try container.decode(String.self, forKey: .country)
    rank = try container.decode(Double.self, forKey: .rank)
  }

  private enum CodingKeys: String, CodingKey {
    case gender = "sex"
    case country
    case rank
  }
}

struct LifeExpectancy : PopulationFactObject, Decodable {
  let gender: Gender
  let country: String
  let lifeExpectancy: Double

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    gender = try container.decode(Gender.self, forKey: .gender)
    country = try container.decode(String.self, forKey: .country)
    lifeExpectancy = try container.decode(Double.self, forKey: .lifeExpectancy)
  }

  private enum CodingKeys: String, CodingKey {
    case gender = "sex"
    case country
    case lifeExpectancy = "total_life_expectancy"
  }

  var populationFactString: String {
    return "The life expectancy of \(gender.genderNoun) in \(readableCountryName) is \(numberFormatter.string(from: NSNumber(value: lifeExpectancy))!) years."
  }
}

struct PopulationData: Decodable {
  let year: Int
  let ageCohort: Int

  let totalPopulation: Int
  let malesPopulation: Int
  let femalesPopulation: Int

  private enum CodingKeys: String, CodingKey {
    case year = "year"
    case ageCohort = "age"
    case totalPopulation = "total"
    case malesPopulation = "males"
    case femalesPopulation = "females"
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    year = try container.decode(Int.self, forKey: .year)
    ageCohort = try container.decode(Int.self, forKey: .ageCohort)
    totalPopulation = try container.decode(Int.self, forKey: .totalPopulation)
    malesPopulation = try container.decode(Int.self, forKey: .malesPopulation)
    femalesPopulation = try container.decode(Int.self, forKey: .femalesPopulation)
  }
}

