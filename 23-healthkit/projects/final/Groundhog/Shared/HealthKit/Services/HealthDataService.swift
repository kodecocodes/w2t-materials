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

// ****** Units and Types
let energyUnit = HKUnit.kilocalorie()
let energyFormatterUnit: EnergyFormatter.Unit = {
  return HKUnit.energyFormatterUnit(from: energyUnit)
} ()

let distanceUnit: HKUnit = {
  let locale = Locale.current
  let isMetric: Bool = locale.usesMetricSystem
  
  if isMetric {
    return HKUnit.meter()
  } else {
    return HKUnit.mile()
  }
} ()
let distanceFormatterUnit: LengthFormatter.Unit = {
  return HKUnit.lengthFormatterUnit(from: distanceUnit)
} ()


let hrUnit = HKUnit(from: "count/min")

let energyType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)!
let hrType:HKQuantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
let cyclingDistanceType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceCycling)!
let runningDistanceType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)!

class HealthDataService {
  
  internal let healthKitStore:HKHealthStore = HKHealthStore()
  
  init() {}
  
  /// This function asks HealthKit for authorization to read and write to the health store
  func authorizeHealthKitAccess(_ completion: ((_ success:Bool, _ error:Error?) -> Void)!) {
    let typesToShare = Set(
      [HKObjectType.workoutType(),
      energyType,
      cyclingDistanceType,
      runningDistanceType,
      hrType
      ])
    let typesToSave = Set([
      energyType,
      cyclingDistanceType,
      runningDistanceType,
      hrType
      ])
    
    healthKitStore.requestAuthorization(toShare: typesToShare, read: typesToSave) { (success, error) in
      completion(success, error)
    }
  }
  
  /// This function gets HKWorkouts from the Health Store that were created by this app
  func readWorkouts(_ completion: @escaping (_ success: Bool, _ workouts:[HKWorkout], _ error: Error?) -> Void) {
    
    // Predicate indicating "this app"
    let sourcePredicate = HKQuery.predicateForObjects(from: HKSource.default())

    // Get workouts that took some amount of time
    let workoutsPredicate = HKQuery.predicateForWorkouts(with: .greaterThan, duration: 0)

    // AND the two predicates together
    let predicate = NSCompoundPredicate(type: .and, subpredicates: [sourcePredicate, workoutsPredicate])
    let sortDescriptor = NSSortDescriptor(key:HKSampleSortIdentifierStartDate, ascending: false)
    
    let sampleQuery = HKSampleQuery(sampleType: HKWorkoutType.workoutType(), predicate: predicate, limit: 0, sortDescriptors: [sortDescriptor])
      { (sampleQuery, results, error ) -> Void in
        
        guard let samples = results as? [HKWorkout] else {
          completion(false, [HKWorkout](), error)
          return
        }
        
        completion(error == nil, samples, error)
    }
    healthKitStore.execute(sampleQuery)
  }
  
  /// This function gets samples of a certain type from the workout passed in
  func samplesForWorkout(_ workout: HKWorkout,
    intervalStart: Date,
    intervalEnd: Date,
    type: HKQuantityType,
    completion: @escaping (_ samples: [HKSample], _ error: Error?) -> Void) {
      
      // Start with the workout
      let workoutPredicate = HKQuery.predicateForObjects(from: workout)

      // Just get samples within the timeframe of a certain interval
      let datePredicate = HKQuery.predicateForSamples(withStart: intervalStart, end: intervalEnd, options: HKQueryOptions())

      // AND the two predicates
      let predicate = NSCompoundPredicate(type: .and, subpredicates: [workoutPredicate, datePredicate])
      let startDateSort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
      
      let query = HKSampleQuery(sampleType: type, predicate: predicate, limit: 0, sortDescriptors: [startDateSort]) { (query, samples, error) -> Void in
        completion(samples!, error)
      }
      healthKitStore.execute(query)
  }
  
  /// This function gets statistics of a certain type from the workout passed in
  func statisticsForWorkout(_ workout: HKWorkout,
    intervalStart: Date,
    intervalEnd: Date,
    type: HKQuantityType,
    options: HKStatisticsOptions,
    completion: @escaping (_ statistics: HKStatistics, _ error: Error?) -> Void) {
      
      // Start with the workout
      let workoutPredicate = HKQuery.predicateForObjects(from: workout)
      
      // Just get stats within the timeframe of a certain interval
      let datePredicate = HKQuery.predicateForSamples(withStart: intervalStart, end: intervalEnd, options: HKQueryOptions())

      // AND the two predicates
      let predicate = NSCompoundPredicate(type: .and, subpredicates: [workoutPredicate, datePredicate])
      
      let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: options) { (query, stats, error) -> Void in
        completion(stats!, error)
      }
      healthKitStore.execute(query)
  }
}
