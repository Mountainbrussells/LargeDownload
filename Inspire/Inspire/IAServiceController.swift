//
//  IAServiceController.swift
//  InspireApp
//
//  Created by BenRussell on 6/20/17.
//  Copyright © 2017 BenRussell. All rights reserved.
//

import Foundation

class IAServiceController: NSObject {
    let baseURL = "http://dev.inspiringapps.com/Files/IAChallenge/30E02AAA-B947-4D4B-8FB6-9C57C43872A9/Apache.log".addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
    
    let dataSource = IADataSource.sharedInstance
    
    func downloadLog(completion: @escaping (_ array: Array<RankedSequence>?, _ error: Error?) -> Void) {
        let url = URL(string: baseURL!)
        
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        let task = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            if (error != nil) {
                completion(nil, error)
            }
            else {
                let dataString = String(data: data!, encoding: .utf8)
                let dataArray = dataString?.components(separatedBy: "\n")
                self.sequenceArray(dataArray!, completion:{ (array) -> Void in
                    completion(array, nil)
                })
            }
        })
        task.resume()
        session.finishTasksAndInvalidate()
    }
    
    func sequenceArray(_ array: Array<String>, completion: @escaping (_ array: Array<RankedSequence>?) -> Void ) {
        var currentUser = ""
        DispatchQueue.global(qos: .background).async {
            var mutableData = array
            var counter = 0
            while mutableData.count > 0 {
                var currentSequence = [String]()
                let string0 = mutableData[0] as String
                currentUser = String(string0.characters.prefix(9))
                for string in mutableData {
                    if string != "" {
                        let requestArray = string.components(separatedBy: " ")
                        let user = requestArray[0] as String
                        let page = requestArray[6] as String
                        if user == currentUser {
                            currentSequence.append(page)
                            if currentSequence.count == 3 {
                                var alreadyRanked = false
                                for rankedSequence in self.dataSource.dataArray {
                                    if currentSequence == rankedSequence.sequence {
                                        rankedSequence.numberOfInstances = rankedSequence.numberOfInstances + 1
                                        alreadyRanked = true
                                        break
                                    }
                                }
                                if alreadyRanked == false {
                                    let rankedSequence = RankedSequence()
                                    rankedSequence.sequence = currentSequence
                                    rankedSequence.numberOfInstances = rankedSequence.numberOfInstances + 1
                                    self.dataSource.addSequence(rankedSequence)
                                }
                                break
                            }
                            
                        }
                    }
                }
                counter = counter + 1
                if counter == 500 {
                    self.dataSource.dataArray = self.dataSource.dataArray.sorted { $0.numberOfInstances > $1.numberOfInstances }
                    self.dataSource.sendDataAvailableNotice()
                    counter = 0
                }
                mutableData.remove(at: 0)
            }
            self.dataSource.dataArray = self.dataSource.dataArray.sorted { $0.numberOfInstances > $1.numberOfInstances }
            DispatchQueue.main.async {
                completion(self.dataSource.dataArray)
            }
        }
    }
    
}




