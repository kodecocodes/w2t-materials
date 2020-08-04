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

import AVFoundation
import AVKit
import MobileCoreServices
import UIKit

class MemosViewController: UITableViewController, MemoStoreObserver {
  
  static private let MemoCellIdentifier = "MemoCellIdentifier"
  
  var memos: [VoiceMemo] = []
  
  let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .long
    formatter.timeStyle = .short
    return formatter
  }()
  
  // MARK: View Life Cycle
  
  deinit {
    MemoStore.shared.unregisterObserver(self)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Turbo Memo"
    tableView.contentInset = UIEdgeInsets(top: -36, left: 0, bottom: 0, right: 0)
    MemoStore.shared.registerObserver(self)
  }
  
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    setTableViewBackgroundImageView()
  }
  
  // MARK: MemoStoreObserver
  
  func memoStore(store: MemoStore, didUpdateMemos memos: [VoiceMemo]) {
    self.memos = memos
    tableView.reloadData()
    setTableViewBackgroundImageView()
  }
  
  // MARK: IBActions
  
  @IBAction private func addMemoButtonTapped(sender: Any?) {
    presentAudioRecorderController()
  }
  
  // MARK: Helpers
  
  private func setTableViewBackgroundImageView() {
    
    // If there 'are' memos, make sure table view background view is clear and return.
    if memos.isEmpty == false {
      tableView.backgroundView = nil
      return
    }
    
    // Otherwise, display the onboarding image in background.
    let imageView: UIImageView
    if let backgroundView = tableView.backgroundView as? UIImageView {
      imageView = backgroundView
    } else {
      let image = UIImage(named: "onboarding")
      imageView = UIImageView(image: image)
    }
    
    let isWider = (tableView.bounds.size.width > tableView.bounds.size.height)
    imageView.contentMode = isWider ? .right : .scaleAspectFill
    imageView.frame = tableView.bounds
    tableView.backgroundView = imageView
  }
  
  //// A helper method to configure and display audio recorder controller.
  func presentAudioRecorderController() {
    let controller = storyboard?.instantiateViewController(withIdentifier: "AudioViewController") as! AudioViewController
    unowned let weakSelf = self
    controller.completion = { (output: URL?) in
      weakSelf.dismiss(animated: true, completion: nil)
      guard let output = output else { return }
      let memo = VoiceMemo(filename: output.lastPathComponent, date: Date())
      MemoStore.shared.add(memo: memo)
      MemoStore.shared.save()
    }
    controller.mode = .record
    present(controller, animated: true, completion: nil)
  }
  
  //// A helper method to configure and display audio player controller.
  func playAudioAtURL(URL:URL) {
    let controller = storyboard?.instantiateViewController(withIdentifier: "AudioViewController") as! AudioViewController
    unowned let weakSelf = self
    controller.completion = { (output: URL?) in
      weakSelf.dismiss(animated: true, completion: nil)
    }
    controller.audioFileToPlay = URL
    controller.mode = .play
    controller.shouldStartOnViewDidAppear = true
    present(controller, animated: true, completion: nil)
  }
}

// MARK: UITableViewDelegate

extension MemosViewController {
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return memos.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: MemosViewController.MemoCellIdentifier, for: indexPath as IndexPath) as! MemoCell
    let memo: VoiceMemo = memos[indexPath.row]
    cell.timeLabel.text = dateFormatter.string(from: memo.date)
    cell.previewImageView.image = UIImage(named: "voice-icon")
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let memo = memos[indexPath.row]
    playAudioAtURL(URL: memo.url)
    tableView.deselectRow(at: indexPath, animated: true)
  }
  
  override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
    return UITableViewCellEditingStyle.delete
  }
  
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    let index = indexPath.row
    let memoToDelete = memos[index]
    memos.remove(at: index)
    let store = MemoStore.shared
    store.removeMemo(memoToDelete)
    store.save()
    
    do {
      try FileManager.default.removeItem(at: memoToDelete.url)
    }
    catch {
      print("Failed to delete \(memoToDelete.url) from disk.")
    }
  }
  
}
