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

class TasksViewController: UIViewController {
  @IBOutlet weak var tableView: UITableView!
  
  var tasks: TaskList = TaskList()
  var newTaskCell: NewTaskCell?
  var addingNewTask: Bool = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    tableView.backgroundColor = UIColor.black
    tableView.separatorStyle = .none
    loadSavedTasks()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    tableView.reloadData()
  }
}

// MARK: Updated Tasks
extension TasksViewController {
  func tasksUpdated() {
    saveTasks()
  }
}

// MARK: Add New Task
extension TasksViewController {
  @IBAction func beginAddingTask() {
    addingNewTask = true
    if tasks.ongoingTasks.count > 0 {
      tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .top)
    } else {
      tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .bottom)
    }
    
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(TasksViewController.finishAddingTask))
  }
  
  @objc func finishAddingTask() {
    guard let name = newTaskCell?.taskNameField.text, name.characters.count > 0 else {
      displayError("Please add a Name")
      return
    }
    
    guard let times = Int(newTaskCell?.taskTimesField.text ?? ""), times > 0 else {
      displayError("Invalid number of Times")
      return
    }
    
    guard let color = newTaskCell?.selectedColor else {
      displayError("Invalid Color")
      return
    }
    
    let task = Task(name: name, color: color, totalTimes: times)
    tasks.addTaskToFront(task)
    addingNewTask = false
    tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
    newTaskCell?.reset()
    tasksUpdated()
    
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(TasksViewController.beginAddingTask))
  }
  
  func displayError(_ error: String) {
    let alert = UIAlertController(title: error, message: nil, preferredStyle: .alert)
    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
    alert.addAction(okAction)
    self.present(alert, animated: true, completion: nil)
  }
}

// MARK: UITableViewDelegate
extension TasksViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if (indexPath .section == 1 || tasks.ongoingTasks.count == 0) {
      return
    }
    guard indexPath.section != 1 else { return }
    guard tasks.ongoingTasks.count != 0 else { return }
    guard !(addingNewTask && indexPath.section == 0 && indexPath.row == 0) else { return }
    
    let task = tasks.ongoingTasks[indexPath.row]
    
    tasks.didTask(task)
    
    if (task.isCompleted) {
      let indexSet = IndexSet(integersIn: 0..<2)
      tableView.reloadSections(indexSet, with: .automatic)
    }
    else {
      let cell = tableView.cellForRow(at: indexPath) as! TaskCell
      
      UIView.animate(withDuration: 0.4, delay: 0, options: [.beginFromCurrentState, .allowUserInteraction], animations: {
        cell.updateWithTask(task)
        cell.layoutIfNeeded()
        }, completion: nil)
    }
    tasksUpdated()
  }
  
  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    if let cell = cell as? NewTaskCell {
      cell.taskNameField.becomeFirstResponder()
    }
  }

  // Completed Header
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    if section == 1 && tasks.completedTasks.count > 0 {
      return 30
    }
    return 0
  }

  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    guard section == 1 && tasks.completedTasks.count > 0 else { return nil }
    let label = UILabel()
    label.text = "    COMPLETED"
    label.textColor = Theme.red
    label.backgroundColor = Theme.red.withAlphaComponent(0.17)

    return label
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if (addingNewTask && indexPath.row == 0 && indexPath.section == 0) {
      return 90
    }
    return 60
  }
}

// MARK: UITableViewDataSource
extension TasksViewController: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 0 {
      if addingNewTask {
        return 1 + tasks.ongoingTasks.count
      } else {
        return max(1,tasks.ongoingTasks.count)
      }
    }
    else if section == 1 {
      return tasks.completedTasks.count
    }
    return 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if (indexPath.section == 0 && indexPath.row == 0) {
      if addingNewTask {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewTaskCell", for: indexPath) as! NewTaskCell
        newTaskCell = cell
        return cell
      } else if tasks.ongoingTasks.count == 0 {
        // Placeholder when there are no ongoing tasks
        return tableView.dequeueReusableCell(withIdentifier: "NoOngoingCell", for: indexPath)
      }
    }
    
    let cell = tableView.dequeueReusableCell(withIdentifier: TaskCell.ReuseId, for: indexPath) as! TaskCell
    
    let task = indexPath.section == 0 ? tasks.ongoingTasks[indexPath.row] : tasks.completedTasks[indexPath.row]
    cell.updateWithTask(task)
    
    return cell
  }
}

// MARK: Task Persistance
extension TasksViewController {
  private var savedTasksPath: String {
    let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
    let docPath = paths.first!
    return (docPath as NSString).appendingPathComponent("SavedTasks")
  }
  
  func loadSavedTasks() {
    if let data = try? Data(contentsOf: URL(fileURLWithPath: savedTasksPath)) {
      let savedTasks = NSKeyedUnarchiver.unarchiveObject(with: data) as! TaskList
      tasks = savedTasks
    } else {
      tasks = TaskList()
    }
  }
  
  func saveTasks() {
    NSKeyedArchiver.archiveRootObject(tasks, toFile: savedTasksPath)
  }
}
