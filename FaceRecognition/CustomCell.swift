//
//  CustomCell.swift
//  FaceRecognition
//
//  Created by Narayanaswamy, Subhashini on 12/04/20.
//  Copyright © 2020 Narayanaswamy, Subhashini. All rights reserved.
//

import UIKit

protocol FaceInformation: class {
    func viewCroppedFaces(image: UIImage)
}

class CustomCell: UICollectionViewCell {
    
    unowned var delegate: FaceInformation?
    var detectedFaces: [UIView]?
    var image: UIImage? {
        didSet {
            guard let image = image else {return}
            cleanupOldFaceDetected()
            photoImageView.contentMode = .scaleAspectFit
            photoImageView.image = image
        }
    }
    
    @IBOutlet weak var photoImageView: UIImageView!
    func cleanupOldFaceDetected() {
        detectedFaces?.forEach({
            $0.removeFromSuperview()
        })
        detectedFaces?.removeAll()
    }
    
    func setupViews() {
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
    @IBAction func didTapToViewCroppedFaces(_ sender: Any) {
        self.delegate?.viewCroppedFaces(image: self.image!)
    }
    @IBAction func didTapViewContourLines(_ sender: Any) {
        DispatchQueue.global().async{
            FaceDetector().findLandmarks(for: self.image!) { (image) in
                DispatchQueue.main.async {                           if let finalImage = image {
                        self.photoImageView.image = finalImage
                    } else {
                        self.showToast(message: "No faces were detected", font: UIFont(name: "HelveticaNeue-Thin", size: 14.0)!)
                    }
                }
            }
        }
    }
    
    @IBAction func didTapToViewTexts(_ sender: Any) {
        let inputImage = self.photoImageView.image
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async {
            TextDetector().detectText(on: inputImage!) { (resultImage) in
                DispatchQueue.main.async {
                    if let finalImage = resultImage {
                        self.photoImageView.image = finalImage
                    } else {
                        self.showToast(message: "No text was detected", font: UIFont(name: "HelveticaNeue-Thin", size: 14.0)!)
                    }
                }
            }
        }
    }
}

extension CustomCell {

func showToast(message : String, font: UIFont) {

    let toastLabel = UILabel(frame: CGRect(x: self.contentView.frame.size.width/2 - 75, y: self.contentView.frame.size.height-100, width: 150, height: 35))
    toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
    toastLabel.textColor = UIColor.white
    toastLabel.font = font
    toastLabel.textAlignment = .center;
    toastLabel.text = message
    toastLabel.alpha = 1.0
    toastLabel.layer.cornerRadius = 10;
    toastLabel.clipsToBounds  =  true
    self.contentView.addSubview(toastLabel)
    UIView.animate(withDuration: 3.0, delay: 0.0, options: .curveEaseOut, animations: {
         toastLabel.alpha = 0.0
    }, completion: {(isCompleted) in
        toastLabel.removeFromSuperview()
    })
} }
