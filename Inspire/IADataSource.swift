//
//  IADataSource.swift
//  Inspire
//
//  Created by BenRussell on 6/22/17.
//  Copyright © 2017 BenRussell. All rights reserved.
//

import Foundation

class IADataSource {
    
    class var sharedInstance: IADataSource {
        struct Static {
            static let instance: IADataSource = IADataSource()
        }
        return Static.instance
    }
    
    var dataArray: Array<RankedSequence> = [RankedSequence]()
    
    func sendDataAvailableNotice() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "dataAvailable"), object: self)
    }
    
    func addSequence(_ sequence: RankedSequence) {
        self.dataArray.append(sequence)
    }
}
