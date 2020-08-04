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

extension FileManager {
  
  /// Moves a given file to user documents.
  /// Returns the destination URL on success or nil if it fails.
  /// This is a synchronous operation.
  func moveToUserDocuments(itemAt item: URL, renameTo rename: String?) -> URL? {
    
    let filename: String
    if let renameToName = rename {
      filename = renameToName
    } else {
      filename = item.lastPathComponent
    }
    
    let destination: URL = userDocumentsDirectory.appendingPathComponent(filename)
    let doesFileExist: Bool = fileExists(atPath: destination.relativePath)
    do {
      
      if doesFileExist {
        print("FileManager replacing \(filename) in documents directory...")
        _ = try replaceItemAt(destination, withItemAt: item)
      } else {
        print("FileManager moving \(filename) to documents directory...")
        try moveItem(at: item, to: destination)
      }
      return destination
      
    } catch let error {
      print("FileManager failed to move '\(filename)' to documents directory.\nError:\n\t\(error)")
      return nil
    }
  }
  
  /// Returns the user documents directory URL.
  var userDocumentsDirectory: URL {
    let manager = FileManager.default
    let url: URL = manager.urls(for: .documentDirectory, in: .userDomainMask).last!
    return url
  }
}
