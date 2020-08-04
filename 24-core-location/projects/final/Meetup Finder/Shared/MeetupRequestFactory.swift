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

/**
 * This is a request factory that creates NSURLRequest to query api.meetup.com
 * using request models in which search parameters are defined.
 * The factory puts together query pamateres with based URL, API key and anything
 * else necessary.
 **/
class MeetupRequestFactory {
  
  private let APIKey = "YOUR_API_TOKEN"
  private let MeetupBaseURL = "https://api.meetup.com/"
  
  /// API Methods.
  private enum Method: String {
    case FindGroup = "find/groups"
  }
  
  /// Returns a NSURLRequest to query https://api.meetup.com/find/groups endpoint.
  func URLRequestForGroupSearchWithModel(_ model: MeetupGroupRequestModel) -> URLRequest {
    
    if APIKey == "YOUR_API_TOKEN" {
      print("\n\nMeetupRequestFactory encountered error: Invalid API token.\nYou need to set your own valid private API token for Meetup.com.\n\n")
      let name = NSExceptionName(rawValue: "Invalid API token")
      NSException.raise(name, format: "Error: %@", arguments: getVaList([]))
    }
    
    let base = baseURLWithMethod(.FindGroup)
    
    var URLString = base
    URLString += "&key=\(APIKey)"
    URLString += "&lon=\(model.longitude)"
    URLString += "&lat=\(model.latitude)"
    URLString += "&radius=\(model.radius)"
    URLString += "&page=\(model.pages)"
    if let searchText = model.searchText {
      URLString += "&text=\(searchText)"
    }
    
    let URL = Foundation.URL(string: URLString)!
    let request = URLRequest(url: URL, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringCacheData, timeoutInterval: 30.0)
    return request
  }
  
  private func baseURLWithMethod(_ method: Method) -> String {
    let output = MeetupBaseURL + method.rawValue + "?&"
    return output
  }
  
}
