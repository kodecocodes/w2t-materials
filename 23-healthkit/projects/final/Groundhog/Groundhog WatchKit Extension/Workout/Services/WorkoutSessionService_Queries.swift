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

extension WorkoutSessionService {
  
  fileprivate func genericSamplePredicate (withStartDate start: Date) -> NSPredicate {
    let datePredicate = HKQuery.predicateForSamples(withStart: start, end: nil, options: .strictStartDate)
    let devicePredicate = HKQuery.predicateForObjects(from: [HKDevice.local()])
    return NSCompoundPredicate(andPredicateWithSubpredicates: [datePredicate, devicePredicate])
  }
  
  internal func heartRateQuery(withStartDate start: Date) -> HKQuery {
    // Query all HR samples from the beginning of the workout session on the current device
    let predicate = genericSamplePredicate(withStartDate: start)
    
    let query:HKAnchoredObjectQuery = HKAnchoredObjectQuery(type: hrType,
      predicate: predicate,
      anchor: hrAnchorValue,
      limit: Int(HKObjectQueryNoLimit)) {
        (query, sampleObjects, deletedObjects, newAnchor, error) in

        self.hrAnchorValue = newAnchor
        self.newHRSamples(sampleObjects)
    }
    
    query.updateHandler = {(query, samples, deleteObjects, newAnchor, error) in
      self.hrAnchorValue = newAnchor
      self.newHRSamples(samples)
    }

    return query
  }
  
  fileprivate func newHRSamples(_ samples: [HKSample]?) {
    // Abort if the data isn't right
    guard let samples = samples as? [HKQuantitySample], samples.count > 0 else {
      return
    }
    
    DispatchQueue.main.async {
      self.hrData += samples
      if let hr = samples.last?.quantity {
        self.heartRate = hr
        self.delegate?.workoutSessionService(self, didUpdateHeartrate: hr.doubleValue(for: hrUnit))
      }
    }
  }
  
  internal func distanceQuery(withStartDate start: Date) -> HKQuery {
    // Query all distance samples from the beginning of the workout session on the current device
    let predicate = genericSamplePredicate(withStartDate: start)
    
    let query = HKAnchoredObjectQuery(type: distanceType,
      predicate: predicate,
      anchor: distanceAnchorValue,
      limit: Int(HKObjectQueryNoLimit)) {
        (query, samples, deleteObjects, anchor, error) in
        
        self.distanceAnchorValue = anchor
        self.newDistanceSamples(samples)
    }
    
    query.updateHandler = {(query, samples, deleteObjects, newAnchor, error) in
      self.distanceAnchorValue = newAnchor
      self.newDistanceSamples(samples)
    }
    return query
  }
  
  internal func newDistanceSamples(_ samples: [HKSample]?) {
    // Abort if the data isn't right
    guard let samples = samples as? [HKQuantitySample], samples.count > 0 else {
      return
    }
    
    DispatchQueue.main.async {
      self.distance = self.distance.addSamples(samples, unit: distanceUnit)
      self.distanceData += samples
      
      self.delegate?.workoutSessionService(self, didUpdateDistance: self.distance.doubleValue(for: distanceUnit))
    }
  }
  
  internal func energyQuery(withStartDate start: Date) -> HKQuery {
    // Query all Energy samples from the beginning of the workout session on the current device
    let predicate = genericSamplePredicate(withStartDate: start)
    
    let query = HKAnchoredObjectQuery(type: energyType,
      predicate: predicate,
      anchor: energyAnchorValue,
      limit: 0) {
        (query, sampleObjects, deletedObjects, newAnchor, error) in
        
        self.energyAnchorValue = newAnchor
        self.newEnergySamples(sampleObjects)
    }
    
    query.updateHandler = {(query, samples, deleteObjects, newAnchor, error) in
      self.energyAnchorValue = newAnchor
      self.newEnergySamples(samples)
    }
    
    return query
  }
  
  internal func newEnergySamples(_ samples: [HKSample]?) {
    // Abort if the data isn't right
    guard let samples = samples as? [HKQuantitySample], samples.count > 0 else {
      return
    }
    
    DispatchQueue.main.async {
      self.energyBurned = self.energyBurned.addSamples(samples, unit: energyUnit)
      self.energyData += samples
      
      self.delegate?.workoutSessionService(self, didUpdateEnergyBurned: self.energyBurned.doubleValue(for: energyUnit))
    }
  }
}
