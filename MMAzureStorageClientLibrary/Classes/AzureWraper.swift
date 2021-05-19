//
//  AzureWraper.swift
//  WorkChat
//
//  Created by Van Trieu Phu Huy on 5/17/21.
//  Copyright © 2021 Van Trieu Phu Huy. All rights reserved.
//

import UIKit
import Foundation

internal extension Dictionary {
    
    var total: Double {
        var _total = Double(0)
        for item in self {
            _total = _total + ((item.value as? Double) ?? 0)
        }
        return _total
    }
    
}


internal extension String {
    func decodeUrl() -> String {
        return self.removingPercentEncoding ?? ""
    }
}



internal extension URL {
    func getKeyValues() -> [String : String]? {
        var results = [String: String]()
        if let keyValues = self.query?.decodeUrl().lowercased().components(separatedBy: "&") {
            if(keyValues.count > 0) {
                for pair in keyValues {
                    let kv = pair.components(separatedBy: "=")
                    if kv.count > 1 {
                        results.updateValue(kv[1], forKey: kv[0])
                    }
                }
                
            }
            return results
        }
        return nil
        
    }
    
    
}


@objc public class AzureWraper: NSObject {
    
    
    
    @objc public static let shared: AzureWraper = {
        let instance = AzureWraper()
        return instance
    }()
    
    var operationContextCollection: [String: AZSOperationContext] = [:]
    
    func removeOperationContext(id: String) {
        self.operationContextCollection.removeValue(forKey: id)
    }
    
    @objc public func cancel(id: String) {
        self.operationContextCollection[id]?.cancel()
        self.removeOperationContext(id: id)
    }
    
    @objc public func cancelAll() {
        for item in self.operationContextCollection {
            item.value.cancel()
        }
        self.operationContextCollection.removeAll()
    }
    
    //Upload to Azure Blob Storage with help of SAS
    @objc public func uploadBlobSAS(id: String? = nil, linkSAS: String, blockname: String, fromfile: String, progressHandler: @escaping (Double) -> Void, completion: ((String, Error?) -> Void)?, cancelRequest: ((String, Error?) -> Void)? = nil) {
        if let url = URL(string: linkSAS) {
            var errorBlockBlob: NSError?
            let blockBlob = AZSCloudBlockBlob(url: url, error: &errorBlockBlob)
            if let errorBlockBlob = errorBlockBlob {
                completion?(linkSAS, errorBlockBlob)
            } else {
                if let stream = InputStream(fileAtPath: fromfile) {
                    do {
                        let size = try Double((FileManager.default.attributesOfItem(atPath: fromfile) as NSDictionary).fileSize())
                        let operationContext = AZSOperationContext()
                        var totalBytesSentDict = [String: Double]()
                        var _totalBytesSent: Double = 0
                        operationContext.didSendBodyData = { (task, bytesSent, totalBytesSent, totalBytesExpectedToSend) in
                            _totalBytesSent = _totalBytesSent + Double(totalBytesSent)
                            /*
                            if let blobUploadHelper = stream.delegate as? AZSBlobUploadHelper {
                                print("")
                            }
                            */
                            
                            if let dict = task.currentRequest?.url?.getKeyValues(), let blockid = dict["blockid"] {
                                totalBytesSentDict[blockid] = Double(totalBytesSent)
                                //print("totalBytesSentDict: \(totalBytesSentDict)")
                                //print("total: \(totalBytesSentDict.total)")
                                let fractionCompleted = totalBytesSentDict.total / size
                                DispatchQueue.main.async {
                                    progressHandler(fractionCompleted)
                                }
                                //print("**** percentage: \(percentage)")
                            }
                            
                            //print("**** percentage: \(percentage) - \(_totalBytesSent) / \(size) - \(bytesSent), \(totalBytesSent), \(totalBytesExpectedToSend)")
                            
                            //print("**** percentage: \(bytesSent), \(totalBytesSent), \(totalBytesExpectedToSend) \(task.currentRequest?.url?.absoluteString ?? "")")
                        }
                        blockBlob.upload(from: stream, accessCondition: nil, requestOptions: nil, operationContext: operationContext) {[weak self] (e) in
                            //guard let `self` = self else { return }
                            self?.removeOperationContext(id: id ?? linkSAS)
                            if let er = e as NSError?, er.code == AZSECancelRequest, let cancelRequest = cancelRequest {
                                DispatchQueue.main.async {
                                    cancelRequest(linkSAS, e)
                                }
                            } else {
                                DispatchQueue.main.async {
                                    completion?(linkSAS, e)
                                }
                            }
                        }
                        self.operationContextCollection[id ?? linkSAS] = operationContext
                        
                    } catch {
                        completion?(linkSAS, error)
                    }
                    
                } else {
                    let serviceError = AzureWraper.serviceError(messageError: "Resource file not found", domain: "UploadBlobSAS")!
                    completion?(linkSAS, serviceError)
                }
                
                /*
                blockBlob.uploadFromFile(withPath: fromfile) { (e) in
                    completion?(linkSAS, e)
                }
                */
            }
        } else {
            let serviceError = AzureWraper.serviceError(messageError: "Link upload invalid", domain: "UploadBlobSAS")!
            completion?(linkSAS, serviceError)
        }
        
        
        
        
    }
    
    
    internal class func serviceError(messageError:String, domain:String) -> NSError? {
        
        return NSError(domain: domain, code: -1, userInfo: [NSLocalizedDescriptionKey: messageError])
        
        
    }
}
