//
//  TextDetector.swift
//  FaceRecognition
//
//  Created by Narayanaswamy, Subhashini on 18/04/20.
//  Copyright © 2020 Narayanaswamy, Subhashini. All rights reserved.
//

import UIKit
import Vision

class TextDetector {
    
    func detectText(on image: UIImage, completion: @escaping (UIImage?) -> Void) {
        let request = VNDetectTextRectanglesRequest { (request, error) in
            
            guard let observations = request.results as? [VNTextObservation], error == nil else {
                return
            }
            if observations.count == 0 {
                completion(nil)
            }
            var resultImage = image
            for observation in observations {
                if let charBoxes = observation.characterBoxes {
                    resultImage = self.drawOverlayOnImage(image: resultImage, observations: charBoxes)
                }
                
            }
            
            completion(resultImage)
        }
        request.reportCharacterBoxes = true
        let requestHandler = VNImageRequestHandler(cgImage: image.cgImage!, options: [:])
        do {
            try requestHandler.perform([request])
        } catch {
            print(error)
        }
    }
    
    private func drawOverlayOnImage(image: UIImage, observations: [VNRectangleObservation]) -> UIImage {
        
        UIGraphicsBeginImageContext(image.size)
        
        image.draw(at: CGPoint.zero)
        
        let context = UIGraphicsGetCurrentContext()!
        var transform = CGAffineTransform.identity
        transform = transform.scaledBy(x: image.size.width, y: -image.size.height)
        transform = transform.translatedBy(x: 0, y: -1)
        
        context.setLineWidth(2.0)
        context.setStrokeColor(UIColor.yellow.cgColor)
        
        for rect in observations {
            UIBezierPath(rect: rect.boundingBox.applying(transform)).stroke()
        }
        
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        return resultImage!
    }
}
