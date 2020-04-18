//
//  FaceDetector.swift
//  FaceRecognition
//
//  Created by Narayanaswamy, Subhashini on 14/04/20.
//  Copyright © 2020 Narayanaswamy, Subhashini. All rights reserved.
//

import UIKit
import Vision

class FaceDetector {
    
    func findLandmarks(for image: UIImage, completion: @escaping((UIImage) -> Void)) {
        var resultImage = image
        let detectFaceRequest = VNDetectFaceLandmarksRequest { (request, error) in
            guard let observations = request.results as? [VNFaceObservation] else {
                return
            }
            
            print("Found \(observations.count) faces in the image")
            
            for face in observations {
                guard let landmark = face.landmarks else {
                    continue
                }
                let boundingBox = face.boundingBox
                var landmarkRegions: [VNFaceLandmarkRegion2D] = []
                
                if let faceContour = landmark.faceContour {
                    landmarkRegions.append(faceContour)
                }
                
                if let leftEye = landmark.leftEye {
                    landmarkRegions.append(leftEye)
                }
                
                if let rightEye = landmark.rightEye {
                    landmarkRegions.append(rightEye)
                }
                
                if let nose = landmark.nose {
                    landmarkRegions.append(nose)
                }
                
                if let noseCrest = landmark.noseCrest {
                    landmarkRegions.append(noseCrest)
                }
                
                if let outerLips = landmark.outerLips {
                    landmarkRegions.append(outerLips)
                }
                
                resultImage = self.drawOnImage(source: resultImage, boundingBox: boundingBox, regions: landmarkRegions)
            }
            
            completion(resultImage)
        }
        let requestHandler = VNImageRequestHandler(cgImage: image.cgImage!, options: [:])
        do {
            try requestHandler.perform([detectFaceRequest])
        } catch  {
            print(error)
        }
    }
    
    private func drawOnImage(source: UIImage, boundingBox: CGRect, regions faceLandmarks: [VNFaceLandmarkRegion2D]) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(source.size, false, 1)
        let context = UIGraphicsGetCurrentContext()!
        context.translateBy(x: 0, y: source.size.height)
        context.scaleBy(x: 1, y: -1)
        context.setBlendMode(CGBlendMode.colorBurn)
        context.setLineJoin(.round)
        context.setLineCap(.round)
        context.setShouldAntialias(true)
        context.setAllowsAntialiasing(true)
        
        let rectWidth = source.size.width * boundingBox.size.width
        let rectHeight = source.size.height * boundingBox.size.height
        
        let rect = CGRect(x: 0, y: 0, width: source.size.width, height: source.size.height)
        context.draw(source.cgImage!, in: rect)
        
        //draw face rect
        let x = boundingBox.origin.x * source.size.width
        let y = boundingBox.origin.y * source.size.height
        context.addRect(CGRect(x: x, y: y, width: rectWidth, height: rectHeight))
        context.drawPath(using: CGPathDrawingMode.stroke)
        
        //draw features
        let fillColor = UIColor.blue
        fillColor.setStroke()
        
        context.setLineWidth(2.0)
        for faceRegion in faceLandmarks {
            var points: [CGPoint] = []
            for i in 0..<faceRegion.pointCount {
                let point = faceRegion.normalizedPoints[i]
                let p = CGPoint(x: CGFloat(point.x), y: CGFloat(point.y))
                points.append(p)
            }
            
            let mappedPoints = points.map {
                CGPoint(x: boundingBox.origin.x * source.size.width + $0.x * rectWidth, y: boundingBox.origin.y * source.size.height + $0.y * rectHeight)
            }
            context.addLines(between: mappedPoints)
            context.drawPath(using: CGPathDrawingMode.stroke)
        }
        
        let faceImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return faceImage
    }
}
