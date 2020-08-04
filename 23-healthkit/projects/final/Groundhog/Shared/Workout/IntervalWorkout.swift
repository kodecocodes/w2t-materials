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
import HealthKit

class IntervalWorkout {
  
  // MARK: - Properties
  let workout: HKWorkout
  let configuration: WorkoutConfiguration
  let intervals: [IntervalWorkoutInterval]
  
  init(withWorkout workout:HKWorkout, configuration:WorkoutConfiguration) {
    self.workout = workout
    self.configuration = configuration
    self.intervals = {
      var ints: [IntervalWorkoutInterval] = [IntervalWorkoutInterval]()
      
      let activeLength = configuration.activeTime
      let restLength = configuration.restTime
      
      var intervalStart = workout.startDate
      
      while intervalStart.compare(workout.endDate) == .orderedAscending {
        let restStart = Date(timeInterval: activeLength, since: intervalStart)
        let interval = IntervalWorkoutInterval(activeStartTime: intervalStart,
          restStartTime: restStart,
          duration: activeLength,
          endTime: Date(timeInterval: restLength, since: restStart)
        )
        ints.append(interval)
        intervalStart = Date(timeInterval: activeLength + restLength, since: intervalStart)
      }
      return ints
    } ()
  }
  
  // MARK: - Read-Only Properties
  
  var distanceType: HKQuantityType {
    if workout.workoutActivityType == .cycling {
      return cyclingDistanceType
    } else {
      return runningDistanceType
    }
  }
  
  var startDate: Date {
    return workout.startDate
  }
  
  var endDate: Date {
    return workout.endDate
  }
  
  var duration: TimeInterval {
    return workout.duration
  }
  
  var calories: Double {
    guard let energy = workout.totalEnergyBurned else {return 0.0}
    
    return energy.doubleValue(for: energyUnit)
  }
  
  var distance: Double {
    guard let dist = workout.totalDistance else {return 0.0}
    
    return dist.doubleValue(for: distanceUnit)
  }
}

class IntervalWorkoutInterval {
  let activeStartTime: Date
  let duration: TimeInterval
  let restStartTime: Date
  let endTime: Date
  
  init (activeStartTime: Date, restStartTime: Date, duration: TimeInterval, endTime: Date) {
    self.activeStartTime = activeStartTime
    self.restStartTime = restStartTime
    self.duration = duration
    self.endTime = endTime
  }
  
  var distanceStats: HKStatistics?
  var hrStats: HKStatistics?
  var caloriesStats: HKStatistics?
  
  var distance: Double? {
    guard let distanceStats = distanceStats else { return nil }
    return distanceStats.sumQuantity()?.doubleValue(for: distanceUnit)
  }
  
  var averageHeartRate: Double? {
    guard let hrStats = hrStats else { return nil }
    return hrStats.averageQuantity()?.doubleValue(for: hrUnit)
  }
  
  var calories: Double? {
    guard let caloriesStats = caloriesStats else { return nil }
    return caloriesStats.sumQuantity()?.doubleValue(for: energyUnit)
  }
  
}

