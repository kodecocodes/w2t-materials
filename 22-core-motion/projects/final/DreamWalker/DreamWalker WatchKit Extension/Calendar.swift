/**
 * Copyright (c) 2016 Razeware LLC
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
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import Foundation

struct Calendar {
  let secondsPerHour: TimeInterval = 3600
  let cal = Foundation.Calendar(identifier: .gregorian)
//  let cal = Foundation.Calendar(calendarIdentifier: Calendar.Identifier.gregorian)!

  var now: Date {
    return Date()
  }
  
  var startOfToday: Date {
    return cal.startOfDay(for: now)
  }
  
  func startOfNextDay(_ date: Date) -> Date {
    // allow for daylight-saving and crossing a few time zones
    let nextDay = date.addingTimeInterval(secondsPerHour * 28)
    return cal.startOfDay(for: nextDay)
  }
  
  func isDate(_ date1: Date, afterDate date2: Date) -> Bool {
    return date1.timeIntervalSince(date2) > 0
  }
  
}
