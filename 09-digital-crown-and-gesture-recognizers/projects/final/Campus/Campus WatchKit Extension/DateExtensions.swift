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

extension Date {
  
  func roundedToMidnight() -> Date {
    let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
    
    var dateComponents = calendar.dateComponents([.year, .month, .day, .hour], from: self)
    
    // Round date to next day if past noon, 12:00 PM
    if dateComponents.hour! >= 12 {
      let newDate = calendar.date(byAdding: DateComponents(calendar: calendar, day: 1), to: self)!
      dateComponents = calendar.dateComponents([.year, .month, .day], from: newDate)
    }
    
    // Create components for midnight, 12:00 AM
    dateComponents.hour = 0
    dateComponents.minute = 0
    dateComponents.second = 0
    
    let newDate = calendar.date(from: dateComponents)!
    return newDate
  }
  
  /**
   This adds a new method adding to Date.
   
   It returns a new date by adding the specified minutes to the receiver
   
   :param: minutes: The minutes to add, can be positive or negative
   
   :returns: a new Date on the same year/month/day as the receiver, but adding the specified minutes value
   */
  
  func adding(minutes: Int) -> Date {
    let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
    
    let newDate = calendar.date(byAdding: DateComponents(calendar: calendar, minute: minutes), to: self)!
    
    return newDate
  }
  
  /**
   This adds a new method dateAt to Date.
   
   It returns a new date at the specified hours and minutes of the receiver
   
   :param: hours: The hours value
   :param: minutes: The new minutes
   
   :returns: a new Date with the same year/month/day as the receiver, but with the specified hours/minutes values
   */
  
  func dateAt(_ hours: Int, minutes: Int) -> Date {
    let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
    
    //get the month/day/year components for this instance's date
    var dateComponents = calendar.dateComponents([.year, .month, .day], from: self)
    
    // Create components for specified time.
    dateComponents.hour = hours
    dateComponents.minute = minutes
    dateComponents.second = 0
    
    let newDate = calendar.date(from: dateComponents)!
    return newDate
  }
}
