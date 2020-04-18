//
//  ViewController.swift
//  FaceRecognition
//
//  Created by Narayanaswamy, Subhashini on 11/04/20.
//  Copyright © 2020 Narayanaswamy, Subhashini. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    var data: [UIImage] = [#imageLiteral(resourceName: "HarryPotter"), #imageLiteral(resourceName: "friends"), #imageLiteral(resourceName: "avengers"), #imageLiteral(resourceName: "office"), #imageLiteral(resourceName: "TextDetection")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.title = "Face and Text Detection"
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CustomCell
        cell.delegate = self
        cell.image = data[indexPath.item]
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.collectionView.frame.width, height: self.collectionView.frame.height)
    }
}


extension ViewController: FaceInformation {
    
    func viewCroppedFaces(image: UIImage) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "CropFaceViewController") as! CropFaceViewController
        nextViewController.sourceImage = image
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
}

