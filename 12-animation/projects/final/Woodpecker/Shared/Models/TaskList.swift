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

import UIKit

// NSObject Inheritance required for NSCoding
final public class TaskList: NSObject {
  
  public var ongoingTasks: [Task]
  public var completedTasks: [Task]
  
  public init(ongoing: [Task] = [], completed: [Task] = []) {
    self.ongoingTasks = ongoing
    self.completedTasks = completed
  }
}

// MARK: Methods
extension TaskList {
  public func addTaskToFront(_ task: Task) {
    guard !task.isCompleted else { return }
    ongoingTasks.insert(task, at: 0)
  }
  
  public func addTask(_ task: Task) {
    if (task.isCompleted) {
      completedTasks.append(task)
    }
    else {
      ongoingTasks.append(task)
    }
  }
  
  public func didTask(_ task:Task) {
    if task.isCompleted {
      return
    }
    task.completeOnce()
    if task.isCompleted {
      finishedTask(task)
    }
  }
  
  public func finishedTask(_ task: Task) {
    if let index = ongoingTasks.index(of: task) {
      ongoingTasks.remove(at: index)
      completedTasks.append(task)
    }
  }
}

// MARK: NSCoding
extension TaskList: NSCoding {
  private struct CodingKeys {
    static let ongoing = "ongoing"
    static let completed = "completed"
  }
  
  public convenience init(coder aDecoder: NSCoder) {
    let ongoing = aDecoder.decodeObject(forKey: CodingKeys.ongoing) as! [Task]
    let completed = aDecoder.decodeObject(forKey: CodingKeys.completed) as! [Task]

    self.init(ongoing: ongoing, completed: completed)
  }
  
  public func encode(with encoder: NSCoder) {
    encoder.encode(ongoingTasks, forKey: CodingKeys.ongoing)
    encoder.encode(completedTasks, forKey: CodingKeys.completed)
  }
  
}
