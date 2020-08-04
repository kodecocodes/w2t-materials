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

class WorkoutConfiguration {
  
  let exerciseType: ExerciseType
  var activeTime: TimeInterval
  var restTime: TimeInterval
  
  fileprivate let exerciseTypeKey = "com.razeware.config.exerciseType"
  fileprivate let activeTimeKey = "com.razeware.config.activeTime"
  fileprivate let restTimeKey = "com.razeware.config.restTime"
  
  init(exerciseType: ExerciseType = .other, activeTime: TimeInterval = 120, restTime: TimeInterval = 30) {
    self.exerciseType = exerciseType
    self.activeTime = activeTime
    self.restTime = restTime
  }
  
  init(withDictionary rawDictionary:[String : Any]) {
    if let type = rawDictionary[exerciseTypeKey] as? Int {
      self.exerciseType = ExerciseType(rawValue: type)!
    } else {
      self.exerciseType = ExerciseType.other
    }
    
    if let active = rawDictionary[activeTimeKey] as? TimeInterval {
      self.activeTime = active
    } else {
      self.activeTime = 120
    }
    
    if let rest = rawDictionary[restTimeKey] as? TimeInterval {
      self.restTime = rest
    } else {
      self.restTime = 30
    }
  }
  
  func intervalDuration() -> TimeInterval {
    return activeTime + restTime
  }
  
  func dictionaryRepresentation() -> [String : Any] {
    return [
      exerciseTypeKey : exerciseType.rawValue,
      activeTimeKey : activeTime,
      restTimeKey : restTime,
    ]
  }
}
