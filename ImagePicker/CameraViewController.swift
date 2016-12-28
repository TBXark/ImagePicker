//
//  CameraViewController.swift
//  ImagePicker
//
//  Created by Tbxark on 26/12/2016.
//  Copyright © 2016 Tbxark. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

protocol CameraViewControllerDelegate: class {
    func cameraViewController(_ controller: CameraViewController, capture image: UIImage?)
}


class CameraViewController: UIViewController {
    
    weak var delegate: CameraViewControllerDelegate?
    
    fileprivate let cameraView = CameraView()
    fileprivate let cameraButton = UIButton()
    fileprivate let closeButton = UIButton()
    fileprivate let swapButton = UIButton()
    fileprivate let flashButton = UIButton()
    

    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    override var preferredStatusBarUpdateAnimation : UIStatusBarAnimation {
        return UIStatusBarAnimation.slide
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        shareInit()
        view.backgroundColor = UIColor.black
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkPermissions()
    }
    
    fileprivate func checkPermissions() {
        if AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) == AVAuthorizationStatus.authorized {
            startCamera()
        } else {
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo) { granted in
                DispatchQueue.main.async {
                    if granted == true {
                        self.startCamera()
                    } else {
                        UIAlertView.init(title: "没有权限",
                                         message: "没有访问相机权限\n 请前往 设置 打开权限",
                                         delegate: nil,
                                         cancelButtonTitle: nil).show()
                    }
                }
            }
        }
    }
    fileprivate func startCamera() {
        cameraView.startSession()
    }
    
}


extension CameraViewController {
    func shareInit() {
    
        
        
        cameraView.frame = view.bounds
        cameraView.frame.origin.y = NavigationBar.height
        
        let navBar = UIView()
        let toolBar = UIView()
        
        cameraButton.addTarget(self, action: #selector(CameraViewController.capturePhoto), for: .touchUpInside)
        swapButton.addTarget(self, action: #selector(CameraViewController.swapCamera), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(CameraViewController.close), for: .touchUpInside)
        flashButton.addTarget(self, action: #selector(CameraViewController.toggleFlash), for: .touchUpInside)
        
        cameraButton.setImage(UIImage.ip_imageWithName("camera_capture_btn"), for: .normal)
        closeButton.setImage(UIImage.ip_imageWithName("ip_nav_close_button"),for: .normal)
        swapButton.setImage(UIImage.ip_imageWithName("camera_swap_btn"), for: .normal)
        flashButton.setImage(UIImage.ip_imageWithName("flash_off_btn"),for: .normal)
        
        navBar.backgroundColor = UIColor.white
        navBar.isUserInteractionEnabled = true
        toolBar.backgroundColor = UIColor.white
        toolBar.isUserInteractionEnabled = true
        
        
        view.addSubview(cameraView)
        view.addSubview(navBar)
        view.addSubview(toolBar)

        navBar.addSubview(closeButton)
        toolBar.addSubview(cameraButton)
        toolBar.addSubview(swapButton)
        toolBar.addSubview(flashButton)
        
        cameraButton.isEnabled = true
        flashButton.isEnabled = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)?.hasTorch ?? false
        
        let td = ["tool": toolBar, "swap": swapButton, "camera": cameraView, "flash": flashButton]
        let nd = ["nav": navBar, "close": closeButton]
        
        let nl = ["H:|-0-[nav]-0-|",
                  "V:|-0-[nav(==\(NavigationBar.height))]",
            "H:|-20-[close(==20)]",
            "V:|-\((NavigationBar.height - 20)/2)-[close(==20)]"]
        
        
        let size: CGFloat = 100
        let btns: CGFloat = 30
        let space = (UIScreen.main.bounds.width - size - btns * 2) / 4.0
        let tl = ["H:|-\(space)-[swap==(\(btns))]-\(space)-[camera==(\(size))]-\(space)-[flash==(\(btns))]-\(space)-|"]
        
        view.addConstraints(view.makeConstraints(vlfs: nl, views: nd))
        view.addConstraints(view.makeConstraints(vlfs: tl, views: td))
        
        for v in [swapButton, cameraView, flashButton] {
            toolBar.addConstraint(NSLayoutConstraint(item: v,
                                                     attribute: NSLayoutAttribute.centerY,
                                                     relatedBy: NSLayoutRelation.equal,
                                                     toItem: toolBar,
                                                     attribute: NSLayoutAttribute.centerY,
                                                     multiplier: 1.0, constant: 0.0));
            
        }

    }
}


extension CameraViewController {
    func capturePhoto() {
        cameraButton.isEnabled = false
        cameraView.capturePhoto { image in
            self.saveCameraResult(image)
        }
    }
    
    func close() {
        cameraView.stopSession()
        cameraButton.isEnabled = true
        dismiss(animated: true, completion: nil)
    }
    
    func toggleFlash() {
        guard let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo) else { return }
        if (device.hasTorch) {
            do {
                try device.lockForConfiguration()
                switch device.torchMode {
                case .off:
                    device.torchMode = .auto
                    flashButton.setImage(UIImage.ip_imageWithName("flash_auto_btn"),for: .normal)
                case .auto:
                    device.torchMode = .on
                    flashButton.setImage(UIImage.ip_imageWithName("flash_on_btn"),for: .normal)
                case .on:
                    device.torchMode = .off
                    flashButton.setImage(UIImage.ip_imageWithName("flash_off_btn"), for: .normal)
                }
                device.unlockForConfiguration()
            } catch {
            }
        }
    }
    
    
    func swapCamera() {
        cameraView.swapCameraInput()
        flashButton.isHidden = cameraView.currentPosition == AVCaptureDevicePosition.front
    }
    func saveCameraResult(_ image: UIImage) {
        self.cameraView.pauseSession()
        ImagePickerConfig.HUG.show()
        DispatchQueue.global().async { () -> Void in
            let w = image.size.width
            let rect = CGRect(x: 0, y: 0, width: w, height: w)
            let cropImg = CameraView.crop(image: image, zoom: 1, cropRect: rect)
            self.delegate?.cameraViewController(self, capture: cropImg)
        }
    }
    
}
