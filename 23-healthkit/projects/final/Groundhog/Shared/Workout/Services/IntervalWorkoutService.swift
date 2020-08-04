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

class IntervalWorkoutService {
  
  fileprivate let healthService = HealthDataService()
  
  /// This method gets a list of workouts from HealthKit and reformats them as IntervalWorkouts
  /// It uses the metadata written by the watch to determine how long the intervals were when it was created
  func readIntervalWorkouts(_ completion: @escaping (_ success: Bool, _ workouts:[IntervalWorkout], _ error: Error?) -> Void) {
    
    healthService.readWorkouts { (success, workouts, error) -> Void in
      
      var intervalWorkouts:[IntervalWorkout] = [IntervalWorkout]()
      
      // Loop through results
      for workout in workouts {
        // There's no Metadata, so it must not be an IntervalWorkout that we created - Just make it with one interval
        guard let metadata = workout.metadata, metadata.count > 0 else {
          let basicConfiguration = WorkoutConfiguration(exerciseType: ExerciseType.other, activeTime: workout.duration, restTime: 0)
          let basicIntervalWorkout = IntervalWorkout(withWorkout: workout, configuration: basicConfiguration)
          intervalWorkouts.append(basicIntervalWorkout)
          continue
        }
        
        // Determine The Configuration
        let configuration = WorkoutConfiguration(withDictionary: metadata)
        
        // Create a workout
        let intervalWorkout = IntervalWorkout(withWorkout: workout, configuration: configuration)
        intervalWorkouts.append(intervalWorkout)
      }
      
      // Return the results to the caller
      completion(success, intervalWorkouts, error)
    }
    
  }
  
  func readWorkoutDetail(_ workout:IntervalWorkout, completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
    
    // Start a dispatch group to get all the data
    let loadAllDataDispatchGroup = DispatchGroup()
    
    for interval in workout.intervals {

      // Get Distance Data
      loadAllDataDispatchGroup.enter()
      statisticsForInterval(interval, workout: workout, type: workout.distanceType, options: .cumulativeSum, completion: { (stats, error) -> Void in
        interval.distanceStats = stats
        loadAllDataDispatchGroup.leave()
      })
      
      // Get HR Data
      loadAllDataDispatchGroup.enter()
      statisticsForInterval(interval, workout: workout, type: hrType, options: .discreteAverage, completion: { (stats, error) -> Void in
        interval.hrStats = stats
        loadAllDataDispatchGroup.leave()
      })
      
      // Energy Data
      loadAllDataDispatchGroup.enter()
      statisticsForInterval(interval, workout: workout, type: energyType, options: .cumulativeSum, completion: { (stats, error) -> Void in
        interval.caloriesStats = stats
        loadAllDataDispatchGroup.leave()
      })
    }
    
    // Now that all the work is done, call the completion handler
    loadAllDataDispatchGroup.notify(queue: DispatchQueue.global(qos: .default)) { () -> Void in
      completion(true, nil)
    }
  }
  
  fileprivate func statisticsForInterval(_ interval: IntervalWorkoutInterval, workout: IntervalWorkout, type: HKQuantityType, options:HKStatisticsOptions,
    completion: @escaping (_ stats: HKStatistics?, _ error: Error?) -> Void) {
      
      healthService.statisticsForWorkout(workout.workout,
        intervalStart: interval.activeStartTime,
        intervalEnd: interval.restStartTime,
        type: type,
        options: options) { (statistics, error) -> Void in
        
          completion(statistics, error)
      }
  }
}
