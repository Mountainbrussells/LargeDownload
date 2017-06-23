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
                self.fillDataSource(dataArray!, completion:{ (array) -> Void in
                    completion(array, nil)
                })
            }
        })
        task.resume()
        session.finishTasksAndInvalidate()
    }
    
    func fillDataSource(_ array: Array<String>, completion: @escaping (_ array: Array<RankedSequence>?) -> Void ) {
        DispatchQueue.global(qos: .background).async {
            var mutableData = array
            var userDict = [String:Array<String>]()
            
            // create dictionary of pages arrays that users visited
            for string in mutableData {
                if string != "" {
                    let requestArray = string.components(separatedBy: " ")
                    let user = requestArray[0] as String
                    let page = requestArray[6] as String
                    if (userDict[user] != nil) {
                        userDict[user]!.append(page)
                    } else {
                        var userPageArray = [String]()
                        userPageArray.append(page)
                        userDict.updateValue(userPageArray, forKey: user)
                    }
                }
            }
            mutableData = []
            
            var counter = 0
            // Iterate through user's visited pages arrays in  dictionary
            for (_,pages) in userDict {
                // got through pages visited array
                for (index, _) in pages.enumerated(){
                    // Create sequence
                    var sequenceArray = [String]()
                    if pages.indices.contains(index + 2) {
                        sequenceArray.append(pages[index])
                        sequenceArray.append(pages[index + 1])
                        sequenceArray.append(pages[index + 2])
                    
                        // add to or update datasource with sequence
                        if self.dataSource.dataArray.contains(where: { rankedSequence in rankedSequence.sequence == sequenceArray }) {
                            let rankedArray = self.dataSource.dataArray.first(where: { $0.sequence == sequenceArray })
                            rankedArray?.numberOfInstances = (rankedArray?.numberOfInstances)! + 1
                        } else {
                            let rankedSequence = RankedSequence()
                            rankedSequence.sequence = sequenceArray
                            rankedSequence.numberOfInstances = rankedSequence.numberOfInstances + 1
                            self.dataSource.addSequence(rankedSequence)
                        }
                        counter = counter + 1
                        if counter == 500 {
                            self.dataSource.dataArray = self.dataSource.dataArray.sorted { $0.numberOfInstances > $1.numberOfInstances }
                            self.dataSource.sendDataAvailableNotice()
                            counter = 0
                        }
                    }
                }
            }
            self.dataSource.dataArray = self.dataSource.dataArray.sorted { $0.numberOfInstances > $1.numberOfInstances }
            DispatchQueue.main.async {
                completion(self.dataSource.dataArray)
            }
        }
    }
    
}




