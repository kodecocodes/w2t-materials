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
final public class Task: NSObject {
  
  public let name: String
  public var color: Color
  
  public var totalTimes: Int
  public var timesCompleted: Int
  
  public var isCompleted: Bool {
    return totalTimes == timesCompleted
  }
  
  public init(name: String, color: Color = .red, totalTimes: Int = 0, timesCompleted: Int = 0) {
    self.name = name
    self.color = color
    self.totalTimes = totalTimes
    self.timesCompleted = timesCompleted
  }
}

// MARK: Public
extension Task {
  public func completeOnce() {
    if (!isCompleted) {
      timesCompleted += 1
    }
  }
}

// MARK: Color
extension Task {
  public enum Color: Int, CustomStringConvertible {
    case blue, purple, green, yellow, orange, red
    public static let allColors = [blue, purple, green, yellow, orange, red]
    
    public var name: String {
      switch self {
      case .blue:     return "Blue"
      case .purple:   return "Purple"
      case .green:    return "Green"
      case .orange:   return "Orange"
      case .yellow:   return "Yellow"
      case .red:      return "Red"
      }
    }
    
    public var color: UIColor {
      switch self {
      case .blue:     return UIColor(red: 32/255.0, green: 148/255.0, blue: 250/255.0, alpha: 1)
      case .purple:     return UIColor(red: 120/255.0, green: 122/255.0, blue: 255/255.0, alpha: 1)
      case .green:    return UIColor(red: 4/255.0, green: 222/255.0, blue: 113/255.0, alpha: 1)
      case .orange:   return UIColor(red: 255/255.0, green: 149/255.0, blue: 0/255.0, alpha: 1)
      case .yellow:   return UIColor(red: 250/255.0, green: 200/255.0, blue: 20/255.0, alpha: 1)
      case .red:      return UIColor(red: 255/255.0, green: 59/255.0, blue: 48/255.0, alpha: 1)
      }
    }
    
    public var description: String {
      return name
    }
  }
}

// MARK: Equality
//extension Task: Equatable { }
public func ==(lhs: Task, rhs: Task) -> Bool {
  return lhs.name == rhs.name && lhs.color == rhs.color && lhs.totalTimes == rhs.totalTimes
}

// MARK: NSCoding
extension Task: NSCoding {
  private struct CodingKeys {
    static let name = "name"
    static let color = "color"
    static let totalTimes = "totalTimes"
    static let timesCompleted = "timesCompleted"
  }
  
  public convenience init(coder aDecoder: NSCoder) {
    let name = aDecoder.decodeObject(forKey: CodingKeys.name) as! String
    let color = Color(rawValue: aDecoder.decodeInteger(forKey: CodingKeys.color))!
    let totalTimes = aDecoder.decodeInteger(forKey: CodingKeys.totalTimes)
    let timesCompleted = aDecoder.decodeInteger(forKey: CodingKeys.timesCompleted)
    self.init(name: name, color: color, totalTimes: totalTimes, timesCompleted: timesCompleted)
  }
  
  public func encode(with encoder: NSCoder) {
    encoder.encode(name, forKey: CodingKeys.name)
    encoder.encode(color.rawValue, forKey: CodingKeys.color)
    encoder.encode(totalTimes, forKey: CodingKeys.totalTimes)
    encoder.encode(timesCompleted, forKey: CodingKeys.timesCompleted)
  }
}
