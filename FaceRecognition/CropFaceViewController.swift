//
//  CropFaceViewController.swift
//  FaceRecognition
//
//  Created by Narayanaswamy, Subhashini on 12/04/20.
//  Copyright © 2020 Narayanaswamy, Subhashini. All rights reserved.
//

import UIKit

class CropFaceViewController: UIViewController {
    
    @IBOutlet weak var noDetectedFacesView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var faces: [UIImage] = []
    
    public var sourceImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        getFacesFromPicture()
        self.title = "Detected Faces"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        noDetectedFacesView.isHidden = faces.count == 0 ? false : true
    }
    
    func getFacesFromPicture() {
        FaceCropper.init(image: sourceImage!).crop { (faceImages, result) in
            switch result {
            case .success:
                self.faces = faceImages!
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            case .failed(let failed):
                print(failed)
            case .error(let error):
                print(error)
                
            }
        }
    }
}

extension CropFaceViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return faces.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cropFaceCell", for: indexPath) as! CropFaceCustomCell
        cell.imageView.image = faces[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.collectionView.frame.size.width / 3.2
        return CGSize(width: width, height: width)
    }
}
