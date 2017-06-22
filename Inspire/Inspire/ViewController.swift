//
//  ViewController.swift
//  Inspire
//
//  Created by BenRussell on 6/21/17.
//  Copyright © 2017 BenRussell. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var dataSource = IADataSource.sharedInstance

    @IBOutlet weak var collectionView: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView!.register(UINib(nibName: "IACollectionCellCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "Cell")
        // Do any additional setup after loading the view, typically from a nib.
        var serviceController = IAServiceController()
        
        serviceController.downloadLog{ (array, error) in
            if error != nil {
                
            } else {
                self.collectionView.reloadData()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.dataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! IACollectionCellCollectionViewCell
    
        let currentSequence = dataSource.dataArray[indexPath.row]
        let sequenceText = currentSequence.sequence.map { String($0) } .joined(separator: " | ")
        cell.sequenceLabel.text = sequenceText
        return cell
    }


}

