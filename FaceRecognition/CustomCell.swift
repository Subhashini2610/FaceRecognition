//
//  CustomCell.swift
//  FaceRecognition
//
//  Created by Narayanaswamy, Subhashini (623) on 12/04/20.
//  Copyright © 2020 Narayanaswamy, Subhashini (623). All rights reserved.
//

import UIKit

class CustomCell: UICollectionViewCell {
    var detectedFaces: [UIView]?
    var image: UIImage? {
        didSet {
            guard let image = image else {
                return
            }
            cleanOldFacesDetected()
            photoImageView.contentMode = .scaleAspectFill
            photoImageView.image = image
        }
    }
    @IBOutlet weak var photoImageView: UIImageView!
    
    func cleanOldFacesDetected () {
        detectedFaces?.forEach({
            $0.removeFromSuperview()
        })
        detectedFaces?.removeAll()
    }
    
    func setupViews() {
//        self.addSubview(photoImageView)
        
//        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }
    
    @objc func handleTap() {
        cleanOldFacesDetected()
        //call face detection here
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
}
