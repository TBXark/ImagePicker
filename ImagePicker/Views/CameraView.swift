//
//  CameraView.swift
//  ImagePicker
//
//  Created by Tbxark on 28/12/2016.
//  Copyright © 2016 Tbxark. All rights reserved.
//

import UIKit
import AVFoundation


public typealias TKCameraShotCompletion = (UIImage) -> Void

class CameraView: UIView {
    
    var session: AVCaptureSession!
    var input: AVCaptureDeviceInput!
    var device: AVCaptureDevice!
    var imageOutput: AVCaptureStillImageOutput!
    var preview: AVCaptureVideoPreviewLayer!
    
    let cameraQueue = DispatchQueue.main
    
    var currentPosition = AVCaptureDevicePosition.back
    
    func startSession() {
        cameraQueue.async {
            self.createSession()
            self.session?.startRunning()
        }
    }
    
    func pauseSession() {
        cameraQueue.async {
            self.session?.stopRunning()
        }
    }
    
    func stopSession() {
        cameraQueue.async {
            self.session?.stopRunning()
            self.preview?.removeFromSuperlayer()
            
            self.session = nil
            self.input = nil
            self.imageOutput = nil
            self.preview = nil
            self.device = nil
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let p = preview {
            p.frame = bounds
        }
    }
    
    fileprivate func createSession() {
        session = AVCaptureSession()
        session.sessionPreset = AVCaptureSessionPresetHigh
        DispatchQueue.main.async {
            self.createPreview()
        }
    }
    
    fileprivate func createPreview() {
        device = cameraWithPosition(currentPosition)
        
        let outputSettings = [AVVideoCodecKey:AVVideoCodecJPEG]
        
        do {
            input = try AVCaptureDeviceInput(device: device)
        } catch let error as NSError {
            input = nil
            return
        }
        
        if session.canAddInput(input) {
            session.addInput(input)
        }
        
        imageOutput = AVCaptureStillImageOutput()
        imageOutput.outputSettings = outputSettings
        
        session.addOutput(imageOutput)
        
        preview = AVCaptureVideoPreviewLayer(session: session)
        preview.videoGravity = AVLayerVideoGravityResizeAspectFill
        preview.frame = bounds
        
        layer.addSublayer(preview)
    }
    
    fileprivate func cameraWithPosition(_ position: AVCaptureDevicePosition) -> AVCaptureDevice? {
        let devices = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo)
        var _device: AVCaptureDevice?
        for d in devices! {
            if (d as AnyObject).position == position {
                _device = d as? AVCaptureDevice
                break
            }
        }
        
        return _device
    }
    
    func capturePhoto(_ completion: @escaping TKCameraShotCompletion) {
        cameraQueue.async {
            let orientation = AVCaptureVideoOrientation(rawValue: UIDevice.current.orientation.rawValue)!
            CameraView.takePhoto(self.imageOutput, videoOrientation: orientation, cropSize: self.frame.size) { image in
                var correctedImage = image
                self.session.stopRunning()
                
                completion(correctedImage)
            }
        }
    }
    
    func swapCameraInput() {
        if session != nil && input != nil {
            session.beginConfiguration()
            session.removeInput(input)
            
            if input.device.position == AVCaptureDevicePosition.back {
                currentPosition = AVCaptureDevicePosition.front
                device = cameraWithPosition(currentPosition)
            } else {
                currentPosition = AVCaptureDevicePosition.back
                device = cameraWithPosition(currentPosition)
            }
            
            let error = NSErrorPointer(nilLiteral:())
            do {
                input = try AVCaptureDeviceInput(device: device)
            } catch let error1 as NSError {
                error?.pointee = error1
                input = nil
            }
            
            session.addInput(input)
            session.commitConfiguration()
        }
    }
    
    class func takePhoto(_ stillImageOutput: AVCaptureStillImageOutput, videoOrientation: AVCaptureVideoOrientation, cropSize: CGSize, completion: @escaping TKCameraShotCompletion) {
        var videoConnection: AVCaptureConnection? = nil
        
        for connection in stillImageOutput.connections {
            for port in (connection as! AVCaptureConnection).inputPorts {
                if (port as AnyObject).mediaType == AVMediaTypeVideo {
                    videoConnection = connection as? AVCaptureConnection
                    break
                }
            }
            
            if videoConnection != nil {
                break
            }
        }
        
        videoConnection?.videoOrientation = videoOrientation
        
        stillImageOutput.captureStillImageAsynchronously(from: videoConnection!, completionHandler: { buffer, error in
            if buffer != nil {
                let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer)
                let image = UIImage(data: imageData!)!
                completion(image)
            }
        })
    }
    
    
    class func crop(image: UIImage, zoom: CGFloat,  cropRect: CGRect) -> UIImage {
       
        var newOrient: UIImageOrientation = .up
        switch image.imageOrientation {
        case .up:
            newOrient = .upMirrored
        case .upMirrored:
            newOrient = .up
        case .down:
            newOrient = .downMirrored
        case .downMirrored:
            newOrient = .down
        case .left:
            newOrient = .rightMirrored
        case .leftMirrored:
            newOrient = .right
        case .right:
            newOrient = .leftMirrored
        case .rightMirrored:
            newOrient = .left
        }

        var rect = cropRect
        rect.origin.x *= image.scale * zoom
        rect.origin.y *= image.scale * zoom
        rect.size.width *= image.scale * zoom
        rect.size.height *= image.scale * zoom
        if rect.size.width <= 0 || rect.size.height <= 0 {
            return UIImage()
        }
        guard let cgimg = image.cgImage,
            let imageRef = cgimg.cropping(to: rect) else {
                return UIImage()
        }
        let image =  UIImage(cgImage: imageRef, scale: image.scale, orientation: newOrient)
        return image

    
    }
    
}

