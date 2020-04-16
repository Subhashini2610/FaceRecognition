//
//  CustomCell+Vision.swift
//  FaceRecognition
//
//  Created by Narayanaswamy, Subhashini (623) on 12/04/20.
//  Copyright © 2020 Narayanaswamy, Subhashini (623). All rights reserved.
//

import UIKit
import Vision

extension CustomCell {
    func detectFaces() {
        let request = VNDetectFaceRectanglesRequest { (request, error) in
            self.detectedFaces = []
            request.results?.forEach({ (result) in
                guard let result = result as? VNFaceObservation else {
                    return
                }
                self.handleFaceDetection(observation: result)
            })
        }
        performImageRequest(request: request)
    }
    func handleFaceDetection (observation: VNFaceObservation) {
        DispatchQueue.main.async {
            let boundingBox = observation.boundingBox
            let faceBox = self.createAnimatedFaceBox(image: self.image!, rect: boundingBox)
            self.addSubview(faceBox)
            self.detectedFaces?.append(faceBox)
        }
    }
    
    func createAnimatedFaceBox(image: UIImage, rect: CGRect) -> UIView {
        
        let imageScaledHeight = self.getScaledHeight(image: image)
        let yTransform = -imageScaledHeight - self.photoImageView.frame.height / 2 + imageScaledHeight / 2
        let transformFlip = CGAffineTransform.init(scaleX: 1, y: -1).translatedBy(x: 0, y: yTransform)
        let transformScale = CGAffineTransform.identity.scaledBy(x: self.frame.width, y: imageScaledHeight)
        let convertedRect = rect.applying(transformScale).applying(transformFlip)
        
        let faceBox = UIView()
        faceBox.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        faceBox.layer.borderWidth = 2
        faceBox.layer.cornerRadius = 8
        faceBox.frame = convertedRect
        faceBox.backgroundColor = UIColor(white: 1.0, alpha: 0.3)
        faceBox.layer.transform = CATransform3DMakeScale(0, 0, 0)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
            faceBox.layer.transform = CATransform3DMakeScale(1, 1, 1)
        }, completion: nil)
        return faceBox
                
    }
    
    func getScaledHeight(image: UIImage) -> CGFloat {
        return self.frame.size.width / image.size.width * image.size.height
    }
    
    func performImageRequest(request: VNDetectFaceRectanglesRequest) {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async {
            guard let cgImage = self.image?.cgImage else { return }
            let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try requestHandler.perform([request])
            } catch let err{
                print(err.localizedDescription)
            }
        }
    }
}
