//
//  PDYRequest.swift
//  Pushdy
//
//  Created by quandt on 6/21/19.
//  Copyright © 2019 Pushdy. All rights reserved.
//

import Foundation

@objc public class PDYRequest : NSObject {
    public typealias CompletionBlock = ((AnyObject?) -> Void)
    public typealias FailureBlock = ((Int, String?) -> Void)

    public class Method {
        public static let GET:String = "GET"
        public static let POST:String = "POST"
        public static let PUT:String = "PUT"
        public static let DELETE:String = "DELETE"
        
        private init() {
            
        }
    }
    
    static var defaultHeaders:[String:Any] = [
        "Content-Type" : "application/json",
        "Accept" : "application/json"
    ]
    
    func createQueryUrl(url:String, method:String, params:Any?) -> String {
        var finalUrl = url
        if (method == Method.GET || method == Method.DELETE) {
            if let parameters = params as? [String:Any] {
                let queryString = parameters.map { "\($0.0)=\($0.1)" }.joined(separator: "&")
                finalUrl += (finalUrl.contains("?") ? "&" : "?") + queryString
            }
        }
        return finalUrl
    }
    
    /**
        Request json data from api service.
     
        - Parameters:
            - url: The request url. Example: https://api.pushdi.com/application.
            - method: The http verbs. Example: GET, POST, PUT, DELETE.
            - headers: The request's headers. Example: ["foo" : "bar"].
            - params: The request's parameters. Example: ["foo" : "bar"].
            - completion: A callback function for getting response data.
            - failure: A callback function for getting request error.
    */
    func request(url:String, method: String, headers: [String: Any]?, params: Any?, completion: CompletionBlock?, failure: FailureBlock?) throws {
        var requestTask:URLSessionDataTask? = nil
        let finalUrl = self.createQueryUrl(url: url, method: method, params: params)
        let request = NSMutableURLRequest(url: NSURL(string:finalUrl)! as URL)
        let finalHeaders = headers != nil ? PDYRequest.defaultHeaders.merging(headers!) { (_, new) in new } : PDYRequest.defaultHeaders
        for (key, value) in finalHeaders {
            request.setValue(value as? String, forHTTPHeaderField: key)
        }
        
        request.httpMethod = method
        
        if method == Method.POST || method == Method.PUT  || method == Method.DELETE {
            if let contentType = finalHeaders["Content-Type"] as? String, let accept = finalHeaders["Accept"] as? String {
                if contentType == "application/json" && accept == "application/json" {
                    if let parameters = params as? [String:Any] {
//                        print("parameters %@", parameters)
                        do {
                            let httpBody = try JSONSerialization.data(withJSONObject: parameters, options: JSONSerialization.WritingOptions.init(rawValue: 0))
                            request.httpBody = httpBody
                        } catch let error as NSError {
                            print("PDYRequest convert dictionary error: \(error.localizedDescription)")
                        }
                    }
                    else if let parameters = params as? [Any] {
                        do {
                            let httpBody = try JSONSerialization.data(withJSONObject: parameters, options: JSONSerialization.WritingOptions.init(rawValue: 0))
                            request.httpBody = httpBody
                        } catch let error as NSError {
                            print("PDYRequest convert array error: \(error.localizedDescription)")
                        }
                    }
                }
                else {
                    
                    if let parameters = params as? [String:Any] {
                        let postString = parameters.map { "\($0.0)=\($0.1)" }.joined(separator: "&")
                        request.httpBody = postString.data(using: String.Encoding.utf8)
                    }
                }
            }
            else {
                let error = NSError(domain:"", code:-1, userInfo:[ NSLocalizedDescriptionKey: "PDYRequest Content-Type and Accept is not valid type"])
                throw error
            }
        }
        
        requestTask = URLSession.shared.dataTask(with: request as URLRequest) {
            (data, response, error) in
//            print("response %@", response)
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    do {
                        let jsonResponse = try JSONSerialization.jsonObject(with: data!, options:  JSONSerialization.ReadingOptions.mutableContainers)
                        completion?(jsonResponse as AnyObject)
                    } catch let error as NSError {
                        print("request error: \(error.localizedDescription)")
                        failure?(error.code, error.localizedDescription)
                    }
                }
                else {
                    print("request error code: \(httpResponse.statusCode) message: \(HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))")
                    failure?(httpResponse.statusCode, HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))
                }
            }
            else {
                print("request error: respone is not HTTPURLResponse object")
            }
        }
        
//        print("requestTask %@", requestTask)
        requestTask?.resume()
    }
    
    /**
         Make a GET request.
     
         - Parameters:
             - url: The request url. Example: https://api.pushdi.com/application.
             - headers: The request's headers. Example: ["foo" : "bar"].
             - params: The request's parameters. Example: ["foo" : "bar"].
             - completion: A callback function for getting response data.
             - failure: A callback function for getting request error.
     */
    func get(url:String, headers: [String: Any]?, params: Any?, completion: CompletionBlock?, failure: FailureBlock?) throws {
        try self.request(url: url, method: Method.GET, headers: headers, params: params, completion: completion, failure: failure)
    }
    
    /**
         Make a POST request.
     
         - Parameters:
             - url: The request url. Example: https://api.pushdi.com/application.
             - headers: The request's headers. Example: ["foo" : "bar"].
             - params: The request's parameters. Example: ["foo" : "bar"].
             - completion: A callback function for getting response data.
             - failure: A callback function for getting request error.
     */
    func post(url:String, headers: [String: Any]?, params: Any?, completion: CompletionBlock?, failure: FailureBlock?) throws {
        try self.request(url: url, method: Method.POST, headers: headers, params: params, completion: completion, failure: failure)
    }
    
    /**
         Make a PUT request.
     
         - Parameters:
             - url: The request url. Example: https://api.pushdi.com/application.
             - headers: The request's headers. Example: ["foo" : "bar"].
             - params: The request's parameters. Example: ["foo" : "bar"].
             - completion: A callback function for getting response data.
             - failure: A callback function for getting request error.
     */
    func put(url:String, headers: [String: Any]?, params: Any?, completion: CompletionBlock?, failure: FailureBlock?) throws {
        try self.request(url: url, method: Method.PUT, headers: headers, params: params, completion: completion, failure: failure)
    }
    
    /**
         Make a DELETE request.
     
         - Parameters:
             - url: The request url. Example: https://api.pushdi.com/application.
             - headers: The request's headers. Example: ["foo" : "bar"].
             - params: The request's parameters. Example: ["foo" : "bar"].
             - completion: A callback function for getting response data.
             - failure: A callback function for getting request error.
     */
    func delete(url:String, headers: [String: Any]?, params: Any?, completion: CompletionBlock?, failure: FailureBlock?) throws {
        try self.request(url: url, method: Method.DELETE, headers: headers, params: params, completion: completion, failure: failure)
    }
}
