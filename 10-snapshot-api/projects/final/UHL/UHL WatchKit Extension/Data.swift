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


func ==(lhs: Team, rhs: Team) -> Bool {
  return lhs.name == rhs.name
}

func ==(lhs: Match, rhs: Match) -> Bool {
  return lhs.date == rhs.date && lhs.home == rhs.home && lhs.away == rhs.away
}

struct Team: Equatable {
  let name: String
  var logoName: String {
    return name.replacingOccurrences(of: " ", with: "-").lowercased()
  }
}

struct Match: Equatable {
  let home: Team
  let away: Team
  let date: Date
  let location: Location
  let result: MatchResult?
  
}

struct MatchResult {
  let homeTeamScore: Int
  let awayTeamScore: Int
}

struct Location {
  let name: String
}

let opponents = [Team(name:"Angels"), Team(name:"Big Red"), Team(name:"Claws"), Team(name: "Jellies"), Team(name:"Jumbos"), Team(name:"Sabers"), Team(name:"Sharks"), Team(name:"Shells"), Team(name:"Stallions"), Team(name:"Stars"), Team(name:"Turtles"), Team(name:"Whales")]

let ourTeam = Team(name:"Octopi")

let locations = [Location(name: "Wembley Natatorium"), Location(name: "Hathaway Country Club"), Location(name: "Rosenbury Farms"), Location(name: "Texas Pool"), Location(name: "Olympic Square")]


// Adding initializer to generate a random match
extension Match {
  
  init(on date: Date = Date()) {
    let opponent = opponents[Int(arc4random_uniform(UInt32(opponents.count)))]
    
    // Randomize the advantage
    let homeTeam = arc4random_uniform(2) == 0 ? opponent : ourTeam
    let awayTeam = homeTeam == ourTeam ? opponent : ourTeam
    
    // Select a random location
    let location = locations[Int(arc4random_uniform(UInt32(locations.count)))]
    
    // If the match occurred in the past, give it a result
    var result: MatchResult? = nil
    if date < Date() {
      let maxScore = 10
      result = MatchResult(homeTeamScore: Int(arc4random_uniform(UInt32(maxScore))), awayTeamScore: Int(arc4random_uniform(UInt32(maxScore))))
    }
    
    home = homeTeam
    away = awayTeam
    self.date = date
    self.location = location
    self.result = result
  }
}

// Adding convenience properties and methods
extension Match {
  var opponent: Team {
    return [home, away].filter { $0 != ourTeam }.first!
  }
  
  var winner: Team? {
    
    guard let result = result else {
      return nil
    }
    
    if result.homeTeamScore > result.awayTeamScore {
      return home
    } else if result.homeTeamScore < result.awayTeamScore {
      return away
    } else {
      return nil
    }
  }
  
  func score(for team: Team) -> Int? {
    return team == home ? result?.homeTeamScore : result?.awayTeamScore
  }
}

extension Match: CustomStringConvertible {
  var description: String {
    return "\(date)   \(home) (\(result!.homeTeamScore)) vs \(away) (\(result!.awayTeamScore))"
  }
}

struct Season {
  
  var matches = [Match]() {
    didSet {
      matches.sort {
        $0.date < $1.date
      }
    }
  }
  
  init() {
    // Will play half the teams twice
    let numMatches = Int(Double(opponents.count) * 1.5)
    
    var opponentsInSchedule = [Team]()
    matches = (0...numMatches).map { matchIndex in
      
      // One match per week, season is halfway complete
      // Ensuring no recent matches - at least two days in the past or future
      let day = Date().addingTimeInterval(TimeInterval((Double(matchIndex - (numMatches / 2)) + 0.5) * 7 * 24 * 60 * 60))
      
      // Select a random time in the evening
      let timeRange = 6...7
      let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
      var dateComponents = calendar.dateComponents([.year, .month, .day], from: day)
      dateComponents.hour = timeRange[timeRange.index(timeRange.startIndex, offsetBy: (Int(arc4random_uniform(UInt32(timeRange.count)))))] + 12
      dateComponents.minute = arc4random_uniform(2) == 0 ? 0 : 30
      dateComponents.second = 0
      
      let date = calendar.date(from: dateComponents)!
      
      var match: Match = Match(on: date)
      
      // Ensure teams only play twice
      repeat {
        match = Match(on: date)
      } while opponentsInSchedule.filter { $0 == match.opponent }.count > 1
      opponentsInSchedule.append(match.opponent)
      
      return match
    }
  }
  
  var upcomingMatches: [Match] {
    return matches.filter { match in
      match.date > Date()
    }
  }
  var playedMatches: [Match] {
    return matches.filter { match in
      match.result != nil
    }
  }
  var record: String {
    
    let record = playedMatches.reduce((won: 0, lost: 0, tied: 0)) {
      var mutableResult = $0
      guard let winner = $1.winner else {
        mutableResult.tied += 1
        return mutableResult
      }
      
      if winner == ourTeam {
        mutableResult.won += 1
      } else {
        mutableResult.lost += 1
      }
      return mutableResult
    }

    return "\(record.won)-\(record.lost)-\(record.tied)"
  }
}

var season = Season()
