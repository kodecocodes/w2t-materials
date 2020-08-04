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

let measurementIntervalMinutes = 30
let daysOfRecord = 5
var measurementsPerDay: Int {
  return 60 * 24 / measurementIntervalMinutes
}

struct Census {
  let attendance: Int
  let timestamp: Date
}

var censuses: [Census] = {
  // Campus configuration
  let campusPopulation = 5000
  let maxExpectedAttendance = 0.8 // 0...1 percentage
  
  // Sine wave serves as bell curve distribution
  let sineArraySize = measurementsPerDay
  let frequency = 1.0
  let phase = .pi / -2.0
  let amplitude = Double(campusPopulation) / 2 * maxExpectedAttendance
  let maxVariation = 1 - maxExpectedAttendance
  
  return (0..<daysOfRecord).map { dayIndex in
    (0..<sineArraySize).map {
      let interior = 2 * .pi / Double(sineArraySize) * Double($0) * frequency + phase
      let y = amplitude * sin(interior) + amplitude
      let randomVariation = drand48() * (maxVariation * 2) - maxVariation
      let adjustedY = y * (1 + randomVariation)
      let attendance = Int(round(adjustedY))
      let timestamp = Date().roundedToMidnight().addingTimeInterval(-TimeInterval(($0 + 1) * measurementIntervalMinutes * 60 + dayIndex * 60 * 60 * 24))
      return Census(attendance: attendance, timestamp: timestamp)
    }
    }.flatMap { $0 }.reversed()
}()
