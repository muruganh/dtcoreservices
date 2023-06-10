//
//  APIRequestManager.swift
// Shape Eat
//
//  Created by Murugan on 25/09/22.
//

import Foundation
import UIKit
import SystemConfiguration

enum MethodType: String{
    case post = "POST"
    case get = "GET"
    case put = "PUT"
    case delete = "DELETE"
}

class DTServices{
    static let sharedInstance = DTServices()
    var loaderDelegate: LoaderStartStopDelegate?
    var networkIssueDelegate: NetworkIssueDelegate?
    var popupDelegate: PopupDelegate?
    
    func getBaseUrl() -> String{
        if let baseUrl = Bundle.main.object(forInfoDictionaryKey: "baseUrl") as? String{
            return baseUrl
        }else{
            return ""
        }
    }
    
    func request(methodType: MethodType, api: String, param :Dictionary<String , AnyObject>, completion : @escaping(_ success: Bool, _ jsonObject : AnyObject?, _ configError: Bool) -> ())
    {
        if  getBaseUrl() != ""{
            let reqApi = getBaseUrl() + api
            if(methodType == .put){
                put(request: clientURLRequestPutMethod(path: reqApi, params: param)) { (success, object) in
                    DispatchQueue.main.async(execute: { () -> Void in
                        completion(true, object, false)
                    })
                }
            }else if(methodType == .get){
                get(request: clientURLRequestGetMethod(path: reqApi)) { (success, object) in
                    DispatchQueue.main.async(execute: { () -> Void in
                        completion(true, object, false)
                    })
                }
            }else if(methodType == .delete){
                delete(request: clientURLRequestPostMethod(path: reqApi, params: [:])) { (success, object) in
                    DispatchQueue.main.async(execute: { () -> Void in
                        DispatchQueue.main.async(execute: { () -> Void in
                            completion(true, object, false)
                        })
                    })
                }
            }else{
                post(request: clientURLRequestPostMethod(path: reqApi, params: param)) { (success, object) in
                    DispatchQueue.main.async(execute: { () -> Void in
                        completion(true, object, false)
                    })
                }
            }
        }else{
            debugPrint("Please check your base url in info.plist")
            completion(false, nil, true)
        }
    }
    
    private func get(request: NSMutableURLRequest, completion: @escaping (_ success: Bool, _ object: AnyObject?) -> ()) {
        dataTask(request: request, method: "GET", completion: completion)
    }
    
    private func post(request: NSMutableURLRequest, completion: @escaping (_ success: Bool, _ object: AnyObject?) -> ()) {
        dataTask(request: request, method: "POST", completion: completion)
    }
    
    private func delete(request: NSMutableURLRequest, completion: @escaping (_ success: Bool, _ object: AnyObject?) -> ()) {
        dataTask(request: request, method: "DELETE", completion: completion)
    }
    
    private func put(request: NSMutableURLRequest, completion: @escaping (_ success: Bool, _ object: AnyObject?) -> ()) {
        dataTask(request: request, method: "PUT", completion: completion)
    }
    
    private func clientURLRequestGetMethod(path: String) -> NSMutableURLRequest {
        let urlWithParams: NSString = path as NSString
        return setRequestDatas(strUrl: urlWithParams as String, params: [:], method: "GET")
    }
    private func clientURLRequestPostMethod(path: String, params: Dictionary<String , AnyObject>? = nil) -> NSMutableURLRequest {
        if params != nil {
            var paramString = ""
            var index : Int = 0
            for (key, value) in params! {
                index = index + 1
                let escapedKey = key
                let escapedValue = value
                if params!.count == index{
                    paramString += "\(escapedKey)=\(escapedValue)"
                }else{
                    paramString += "\(escapedKey)=\(escapedValue)&"
                }
            }
            return setRequestDatas(strUrl: path, params: params as Any, method: "POST")
        }
        
        return NSMutableURLRequest()
    }
    private func clientURLRequestPutMethod(path: String, params: Dictionary<String , AnyObject>? = nil) -> NSMutableURLRequest {
        if params != nil {
            var paramString = ""
            var index : Int = 0
            for (key, value) in params! {
                index = index + 1
                let escapedKey = key
                let escapedValue = value
                if params!.count == index{
                    paramString += "\(escapedKey)=\(escapedValue)"
                }else{
                    paramString += "\(escapedKey)=\(escapedValue)&"
                }
            }
            return setRequestDatas(strUrl: path, params: params as Any, method: "POST")
        }
        
        return NSMutableURLRequest()
    }
    func setRequestDatas(strUrl: String, params: Any, method: String)->NSMutableURLRequest{
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let jsonParams = String(data: jsonData, encoding: .utf8)!
        debugPrint("DTService: Url:----->\(strUrl)")
        debugPrint("DTService: Params:----->\(jsonParams)")
        let request = NSMutableURLRequest(url: NSURL(string: strUrl)! as URL)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if method == "POST"{
            request.httpBody = try! JSONSerialization.data(withJSONObject: params as Any, options: [])
        }
        return request
    }
    
    private func dataTask(request: NSMutableURLRequest, method: String, completion: @escaping (_ success: Bool, _ object: AnyObject?) -> ()) {
        if(Reachability.isConnectedToNetwork()){
            self.loaderDelegate?.isStartLoading(isload: true)
            request.httpMethod = method
            let session = URLSession(configuration: URLSessionConfiguration.default)
            session.dataTask(with: request as URLRequest) { (data, response, error) -> Void in
                // Globals.shared.disableLoaderForSomeScreen = false
                if let  data = data {
                    if let response = response as? HTTPURLResponse, 200...299 ~= response.statusCode {
                        do{
                            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                                let jsonData = try! JSONSerialization.data(withJSONObject: json, options: [])
                                let jsonResponse = String(data: jsonData, encoding: .utf8)!
                                debugPrint("DTService: Response-----> \(jsonResponse)")
                            }
                        }
                        catch let error as NSError{
                            print("DTService: Error---> ", error.localizedDescription)
                        }
                        completion(true, data as AnyObject?)
                    }else{
                        completion(false, data as AnyObject?)
                    }
                    self.loaderDelegate?.isStartLoading(isload: false)
                }
                if error != nil{
                    print("DTService: Error---> ", error?.localizedDescription ?? "")
                    self.loaderDelegate?.isStartLoading(isload: false)
                    DispatchQueue.main.async {
                        self.popupDelegate?.showMessage(msg: error?.localizedDescription ?? "")
                    }
                }
            }.resume()
        }else{
            self.popupDelegate?.showMessage(msg: "Please check your internet connection")
        }
    }
}

public class Reachability {
    class func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
}

protocol PopupDelegate: AnyObject{
    func showMessage(msg: String)
}
protocol LoaderStartStopDelegate: AnyObject {
    func isStartLoading(isload: Bool)
}
protocol NetworkIssueDelegate: AnyObject {
    func openNetworkIssuePopup()
}
