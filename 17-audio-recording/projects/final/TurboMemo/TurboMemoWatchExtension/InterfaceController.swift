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

enum InterfaceState {
  case instantiated
  case awake
  case initialized
}

class InterfaceController: WKInterfaceController, MemoStoreObserver {
  
  /// A group that's shown when the controller doesn't have valid content, e.g. there is no voice or video memo.
  /// invalidContentGroup and validContentGroup are mutually exclusive and are not shown at the same time.
  @IBOutlet private var invalidContentGroup: WKInterfaceGroup!
  
  /// A group that's shown when there is content.
  /// invalidContentGroup and validContentGroup are mutually exclusive and are not shown at the same time.
  @IBOutlet private var validContentGroup: WKInterfaceGroup!
  
  /// The interface table where content is shown.
  @IBOutlet private var interfaceTable: WKInterfaceTable!
  
  private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "hh:mma\nMM/dd/yyyy"
    return dateFormatter
  }()
  
  var memos: [VoiceMemo] = []
  var interfaceState = InterfaceState.instantiated
  
  override func awake(withContext context: Any?) {
    super.awake(withContext: context)
    interfaceState = .awake
  }
  
  override func willActivate() {
    super.willActivate()
    MemoStore.shared.registerObserver(self)
  }
  
  override func didDeactivate() {
    super.didDeactivate()
    MemoStore.shared.unregisterObserver(self)
  }
  
  override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
    let memo = memos[rowIndex]
    presentController(withName: "AudioPlayerInterfaceController", context: memo)
  }
  
  // MARK: Helper
  
  /// The designated helper method to reload and update the entire interface when the data source is updated.
  func reloadInterface() {
    updateVisiblityOfInterfaceContentGroups { () -> Void in
      self.updateInterfaceTableRowCounts(completion: { () -> Void in
        self.updateInterfaceTableData()
      })
    }
  }
  
  /// A helper method to change and update visiblity of WKInterfaceGroup objects based on content.
  func updateVisiblityOfInterfaceContentGroups(completion: @escaping () -> Void) {
    let hasContent = (memos.count != 0)
    validContentGroup.setHidden(!hasContent)
    invalidContentGroup.setHidden(hasContent)
    DispatchQueue.main.async(execute: completion)
  }
  
  /// A helper method to initialize or update the number of rows in the interface table.
  func updateInterfaceTableRowCounts(completion: @escaping () -> Void) {
    switch interfaceState {
    case .instantiated:
      break
      
    case .awake:
      fallthrough
      
    case .initialized:
      interfaceTable.setNumberOfRows(memos.count, withRowType: "MemoRowController")
      interfaceState = .initialized
    }
    DispatchQueue.main.async(execute: completion)
  }
  
  /// A helper method to set and update content of the interface table
  func updateInterfaceTableData() {
    for (index, memo) in memos.enumerated() {
      let controller = interfaceTable.rowController(at: index) as! MemoRowController
      let dateString = dateFormatter.string(from: memo.date)
      controller.textLabel.setText(dateString)
    }
  }
  
  // MARK: MemoStoreObserver
  
  func memoStore(store: MemoStore, didUpdateMemos memos: [VoiceMemo]) {
    self.memos = memos
    reloadInterface()
  }
  
  // MARK: Recording
  
  @IBAction private func addVoiceMemoMenuItemTapped() {
    let outputURL = MemoFileNameHelper.newOutputURL()
    let preset = WKAudioRecorderPreset.narrowBandSpeech
    let options: [String : Any] = [WKAudioRecorderControllerOptionsMaximumDurationKey: 30]
    
    presentAudioRecorderController(
      withOutputURL: outputURL,
      preset: preset,
      options: options) { [weak self] (didSave: Bool, error: Error?) in
        print("Did save? \(didSave) - Error: \(String(describing: error))")
        guard didSave else { return }
        self?.processRecordedAudio(at: outputURL)
    }
  }
  
  private func processRecordedAudio(at url: URL) {
    let voiceMemo = VoiceMemo(filename: url.lastPathComponent, date: Date())
    MemoStore.shared.add(memo: voiceMemo)
    MemoStore.shared.save()
  }
  
}

