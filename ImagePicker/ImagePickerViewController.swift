//
//  ImagePickerViewController.swift
//  ImagePicker
//
//  Created by Tbxark on 26/12/2016.
//  Copyright © 2016 Tbxark. All rights reserved.
//

import UIKit
import Photos


public protocol ImagePickerViewControllerDelegate: class {
    func imagePickerViewController(_ controller: ImagePickerViewController, cancleSelect: Void)
    // 选中图片
    func imagePickerViewController(_ controller: ImagePickerViewController, didSelect photo: PhotoModel)
    // 取消选中图片
    func imagePickerViewController(_ controller: ImagePickerViewController, didDeselect photo: PhotoModel)
    // 最终选择图片
    func imagePickerViewController(_ controller: ImagePickerViewController, commitSelect  image: UIImage)
    // 最终选择图片
    func imagePickerViewController(_ controller: ImagePickerViewController, commitSelect photos: [PhotoModel])
}

extension ImagePickerViewControllerDelegate {
    public func imagePickerViewController(_ controller: ImagePickerViewController, cancleSelect: Void) {}
    public func imagePickerViewController(_ controller: ImagePickerViewController, didSelect photo: PhotoModel) {}
    public func imagePickerViewController(_ controller: ImagePickerViewController, didDeselect photo: PhotoModel) {}
    public func imagePickerViewController(_ controller: ImagePickerViewController, commitSelect capture: UIImage) {}
    public func imagePickerViewController(_ controller: ImagePickerViewController, commitSelect photos: [PhotoModel]) {}

}


public class ImagePickerViewController: UIViewController {

    public let config: ImagePickerConfig
    public weak var delegate: ImagePickerViewControllerDelegate?
    
    let navBar = NavigationBar()
    let albumController: AlbumViewController
    let photoController: PhotoViewController
    
    
    
    public init(config: ImagePickerConfig) {
        self.config = config
        self.albumController = AlbumViewController(config: config)
        self.photoController = PhotoViewController(config: config)
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        shareInit()
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
        
    override public var prefersStatusBarHidden : Bool {
        return true
    }
}


extension ImagePickerViewController {
    func shareInit() {
        
        navBar.titleView.stateChange = changeAlbumControllerState
        var rect = view.bounds
        rect.size.height -= navBar.frame.height
        rect.origin.y = navBar.frame.height
        photoController.view.frame = rect
        rect.origin.y = -rect.size.height
        albumController.view.frame = rect
        view.addSubview(photoController.view)
        view.addSubview(albumController.view)
        view.addSubview(navBar)
        
        albumController.delegate = self
        photoController.delegate = self
        
        navBar.cancelButton.addTarget(self, action: #selector(ImagePickerViewController.cancleButtonClick(_:)), for: .touchUpInside)
        navBar.continuteButton.addTarget(self, action: #selector(ImagePickerViewController.continuteButtonClick(_:)), for: .touchUpInside)

        
    }
}


extension ImagePickerViewController {
    
    func cancleButtonClick( _ btn: UIButton) {
        delegate?.imagePickerViewController(self, cancleSelect: ())
    }
    
    func continuteButtonClick(_ btn:UIButton) {
        delegate?.imagePickerViewController(self, commitSelect: photoController.viewModel.selectPhotos)
    }
    
    
    func changeAlbumControllerState(_ show: Bool) {
        if show {
            var rect = view.bounds
            rect.size.height -= navBar.frame.height
            rect.origin.y = navBar.frame.height
            UIView.animate(withDuration: 0.2, animations: { 
                self.albumController.view.frame = rect
            })
        } else {
            var rect = view.bounds
            rect.size.height -= navBar.frame.height
            rect.origin.y = -rect.size.height
            UIView.animate(withDuration: 0.2, animations: {
                self.albumController.view.frame = rect
            })
        }
    }


}


extension ImagePickerViewController:  AlbumViewControllerDelegate, PhotoViewControllerDelegate, CameraViewControllerDelegate {
    internal func albumViewController(_ controller: AlbumViewController, didSelect album: AlbumModel) {
        photoController.albumDataModel = album.fetchResult
        navBar.setTitle(album.title, state: false)
        changeAlbumControllerState(false)
    }
    
    internal func albumViewController(_ controller: AlbumViewController, didLoad albums: [AlbumModel]) {
        guard let data = albums.first else {return}
        photoController.albumDataModel = data.fetchResult
        navBar.setTitle(data.title, state: false)
    }
    
    internal func cameraViewController(_ controller: CameraViewController, capture image: UIImage?) {
        if let img = image {
            // 保存后调用回调函数
            ImagePickerConfig.HUG.show()
            albumController.viewModel.saveImage(image: img, complete: {[weak self] (isSuccess, error) in
                guard let `self` = self else { return }
                if isSuccess {
                    ImagePickerConfig.HUG.dismiss()
                } else {
                    ImagePickerConfig.HUG.error(error)
                }
                self.delegate?.imagePickerViewController(self, commitSelect: img)
                controller.dismiss(animated: true , completion: nil)
            })
        } else {
            ImagePickerConfig.HUG.error(nil)
            controller.dismiss(animated: false, completion: nil)
        }
        
    }
    
    internal func photoPickerSelectCamera(_ controller: PhotoViewController) {
        // TODO: 跳转相机界面
        let camera = CameraViewController()
        camera.delegate = self
        present(camera, animated: true, completion: nil)
    }
    
    internal func photoPickerDidSelect(_ controller: PhotoViewController, model: PhotoModel) {
        navBar.setCount(photoController.viewModel.count)
        navBar.continuteButton.isEnabled = photoController.viewModel.count > 0
        delegate?.imagePickerViewController(self, didSelect: model)
    }
    
    internal func photoPickerDidDeselect(_ controller: PhotoViewController, model: PhotoModel) {
        let finish = config.maxSelect == photoController.viewModel.count
        navBar.continuteButton.isEnabled = photoController.viewModel.count > 0
        navBar.setCount(photoController.viewModel.count)
        delegate?.imagePickerViewController(self, didDeselect: model)
    }

}
