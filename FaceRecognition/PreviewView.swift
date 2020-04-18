//
//  PreviewView.swift
//  FaceRecognition
//
//  Created by Narayanaswamy, Subhashini on 16/04/20.
//  Copyright © 2020 Narayanaswamy, Subhashini. All rights reserved.
//

import UIKit
import Vision
import AVFoundation

class PreviewView: UIView {
    
    private var maskLayer = [CAShapeLayer]()
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
    
    var session: AVCaptureSession? {
        get{
            return videoPreviewLayer.session
        }
        set {
            videoPreviewLayer.session = newValue
        }
    }
    
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    private func createLayer(with rect: CGRect) -> CAShapeLayer {
        let mask = CAShapeLayer()
        mask.frame = rect
        mask.cornerRadius = 10
        mask.opacity = 0.75
        mask.borderColor = UIColor.red.cgColor
        mask.borderWidth = 2.0
        maskLayer.append(mask)
        layer.insertSublayer(mask, at: 1)
        return mask
    }
    
    func drawFaceBoundingBox(faceObservation: VNFaceObservation) {
        _ = createLayer(with: normalizedDimensions(with: faceObservation))
    }
    
    func normalizedDimensions(with faceObservation: VNFaceObservation) -> CGRect {
        let scale = CGAffineTransform.identity.scaledBy(x: frame.width, y: frame.height)
        let transform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -frame.height)
        
        return faceObservation.boundingBox.applying(scale).applying(transform)
    }
    
    func drawFaceWithLandmarks(faceObservation: VNFaceObservation) {
        let faceBounds = normalizedDimensions(with: faceObservation)
        let faceLayer = createLayer(with: faceBounds)
        
        drawFaceLandmarks(on: faceLayer, faceLandmarkRegion: (faceObservation.landmarks?.nose)!)
        drawFaceLandmarks(on: faceLayer, faceLandmarkRegion: (faceObservation.landmarks?.noseCrest)!)
        drawFaceLandmarks(on: faceLayer, faceLandmarkRegion: (faceObservation.landmarks?.medianLine)!)
        drawFaceLandmarks(on: faceLayer, faceLandmarkRegion: (faceObservation.landmarks?.leftEye)!)
        drawFaceLandmarks(on: faceLayer, faceLandmarkRegion: (faceObservation.landmarks?.leftPupil)!)
        drawFaceLandmarks(on: faceLayer, faceLandmarkRegion: (faceObservation.landmarks?.leftEyebrow)!)
        drawFaceLandmarks(on: faceLayer, faceLandmarkRegion: (faceObservation.landmarks?.rightEye)!)
        drawFaceLandmarks(on: faceLayer, faceLandmarkRegion: (faceObservation.landmarks?.rightPupil)!)
        drawFaceLandmarks(on: faceLayer, faceLandmarkRegion: (faceObservation.landmarks?.rightEyebrow)!)
        drawFaceLandmarks(on: faceLayer, faceLandmarkRegion: (faceObservation.landmarks?.innerLips)!)
        drawFaceLandmarks(on: faceLayer, faceLandmarkRegion: (faceObservation.landmarks?.outerLips)!)
        drawFaceLandmarks(on: faceLayer, faceLandmarkRegion: (faceObservation.landmarks?.faceContour)!, closePath: false)
    }
    
    func drawFaceLandmarks(on targetLayer: CALayer, faceLandmarkRegion: VNFaceLandmarkRegion2D, closePath: Bool = true) {
        let rect: CGRect = targetLayer.frame
        var points: [CGPoint] = []
        
        for i in 0..<faceLandmarkRegion.pointCount {
            let point = faceLandmarkRegion.normalizedPoints[i]
            points.append(point)
        }
        
        let landmarkLayer = drawPointsOnLayer(rect: rect, landmarkPoints: points, closePath: closePath)
        
        landmarkLayer.transform = CATransform3DMakeAffineTransform(CGAffineTransform.identity.scaledBy(x: rect.width, y: -rect.height).translatedBy(x: 0, y: -1))
        
        targetLayer.insertSublayer(landmarkLayer, at: 1)
    }
    
    func drawPointsOnLayer(rect: CGRect, landmarkPoints: [CGPoint], closePath: Bool = true) -> CALayer {
        let linePath = UIBezierPath()
        linePath.move(to: landmarkPoints.first!)
        for point in landmarkPoints.dropFirst() {
            linePath.addLine(to: point)
        }
        if closePath {
            linePath.addLine(to: landmarkPoints.first!)
        }
        
        let lineLayer = CAShapeLayer()
        lineLayer.path = linePath.cgPath
        lineLayer.fillColor = nil
        lineLayer.opacity = 1.0
        lineLayer.strokeColor = UIColor.blue.cgColor
        lineLayer.lineWidth = 0.02
        
        return lineLayer
    }
    
    func removemask() {
        for mask in maskLayer {
            mask.removeFromSuperlayer()
        }
        maskLayer.removeAll()
    }
}
