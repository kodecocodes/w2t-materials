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

func randomData(_ numDays: Int) -> History {
  
  let goal: Double = 7500
  
  var days = [Day]()
  
  var summaries = [Summary]()
  
  var totalRevenue: Double = 0
  
  var totalGoal: Double = 0
  
  var totalUnits: Int = 0
  
  for i in 0..<numDays {
    
    let date = Date().addingTimeInterval(TimeInterval(-60*60*24*i))
    let modifierAmount = 0.4
    let randomModifier = Double(arc4random_uniform(UInt32(goal * modifierAmount)))
    let status = (goal * ( 1 - modifierAmount)) + randomModifier
    let units = Int(arc4random_uniform(UInt32(status)))
    let day = Day(date: date, status: status, goal: goal, units: units)
    days.append(day)
    totalRevenue += status
    totalGoal += goal
    totalUnits += units
    
    if i == 0 || i == 6 || i == 29 {
      let summary = Summary(dayCount: i + 1, startDate: date, totalRevenue: totalRevenue, totalGoal: totalGoal, totalUnits: totalUnits)
      summaries.append(summary)
    }
    
  }
  
  return History(days: days, summaries: summaries)
  
}

