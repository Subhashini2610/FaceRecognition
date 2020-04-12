//
//  FaceCropper.swift
//  FaceRecognition
//
//  Created by Narayanaswamy, Subhashini (623) on 13/04/20.
//  Copyright © 2020 Narayanaswamy, Subhashini (623). All rights reserved.
//

import UIKit
import Vision

enum Result {
    case success
    case failed(String)
    case error(String)
}

class FaceCropper {
    private var visionRequests: [VNRequest] = []
    private var faces: [UIImage] = []
    private var result: Result!
    
    var image: UIImage!
    
    var count: Int {
        return self.faces.count
    }
    
    init(image: UIImage) {
        self.image = image
    }
    
    func crop(completionHandler: @escaping ([UIImage]?, Result) -> Void) {
        let faceRequest = VNDetectFaceRectanglesRequest { (request, error) in
            guard let observations = request.results as? [VNFaceObservation] else {
                self.result = Result.error(error!.localizedDescription)
                completionHandler(nil, self.result)
                return
            }
            if observations.count > 0 {
                self.result = Result.success
                observations.forEach { (faceObservation) in
                    let imageWidth = self.image.size.width
                    let imageHeight = self.image.size.height
                    
                    let boxWidth = faceObservation.boundingBox.width * imageWidth
                    let boxHeight = faceObservation.boundingBox.height * imageHeight
                    
                    let boxOriginX = faceObservation.boundingBox.origin.x * imageWidth
                    let boxOriginY = (1 - faceObservation.boundingBox.origin.y) * imageHeight - boxHeight
                    
                    let faceRect = CGRect(x: boxOriginX, y: boxOriginY, width: boxWidth, height: boxHeight)
                    let cgImage = self.image.cgImage?.cropping(to: faceRect)
                    self.faces.append(UIImage(cgImage: cgImage!))
                }
                completionHandler(self.faces, self.result)
            } else {
                self.result = Result.failed("face not found")
                completionHandler(nil, self.result)
            }
        }
        
        self.visionRequests = [faceRequest]
        let imageRequestHandler = VNImageRequestHandler(cgImage: self.image.cgImage!, options: [:])
        do {
            try imageRequestHandler.perform(self.visionRequests)
        } catch  {
            print(error.localizedDescription)
        }
    }
}
