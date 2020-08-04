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

import WatchKit
import Foundation

class ActiveWorkoutInterfaceController: WKInterfaceController {
  
  // MARK: - ****** State Management ******
  var startTime: Date?
  var timer: Timer?
  
  func elapsedTime() -> TimeInterval {
    guard let startTime = startTime else {
      return TimeInterval(0)
    }
    return Date().timeIntervalSince(startTime)
  }
  
  // ****** Models ******
  var workoutConfiguration: WorkoutConfiguration?

  var workoutSession: WorkoutSessionService?

  // ****** UI Elements ******
  @IBOutlet var elapsedTimer: WKInterfaceTimer!
  @IBOutlet var intervalTimeRemainingTimer: WKInterfaceTimer!
  
  @IBOutlet var intervalPhaseBadge: WKInterfaceLabel!
  @IBOutlet var intervalPhaseContainer: WKInterfaceGroup!
  @IBOutlet var countdownGroup: WKInterfaceGroup!
  @IBOutlet var countdownTimerLabel: WKInterfaceTimer!
  @IBOutlet var detailGroup: WKInterfaceGroup!
  @IBOutlet var dataGroup: WKInterfaceGroup!
  @IBOutlet var dataLabel: WKInterfaceLabel!
  
  
  // MARK: - ****** Lifecycle ******
  
  override func awake(withContext context: Any?) {
    super.awake(withContext: context)
    
    workoutConfiguration = context as? WorkoutConfiguration
    self.setTitle(workoutConfiguration?.exerciseType.title)

    // Start Countdown Timer
    let coundownDuration: TimeInterval = 3
    countdownGroup.setHidden(false)
    detailGroup.setHidden(true)
    countdownGroup.setBackgroundImageNamed("progress_ring")
    countdownGroup.startAnimatingWithImages(in: NSRange(location: 0, length: 91), duration: -coundownDuration, repeatCount: 1)
    countdownTimerLabel.setDate(Date(timeIntervalSinceNow: coundownDuration+1))
    countdownTimerLabel.start()
    Timer.scheduledTimer(timeInterval: coundownDuration+0.2, target: self, selector: #selector(ActiveWorkoutInterfaceController.start(_:)), userInfo: nil, repeats: false)
  }
  

  // MARK: - ****** Save Data ******
  
  func presentSaveDataAlertController() {
    // Save Action
    let saveAction = WKAlertAction(title: "Save", style: .default, handler: {
      self.detailGroup.setHidden(true)
      
      // Save Data Here
      self.workoutSession?.saveSession()
    })
    
    // Cancel Action
    let cancelAction = WKAlertAction(title: "Cancel", style: .destructive, handler: {
      self.dismiss()
    })
    
    presentAlert(withTitle: "Good Job!", message: "Would you like to save your workout?", preferredStyle: WKAlertControllerStyle.actionSheet, actions: [saveAction, cancelAction])

  }
  
  
  // MARK: - ****** Timer Management ******

  let tickDuration = 0.5
  var currentPhaseState: (phase: ExerciseIntervalPhase,
    endTime: TimeInterval,
    duration:TimeInterval,
    running: Bool) = (.Active, 0.0, 0.0, false)
  
  // Start the timer and the workout session after a short countdown
  @IBAction func start(_ sender: AnyObject?) {
    guard let workoutConfiguration = workoutConfiguration else {
      return
    }
    
    timer = Timer(timeInterval: tickDuration, target: self, selector: #selector(ActiveWorkoutInterfaceController.timerTick(_:)), userInfo: nil, repeats: true)
    RunLoop.current.add(timer!, forMode: RunLoopMode.commonModes)
    
    // Start the timer
    startTime = Date()
    
    currentPhaseState = (.Active, workoutConfiguration.activeTime, workoutConfiguration.activeTime, true)

    // Update Labels
    elapsedTimer.setDate(Date(timeIntervalSinceNow: TimeInterval(-1)))
    elapsedTimer.start()
    
    updateIntervalPhaseLabels()
    
    countdownGroup.setHidden(true)
    detailGroup.setHidden(false)

    workoutSession = WorkoutSessionService(configuration: workoutConfiguration)
    if workoutSession != nil {
      workoutSession!.delegate = self
      workoutSession!.startSession()
    }
  }
  
  @IBAction func stop(_ sender: AnyObject?) {
    timer?.invalidate()
    
    currentPhaseState = (.Active, 0.0, 0.0, false)
    updateIntervalPhaseLabels()
    
    elapsedTimer.stop()
    intervalTimeRemainingTimer.stop()
    workoutSession!.stopSession()
  }
  
  @objc func timerTick(_ timer: Timer) {
    if (elapsedTime() >= currentPhaseState.endTime) {
      transitionToNextPhase()
    }
  }
  
  func transitionToNextPhase() {
    let previousPhase = currentPhaseState
    switch previousPhase.phase {
    case .Active:
      currentPhaseState = (.Rest, previousPhase.endTime + workoutConfiguration!.restTime, workoutConfiguration!.restTime, previousPhase.running)
      WKInterfaceDevice.current().play(workoutConfiguration!.restTime > 0 ? .stop : .start)
      
    case .Rest:
      currentPhaseState = (.Active, previousPhase.endTime + workoutConfiguration!.activeTime, workoutConfiguration!.activeTime, previousPhase.running)
      WKInterfaceDevice.current().play(.start)
      
    }
    updateIntervalPhaseLabels()
  }
  
  let activeColor = UIColor(red: 1.0, green: 149/255, blue: 0, alpha: 1.0)
  let restColor = UIColor(red: 254/255, green: 204/255, blue: 136/255, alpha: 1.0)

  func updateIntervalPhaseLabels() {
    intervalPhaseBadge.setText(currentPhaseState.phase.rawValue)
    switch currentPhaseState.phase {
    case .Active:
      intervalPhaseContainer.setBackgroundColor(activeColor)
    case .Rest:
      intervalPhaseContainer.setBackgroundColor(restColor)
    }
    
    intervalTimeRemainingTimer.stop()
    let durationInterval = TimeInterval(currentPhaseState.duration as Double + 1.0)
    intervalTimeRemainingTimer.setDate(Date(timeIntervalSinceNow:durationInterval))
    intervalTimeRemainingTimer.start()
  }
}

extension ActiveWorkoutInterfaceController: WorkoutSessionServiceDelegate {
  
  func workoutSessionService(_ service: WorkoutSessionService, didStartWorkoutAtDate startDate: Date) {
  }
  
  func workoutSessionService(_ service: WorkoutSessionService, didStopWorkoutAtDate endDate: Date) {
    presentSaveDataAlertController()
  }
  
  func workoutSessionServiceDidSave(_ service: WorkoutSessionService) {
    self.dismiss()
  }
  
  func workoutSessionService(_ service: WorkoutSessionService, didUpdateHeartrate heartRate:Double) {
    dataGroup.setHidden(false)
    dataLabel?.setText(numberFormatter.string(from: NSNumber(value: heartRate))! + " bpm")
  }
  
  func workoutSessionService(_ service: WorkoutSessionService, didUpdateDistance distance:Double) {
    print("\(distance)")
  }
  
  func workoutSessionService(_ service: WorkoutSessionService, didUpdateEnergyBurned energy:Double) {
  }
}
