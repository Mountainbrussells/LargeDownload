//
//  ViewController.swift
//  Inspire
//
//  Created by BenRussell on 6/21/17.
//  Copyright © 2017 BenRussell. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, IADataSourceDelegate {
    
    var dataSource = IADataSource.sharedInstance

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var loadingIndicator: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource.delegate = self
        
        collectionView!.register(UINib(nibName: "IACollectionCellCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "Cell")
        // Do any additional setup after loading the view, typically from a nib.
        let serviceController = IAServiceController()
        
        serviceController.downloadLog{ (array, error) in
            if error != nil {
                
            } else {
                self.reloadData()
                self.loadingIndicator.isHidden = true
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.reloadData), name: NSNotification.Name(rawValue: "dataAvailable"), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reloadData() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    func sequenceAdded() {
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.dataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! IACollectionCellCollectionViewCell
    
        let currentSequence = dataSource.dataArray[indexPath.row]
        let sequenceText = currentSequence.sequence.map { String($0) } .joined(separator: " | ")
        cell.sequenceLabel.text = sequenceText
        
        let occuranceString = "Occured \(currentSequence.numberOfInstances) times"
        cell.numberOfOccurancesLabel.text = occuranceString
        return cell
    }


}

