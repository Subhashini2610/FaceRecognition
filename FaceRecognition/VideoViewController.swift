//
//  VideoViewController.swift
//  FaceRecognition
//
//  Created by Narayanaswamy, Subhashini (623) on 16/04/20.
//  Copyright © 2020 Narayanaswamy, Subhashini (623). All rights reserved.
//

import UIKit
import Vision
import AVFoundation

class VideoViewController: UIViewController {
    
    @IBOutlet weak var previewView: PreviewView!
    
    @IBOutlet weak var btnSwitchCamera: UIButton!
    
    var devicePosition: AVCaptureDevice.Position = .back
    
    var cameraMode: CameraMode = .backCamera
    
    var session = AVCaptureSession()
    var isSessionRunning = false
    let sessionQueue = DispatchQueue(label: "AV Session Queue")
    var sessionSetupResult: SessionSetupResult = .success
    var videoDeviceInput: AVCaptureInput!
    var videoDeviceOutput: AVCaptureVideoDataOutput!
    var videoDataOutputQueue = DispatchQueue(label: "video data output queue")
    
    var requests = [VNRequest]()
    
    var faceDetectionRequest: VNRequest!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        previewView.session = session
        faceDetectionRequest = VNDetectFaceLandmarksRequest(completionHandler: self.handleFaceLandmarks)
        setCameraAuth()
        setupVision()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        sessionQueue.async {
            switch self.sessionSetupResult {
                
            case .success:
                self.session.startRunning()
                self.isSessionRunning = self.session.isRunning
                
            case .notAuthorised:
                DispatchQueue.main.async {
                    let message = "Please allow camera access for face detection"
                    let alertController = UIAlertController(title: "Face Detection", message: message, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    alertController.addAction(UIAlertAction(title: "Open Settings", style: .default, handler: { (action) in
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                    }))
                    self.present(alertController, animated: true, completion: nil)
                }
                
            case .configurationFailed:
                DispatchQueue.main.async {
                    let message = "Unable to capture due to configuration issues"
                    let alertController = UIAlertController(title: "Face Detection", message: message, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                }
                
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        sessionQueue.async {
            if self.sessionSetupResult == .success {
                self.session.stopRunning()
                self.isSessionRunning = self.session.isRunning
            }
        }
        super.viewWillDisappear(animated)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        if let videoPreviewConnection = previewView.videoPreviewLayer.connection {
            let deviceOrientation = UIDevice.current.orientation
            guard let newVideoOrientation = deviceOrientation.videoOrientation,  deviceOrientation.isPortrait || deviceOrientation.isLandscape else {
                return
            }
            videoPreviewConnection.videoOrientation = newVideoOrientation
            
        }
    }
    
    func setCameraAuth() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            break
        case .notDetermined:
            sessionQueue.suspend()
            AVCaptureDevice.requestAccess(for: .video) { (granted) in
                if !granted {
                    self.sessionSetupResult = .notAuthorised
                }
                self.sessionQueue.resume()
            }
        default:
            sessionSetupResult = .notAuthorised
        }
        sessionQueue.async {
            self.configureSession()
        }
    }
    
    func configureSession() {
        if self.sessionSetupResult != .success {
            return
        }
        
        session.beginConfiguration()
        session.sessionPreset = .high
        
        do {
            var defaultVideoDevice: AVCaptureDevice?
            
            if let dualCameraDevice = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) {
                defaultVideoDevice = dualCameraDevice
            } else if let backCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
                defaultVideoDevice = backCameraDevice
            } else if let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
                defaultVideoDevice = frontCamera
            }
            
            let videoDeviceInput = try AVCaptureDeviceInput(device: defaultVideoDevice!)
            if session.canAddInput(videoDeviceInput) {
                session.addInput(videoDeviceInput)
                self.videoDeviceInput = videoDeviceInput
                DispatchQueue.main.async {
                    let statusBarOrientation = UIApplication.shared.windows.first?.windowScene?.interfaceOrientation
                    var initialVideoOrientation: AVCaptureVideoOrientation = .portrait
                    if statusBarOrientation != .unknown {
                        if let videoOrientation = statusBarOrientation?.videoOrientation {
                            initialVideoOrientation = videoOrientation
                        }
                    }
                    
                    self.previewView.videoPreviewLayer.connection?.videoOrientation = initialVideoOrientation
                }
            } else {
                print("Can't add video device input to session")
                sessionSetupResult = .configurationFailed
                session.commitConfiguration()
                return
            }
        } catch  {
            print(error)
            sessionSetupResult = .configurationFailed
            session.commitConfiguration()
            return
        }
        
        videoDeviceOutput = AVCaptureVideoDataOutput()
        videoDeviceOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
        
        if session.canAddOutput(videoDeviceOutput) {
            videoDeviceOutput.alwaysDiscardsLateVideoFrames = true
            videoDeviceOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
            session.addOutput(videoDeviceOutput)
        } else {
            print("Can't add output to session")
            sessionSetupResult = .configurationFailed
            session.commitConfiguration()
            return
        }
        
        session.commitConfiguration()
    }
    
    func exifOrientationFromDeviceOrientation() -> UInt32 {
        enum DeviceOrientation: UInt32 {
            case topLeft = 1
            case topRight = 2
            case bottomRight = 3
            case bottomLeft = 4
            case leftTop = 5
            case rightTop = 6
            case rightBottom = 7
            case leftBottom = 8
        }
        
        var exifOrientation: DeviceOrientation
        
        switch UIDevice.current.orientation {
        case .portraitUpsideDown:
            exifOrientation = .leftBottom
        case .landscapeLeft:
            //handles mirroring in case of front camera
            exifOrientation = devicePosition == .front ? .bottomRight : .topLeft
        case .landscapeRight:
            //handles mirroring in case of front camera
            exifOrientation = devicePosition == .front ? .topLeft : .bottomRight
        default:
            exifOrientation = .rightTop
        }
        
        return exifOrientation.rawValue
    }
    
    @IBAction func btnSwitchCameraPressed(_ sender: Any) {
        
        DispatchQueue.main.async {
            switch self.cameraMode {
            case .backCamera:
                self.cameraMode = .frontCamera
                self.btnSwitchCamera.titleLabel?.text = "Switch to back camera"
            case .frontCamera:
                self.cameraMode = .backCamera
                self.btnSwitchCamera.titleLabel?.text = "Switch to front camera"
                
            }
        }
        
        //Remove existing input
        guard let currentCameraInput: AVCaptureInput = session.inputs.first else {
            return
        }
        
        //Indicate that some changes will be made to the session
        session.beginConfiguration()
        session.removeInput(currentCameraInput)
        
        //Get new input
        var newCamera: AVCaptureDevice! = nil
        if let input = currentCameraInput as? AVCaptureDeviceInput {
            if (input.device.position == .back) {
                newCamera = cameraWithPosition(position: .front)
            } else {
                newCamera = cameraWithPosition(position: .back)
            }
        }
        
        //Add input to session
        var err: NSError?
        var newVideoInput: AVCaptureDeviceInput!
        do {
            newVideoInput = try AVCaptureDeviceInput(device: newCamera)
        } catch let err1 as NSError {
            err = err1
            newVideoInput = nil
        }
        
        if newVideoInput == nil || err != nil {
            print("Error creating capture device input: \(String(describing: err?.localizedDescription))")
        } else {
            session.addInput(newVideoInput)
        }
        
        //Commit all the configuration changes at once
        session.commitConfiguration()
    }
    
}

// Find a camera with the specified AVCaptureDevicePosition, returning nil if one is not found
func cameraWithPosition(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
    let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .unspecified)
    for device in discoverySession.devices {
        if device.position == position {
            return device
        }
    }
    return nil
}

extension VideoViewController {
    
    func handleFaces(request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            guard let results = request.results as? [VNFaceObservation] else {
                return
            }
            self.previewView.removemask()
            for face in results {
                self.previewView.drawFaceBoundingBox(faceObservation: face)
            }
        }
    }
    
    func handleFaceLandmarks(request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            guard let results = request.results as? [VNFaceObservation] else {
                return
            }
            self.previewView.removemask()
            for face in results {
                self.previewView.drawFaceWithLandmarks(faceObservation: face)
            }
        }
    }
    
    func setupVision() {
        self.requests = [faceDetectionRequest]
    }
    
}

extension VideoViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer), let exifOrientation = CGImagePropertyOrientation(rawValue: self.exifOrientationFromDeviceOrientation()) else { return }
        
        var requestOptions: [VNImageOption: Any] = [:]
        
        if let cameraIntrinsicData = CMGetAttachment(sampleBuffer, key: kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, attachmentModeOut: nil) {
            requestOptions = [VNImageOption.cameraIntrinsics: cameraIntrinsicData]
        }
        
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: exifOrientation, options: requestOptions)
        
        do {
            try imageRequestHandler.perform(requests)
        } catch  {
            print(error)
        }
    }
}

extension VideoViewController {
    enum SessionSetupResult {
        case success
        case notAuthorised
        case configurationFailed
    }
    
    enum CameraMode {
        case backCamera
        case frontCamera
    }
}

extension UIInterfaceOrientation {
    var videoOrientation: AVCaptureVideoOrientation? {
        switch self {
        case .portrait:
            return .portrait
        case .portraitUpsideDown:
            return .portraitUpsideDown
        case .landscapeLeft:
            return .landscapeLeft
        case .landscapeRight:
            return .landscapeRight
        default:
            return nil
        }
    }
}


extension UIDeviceOrientation {
    var videoOrientation: AVCaptureVideoOrientation? {
        switch self {
        case .portrait:
            return .portrait
        case .portraitUpsideDown:
            return .portraitUpsideDown
        case .landscapeLeft:
            return .landscapeRight
        case .landscapeRight:
            return .landscapeLeft
        default:
            return nil
        }
    }
}
