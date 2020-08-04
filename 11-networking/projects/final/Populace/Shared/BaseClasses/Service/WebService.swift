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

enum WebServiceError: Error {
  case badResponse
  case noResponse
  case other
}


class WebService {
  let session: URLSession
  let rootURL: URL
  
  init (rootURL:URL) {
    self.rootURL = rootURL;
    
    let configuration = URLSessionConfiguration.default
    
    session = URLSession(configuration: configuration)
  }
  
  
  // MARK: - ****** Request Helpers ******
  
  internal func requestWithURLString(_ string: String) -> URLRequest? {
    if let url = URL(string: string, relativeTo: rootURL) {
      return URLRequest(url: url)
    }
    return nil
  }

  internal func executeRequest<ResponseType: Decodable>(_ requestPath:String, completion: @escaping (_ response: ResponseType?, _ error: NSError?) -> Void) {
    print("Executing Request With Path: \(requestPath)")
    if let request = requestWithURLString(requestPath) {
      // Create the task
      let task = session.dataTask(with: request) { data, response, error in
        
        if error != nil {
          completion(nil, error as NSError?)
          return
        }
        
        // Check to see if there was an HTTP Error
        let cleanResponse = self.checkResponseForErrors(response)
        if let errorCode = cleanResponse.errorCode {
          print("An error occurred: \(errorCode)")
          completion(nil, error as NSError?)
          return
        }

        // Decode the response
        let decoder = JSONDecoder()
        guard let data = data else {
          print("No response data")
          completion(nil, error as NSError?)
          return
        }

        let response: ResponseType
        do {
          response = try decoder.decode(ResponseType.self, from: data)
        } catch (let error) {
          print("Parsing Issues")
          completion(nil, error as NSError?)
          return
        }

        // Things went well, call the completion handler
        completion(response, nil)
      }
      task.resume()
      
    } else {
      // It was a bad URL, so just fire an error
      let error = NSError(domain:NSURLErrorDomain,
                          code:NSURLErrorBadURL,
                          userInfo:[ NSLocalizedDescriptionKey : "There was a problem creating the request URL:\n\(requestPath)"] )
      completion(nil, error)
    }
  }

  // MARK: - ****** Response Helpers ******
  
  /**
   Takes an `NSURLResponse` object and attempts to determine if any errors occurred
   - parameter response: The `NSURLResponse` generated by the task
   - returns: Tuple (`httpResponse` - The `NSURLResponse` cast to a `NSHTTPURLResponse` and `errorCode` - An error code enum representing detecable problems.)
   */
  internal func checkResponseForErrors(_ response: URLResponse?) -> (httpResponse: HTTPURLResponse?, errorCode: WebServiceError?) {
    // Make sure there was an actual response
    guard response != nil else {
      return (nil, WebServiceError.noResponse)
    }
    
    // Convert the response to an `NSHTTPURLResponse` (You can do this because you know that you are making HTTP calls in this scenario, so the cast will work.)
    guard let httpResponse = response as? HTTPURLResponse else {
      return (nil, WebServiceError.badResponse)
    }
    
    // Check to see if the response contained and HTTP response code of something other than 200
    let statusCode = httpResponse.statusCode
    guard statusCode == 200 else {
      return (nil, WebServiceError.other)
    }
    
    return (httpResponse, nil)
  }
}