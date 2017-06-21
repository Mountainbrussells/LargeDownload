//
//  ViewController.swift
//  Inspire
//
//  Created by BenRussell on 6/21/17.
//  Copyright © 2017 BenRussell. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        var serviceController = IAServiceController()
        
        serviceController.downloadLog{ (array, error) in
            if error != nil {
                
            } else {
                print(array!)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

