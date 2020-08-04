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

enum ExerciseType: Int {
  case cycling = 1
  case stationaryBike
  case elliptical
  case functionalStrengthTraining
  case rowing
  case rowingMachine
  case running
  case treadmill
  case stairClimbing
  case swimming
  case stretching
  case walking
  case wheelchairRun
  case wheelchairWalk
  case other
  
  static let allValues = [cycling, stationaryBike, elliptical, functionalStrengthTraining, rowing, rowingMachine, running, treadmill, stairClimbing, swimming, stretching, walking, wheelchairRun, wheelchairWalk, other]
  
  var title: String {
    switch self {
    case .cycling:                    return "Cycling"
    case .stationaryBike:             return "Stationary Bike"
    case .elliptical:                 return "Elliptical"
    case .functionalStrengthTraining: return "Weights"
    case .rowing:                     return "Rowing"
    case .rowingMachine:              return "Ergometer"
    case .running:                    return "Running"
    case .treadmill:                  return "Treadmill"
    case .stairClimbing:              return "Stairs"
    case .swimming:                   return "Swimming"
    case .stretching:                 return "Stretching"
    case .walking:                    return "Walking"
    case .wheelchairWalk:             return "Wheelchair"
    case .wheelchairRun:              return "Wheelchair Sprint"
    case .other:                      return "Other"
    }
  }

  var activityType: HKWorkoutActivityType {
    switch self {
    case .cycling:                    return .cycling
    case .stationaryBike:             return .cycling
    case .elliptical:                 return .elliptical
    case .functionalStrengthTraining: return .functionalStrengthTraining
    case .rowing:                     return .rowing
    case .rowingMachine:              return .rowing
    case .running:                    return .running
    case .treadmill:                  return .running
    case .stairClimbing:              return .stairClimbing
    case .swimming:                   return .swimming
    case .stretching:                 return .flexibility
    case .walking:                    return .walking
    case .wheelchairWalk:             return .wheelchairWalkPace
    case .wheelchairRun:              return .wheelchairRunPace
    case .other:                      return .other
    }
  }
  
  var quote: String {
    switch self {
    case .stationaryBike:
      return "\"She who succeeds in gaining the mastery of the bicycle will gain the mastery of life.\" – Susan B. Anthony"
    case .cycling:
      return "\"When you ride hard on a mountain bike, sometimes you fall, otherwise you’re not riding hard.\" – George W. Bush"
    case .elliptical:
      return "\"I was never a natural athlete, but I paid my dues in sweat and concentration, and took the time necessary to learn karate and became a world champion.\" – Chuck Norris"
    case .functionalStrengthTraining:
      return "\"I just use my muscles as a conversation piece, like someone walking a cheetah down 42nd Street.\" – Arnold Schwarzenegger"
    case .rowing:
      return "\"It’s a great art, is rowing. It’s the finest art there is. It’s a symphony of motion and when you’re rowing well, why it’s nearing perfection. You’re touching the divine. It touches the you of you’s, which is your soul.\" – George Pocock"
    case .rowingMachine:
      return "\"The less effort, the faster and more powerful you will be.\" – Bruce Lee"
    case .running:
      return "\"It's factual to say I am a bilateral-below-the-knee amputee. I think it's subjective opinion as to whether or not I am disabled because of that. That's just me.\" – Aimee Mullins"
    case .treadmill:
      return "\"I run to see who has the most guts.\" – Steve Prefontaine"
    case .stairClimbing:
      return "\"This is one small step for a man, one giant leap for mankind.\" – Neil Armstrong"
    case .swimming:
      return "\"The water doesn't know how old you are.\" – Dara Torres"
    case .stretching:
      return "\"Other people may not have had high expectations for me... but I had high expectations for myself.\" – Shannon Miller"
    case .walking:
      return "\"People sacrifice the present for the future. But life is available only in the present. That is why we should walk in such a way that every step can bring us to the here and the now.\" – Thich Nhat Hanh"
    case .wheelchairRun:
      return "\"If everything seems under control, you're not going fast enough.\" – Mario Andretti"
    case .wheelchairWalk:
      return "\"When I race my mind is full of doubts - who will finish second, who will finish third?\" – Noureddine Morceli"
    case .other:
      return "\"I am building a fire, and everyday I train, I add more fuel. At just the right moment, I light the match.\" – Mia Hamm"
    }
  }
  
  var location: HKWorkoutSessionLocationType {
    switch self {
    case .cycling:                    return .outdoor
    case .stationaryBike:             return .indoor
    case .elliptical:                 return .indoor
    case .functionalStrengthTraining: return .indoor
    case .rowing:                     return .outdoor
    case .rowingMachine:              return .indoor
    case .running:                    return .outdoor
    case .treadmill:                  return .indoor
    case .stairClimbing:              return .indoor
    case .swimming:                   return .indoor
    case .stretching:                 return .unknown
    case .walking:                    return .outdoor
    case .wheelchairWalk:             return .outdoor
    case .wheelchairRun:              return .outdoor
    case .other:                      return .unknown
    }
  }
  
  var locationName: String {
    switch self.location {
    case .indoor:  return "Indoor Exercise"
    case .outdoor: return "Outdoor Exercise"
    case .unknown: return "General Exercise"
    }
  }

  var hkWorkoutConfiguration: HKWorkoutConfiguration {
    let configuration = HKWorkoutConfiguration()
    configuration.activityType = self.activityType
    configuration.locationType = self.location
    return configuration
  }
}
