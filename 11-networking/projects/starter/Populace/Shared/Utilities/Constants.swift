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
import UIKit

let dateFormatter: DateFormatter = {
  let formatter = DateFormatter()
  
  formatter.dateFormat = "yyyy-MM-dd"
  
  return formatter
} ()

let numberFormatter: NumberFormatter = {
  let formatter = NumberFormatter()
  
  formatter.maximumFractionDigits = 1
  
  return formatter
} ()

let commaFormatter: NumberFormatter = {
  let formatter = NumberFormatter()
  
  formatter.maximumFractionDigits = 0
  formatter.usesGroupingSeparator = true
  
  return formatter
  } ()

let femaleColor = UIColor(red: 1.0, green: 0x22/0xff, blue: 0x67/0xff, alpha: 1.0)
let maleColor = UIColor(red: 0x29/0xff, green: 0x94/0xff, blue: 0xf4/0xff, alpha: 1.0)
