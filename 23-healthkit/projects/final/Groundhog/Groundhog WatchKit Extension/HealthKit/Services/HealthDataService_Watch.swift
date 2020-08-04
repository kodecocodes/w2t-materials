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

// This extension adds support for saving an HKWorkoutSession
extension HealthDataService {
  
  /// This function saves a workout from a WorkoutSessionService and its HKWorkoutSession
  func saveWorkout(_ workoutService: WorkoutSessionService,
    completion: @escaping (Bool, Error?) -> Void) {
      guard let start = workoutService.startDate, let end = workoutService.endDate else {return}
      
      // Create some metadata to save the interval timer details.
      var metadata = workoutService.configuration.dictionaryRepresentation()
      metadata[HKMetadataKeyIndoorWorkout] = workoutService.configuration.exerciseType.location == .indoor
      
      let workout = HKWorkout(activityType: workoutService.configuration.exerciseType.activityType,
        start: start,
        end: end,
        duration: end.timeIntervalSince(start),
        totalEnergyBurned: workoutService.energyBurned,
        totalDistance: workoutService.distance,
        device: HKDevice.local(),
        metadata: metadata)
      
      // Collect the sampled data
      var samples: [HKQuantitySample] = [HKQuantitySample]()
      samples += workoutService.hrData
      samples += workoutService.distanceData
      samples += workoutService.energyData
      
      // Save the workout
      healthKitStore.save(workout) { (success, error) in
				guard success && samples.count > 0 else {
          completion(success, error)
          return
        }
        
        // If there are samples to save, add them to the workout
				self.healthKitStore.add(samples, to: workout) { (success, error)  in
          completion(success, error)
        }
      }
  }
}
