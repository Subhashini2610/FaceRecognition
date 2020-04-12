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
            guard let image = image else {return}
            cleanupOldFaceDetected()
            photoImageView.image = image
        }
    }
    
    let photoImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    func cleanupOldFaceDetected() {
        detectedFaces?.forEach({
            $0.removeFromSuperview()
        })
        detectedFaces?.removeAll()
    }
    
    func setupViews() {
        self.addSubview(photoImageView)
        NSLayoutConstraint.activate([
            photoImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            photoImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            photoImageView.topAnchor.constraint(equalTo: self.topAnchor),
            photoImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }
    
    @objc func handleTap() {
        cleanupOldFaceDetected()
        self.detectFaces()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
}
