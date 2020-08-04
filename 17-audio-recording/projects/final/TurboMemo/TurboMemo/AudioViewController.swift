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
import CoreAudio
import AVFoundation
import UIKit

enum AudioMode {
  case undefined
  case play
  case record
}

class AudioViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
  
  var completion: ((_ output: URL?) -> ())?
  var audioFileToPlay: URL?
  var mode: AudioMode = .undefined
  
  /// A boolean indicating whether 'record' or 'play' should be automatically performed when view did appear.
  var shouldStartOnViewDidAppear: Bool = false
  
  deinit {
    let session = AVAudioSession.sharedInstance()
    do {
      try session.setActive(false)
    }
    catch {}
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    progressView.progress = 0.0
    saveButton.isHidden = true
    updateToMode(mode: .undefined)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    switch mode {
    case .play:
      updateToMode(mode: .play)
      if shouldStartOnViewDidAppear { play() }
      
    case .record:
      unowned let weakSelf = self
      AVAudioSession.sharedInstance().requestRecordPermission({ (granted: Bool) -> Void in
        if granted {
          weakSelf.updateToMode(mode: .record)
          if weakSelf.shouldStartOnViewDidAppear { weakSelf.record() }
        } else {
          weakSelf.updateToMode(mode: .undefined)
          weakSelf.presentAlertControllerForDeniedPermission()
        }
      })
      
    case .undefined : break
    }
  }
  
  // MARK: Private
  
  @IBOutlet private var cancelButton: UIButton!
  @IBOutlet private var saveButton: UIButton!
  
  @IBOutlet private var playButton: UIButton!
  @IBOutlet private var recordButton: UIButton!
  @IBOutlet private var stopButton: UIButton!
  @IBOutlet private var timeLabel: UILabel!
  @IBOutlet private var progressView: UIProgressView!
  
  private var recorder: AVAudioRecorder?
  private var player: AVAudioPlayer?
  private var timer: Timer?
  
  private let recordSettings: [String: Any] = {
    var settings: [String: Any] = [:]
    settings[AVFormatIDKey] = Int(kAudioFormatMPEG4AAC)
    settings[AVSampleRateKey] = 44100.0
    settings[AVNumberOfChannelsKey] = 2
    return settings
  }()
  
  private let outputURL = MemoFileNameHelper.newOutputURL()
  
  private let timeFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.minimumFractionDigits = 0
    formatter.maximumFractionDigits = 0
    formatter.minimumIntegerDigits = 2
    formatter.maximumIntegerDigits = 2
    return formatter
  }()
  
  /// Present an alert controller to notify user that permission is required for recording.
  private func presentAlertControllerForDeniedPermission() {
    let alertController = UIAlertController(title: "Error", message: "Turbo Memo requires your permission for audio recording. Go to Settings and give Turbo Memo access to microphone.", preferredStyle: .alert)
    let cancelAction = UIAlertAction(title: "Dimiss", style: .cancel, handler: { (action: UIAlertAction) -> Void in
      self.cancelButtonTapped(sender: nil)
    })
    alertController.addAction(cancelAction)
    present(alertController, animated: true, completion: nil)
  }
  
  private func formattedTimeFromTime(time: TimeInterval) -> String {
    let seconds = NSNumber(value: time.truncatingRemainder(dividingBy: 60.0))
    let formatted = timeFormatter.string(from: seconds)!
    return "00:00:\(formatted)"
  }
  
  private func updateToMode(mode: AudioMode) {
    let session = AVAudioSession.sharedInstance()
    
    do {
      switch mode {
      case .play:
        playButton.isHidden = false
        recordButton.isHidden = true
        stopButton.isHidden = true
        
        do {
          try session.setCategory(AVAudioSessionCategoryPlayback)
          player = try AVAudioPlayer(contentsOf: audioFileToPlay!)
          player?.numberOfLoops = 1
          player?.delegate = self
          player?.prepareToPlay()
        } catch let error {
          print("Failed to play audio: \(error)")
          playButton.isHidden = true
        }
        
      case .record:
        playButton.isHidden = true
        recordButton.isHidden = false
        stopButton.isHidden = true
        
        do {
          try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
          recorder = try AVAudioRecorder(url: outputURL, settings: recordSettings)
          recorder?.delegate = self
          recorder?.prepareToRecord()
        } catch let error {
          print("Failed to record audio: \(error)")
          recordButton.isHidden = true
        }
        
      case .undefined:
        playButton.isHidden = true
        recordButton.isHidden = true
        stopButton.isHidden = true
        break
      }
      
      try session.setActive(true)
    }
    catch {
      
    }
  }
  
  @objc private func updateViewWithTimer(timer: Timer) {
    
    var currentTime: TimeInterval = 0.0
    var duration: TimeInterval = 0.0
    
    switch mode {
    case .play:
      guard let player = player else { return }
      currentTime = player.currentTime
      duration = player.duration
      
    case .record:
      guard let recorder = recorder else { return }
      currentTime = recorder.currentTime
      duration = 30.0
      
    case .undefined:
      break
    }
    
    let progress = Float(currentTime / duration)
    progressView.setProgress(progress, animated: true)
    timeLabel.text = formattedTimeFromTime(time: currentTime)
  }
  
  /// A helper function to kick off the timer and update UI.
  private func kickOffTimer() {
    timer?.invalidate()
    timer = Timer.scheduledTimer(
      withTimeInterval: 1.0,
      repeats: true,
      block: { [weak self] aTimer in
        self?.updateViewWithTimer(timer: aTimer)
    })
    recorder?.record(forDuration: 30.0)
  }
  
  /// A helper function to start playing an audio file and update UI accordingly.
  private func play() {
    playButton.isHidden = true
    stopButton.isHidden = false
    cancelButton.isHidden = true
    player?.play()
    
    kickOffTimer()
  }
  
  /// A helper function to start recording an audio and update UI accordingly.
  private func record() {
    recordButton.isHidden = true
    stopButton.isHidden = false
    saveButton.isHidden = true
    cancelButton.isHidden = true
    
    AVAudioSession.sharedInstance().requestRecordPermission { [weak self] (granted) in
      guard granted else { return }
      DispatchQueue.main.async {
        self?.kickOffTimer()
      }
    }
  }
  
  // MARK: IBActions
  
  @objc @IBAction func recordButtonTapped(sender: UIButton) {
    record()
  }
  
  @objc @IBAction func stopButtonTapped(sender: UIButton) {
    stopButton.isHidden = true
    cancelButton.isHidden = false
    
    switch mode {
    case .play:
      player?.stop()
      playButton.isHidden = false
      
    case .record:
      recorder?.stop()
      recordButton.isHidden = false
      saveButton.isHidden = false
      
    case .undefined:
      break
    }
  }
  
  @objc @IBAction func playbackButtonTapped(sender: UIButton?) {
    play()
  }
  
  @objc @IBAction func cancelButtonTapped(sender: UIButton?) {
    completion?(nil)
  }
  
  @objc @IBAction func saveButtonTapped(sender: UIButton?) {
    completion?(outputURL)
  }
}

// MARK: AVAudioPlayerDelegate

extension AudioViewController {
  
  func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
    timer?.invalidate()
  }
  
  private func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
    timer?.invalidate()
  }
}
