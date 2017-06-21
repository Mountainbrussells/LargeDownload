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
                let returnArray = self.sequenceArray(dataArray!)
                completion(returnArray, nil)
                
            }
        })
        task.resume()
        session.finishTasksAndInvalidate()
    }
    
    func sequenceArray(_ array: Array<String>) -> Array<RankedSequence> {
        var currentUser = ""
        var sequenceArray = [Array<String>]()
        
            var mutableData = array
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
                            if currentSequence.count == 3{
                                break
                            }
                        }
                    }
                }
                if currentSequence.count == 3 {
                    sequenceArray.append(currentSequence)
                }
                mutableData.remove(at: 0)
            }
            let returnArray = self.rankArray(sequenceArray)
            // let returnArray1 = self.rankedArray(sequenceArray)
            return returnArray
    }
    
    
    
    func rankArray(_ array:Array<Array<String>>) -> Array<RankedSequence> {
        var rankedArray = [RankedSequence]()
        for sequence in array {
            var alreadyRanked = false
            for rankedSequence in rankedArray {
                if sequence == rankedSequence.sequence {
                    rankedSequence.numberOfInstances = rankedSequence.numberOfInstances + 1
                    alreadyRanked = true
                    break
                }
            }
            if alreadyRanked == false {
                let rankedSequence = RankedSequence()
                rankedSequence.sequence = sequence
                rankedSequence.numberOfInstances = rankedSequence.numberOfInstances + 1
                rankedArray.append(rankedSequence)
            }
            
        }
        let sortedArray = rankedArray.sorted { $0.numberOfInstances > $1.numberOfInstances }
        rankedArray = []
        return sortedArray
    }
}




