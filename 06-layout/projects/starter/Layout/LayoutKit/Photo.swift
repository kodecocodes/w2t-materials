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

struct Photo {
  
  let imageName: String
  let username: String
  let timePosted: String
  let comment: String
  
  static var samplePhotos: [Photo] {
    return [
      Photo(imageName: "wwdc", username: "@ryannystrom", timePosted: "13m", comment: "I absolutely loved my first visit to WWDC! Can't wait to go back next year!"),
      Photo(imageName: "clouds", username: "@rwenderlich", timePosted: "59m", comment: "Some crazy looking clouds overhead tonight."),
      Photo(imageName: "gourmet", username: "@micpringle", timePosted: "4h", comment: "Check out this crazy dish I had tonight. This place is too fancy!"),
      Photo(imageName: "pizza", username: "@JackTripleU", timePosted: "16h", comment: "So. Much. Pizza."),
      Photo(imageName: "vineyard", username: "@moayes", timePosted: "2d", comment: "Beautiful afternoon to go and visit a winery. Rolling hills and wonderful people. The wine isn't too bad either!")
    ]
  }
  
}
