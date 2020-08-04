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

class AudioPlayerInterfaceController: WKInterfaceController {
  
  private var player: WKAudioFilePlayer!
  private var asset: WKAudioFileAsset!
  private var statusObserver: NSKeyValueObservation?
  private var timer: Timer!

  @IBOutlet private var playButton: WKInterfaceButton!
  @IBOutlet private var interfaceTimer: WKInterfaceTimer!
  @IBOutlet private var titleLabel: WKInterfaceLabel!

  override func awake(withContext context: Any?) {
    super.awake(withContext: context)
    let memo = context as! VoiceMemo
    asset = WKAudioFileAsset(url: memo.url)
    titleLabel.setText(memo.filename)
    playButton.setEnabled(false)
  }
  
  override func didAppear() {
    super.didAppear()
    prepareToPlay()
  }
  
  @IBAction func playButtonTapped() {
    prepareToPlay()
  }
  
  private func prepareToPlay() {
    // 1
    let playerItem = WKAudioFilePlayerItem(asset: asset)
    // 2
    player = WKAudioFilePlayer(playerItem: playerItem)
    // 3
    statusObserver = player.observe(
      \.status,
      changeHandler: { [weak self] (player, change) in
        // 4
        guard
          player.status == .readyToPlay,
          let duration = self?.asset.duration
          else { return }
        // 5
        let date = Date(timeIntervalSinceNow: duration)
        self?.interfaceTimer.setDate(date)
        // 6
        self?.playButton.setEnabled(false)
        // 7
        player.play()
        self?.interfaceTimer.start()
        // 8
        self?.timer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false, block: { _ in
          self?.playButton.setEnabled(true)
        })
    })
  }
}

