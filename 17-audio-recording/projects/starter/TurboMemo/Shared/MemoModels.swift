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

/// Base Memo. The base class for a memo.
@objc(VoiceMemo)
public class VoiceMemo: NSObject, NSCoding, NSCopying {
  
  public let date: Date
  public let filename: String
  public let url: URL
  
  public init(filename: String, date: Date) {
    self.filename = filename
    self.date = date
    
    let userDocuments = FileManager.default.userDocumentsDirectory
    self.url = userDocuments.appendingPathComponent(filename)
    
    super.init()
  }
  
  // MARK: NSCoding
  
  public required init?(coder aDecoder: NSCoder) {
    self.date = aDecoder.decodeObject(forKey: "date") as! Date
    self.filename = aDecoder.decodeObject(forKey: "filename") as! String
    let userDocuments = FileManager.default.userDocumentsDirectory
    self.url = userDocuments.appendingPathComponent(filename) as URL
    
    super.init()
  }
  
  public func encode(with aCoder: NSCoder) {
    aCoder.encode(self.date, forKey: "date")
    aCoder.encode(self.filename, forKey: "filename")
  }
  
  public func copy(with zone: NSZone? = nil) -> Any {
    let copy = VoiceMemo(filename: filename, date: date)
    return copy
  }
  
}

