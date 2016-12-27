//
//  ImagePickerViewController.swift
//  ImagePicker
//
//  Created by Tbxark on 26/12/2016.
//  Copyright © 2016 Tbxark. All rights reserved.
//

import UIKit


public class ImagePickerViewController: UIViewController {

    public let config: ImagePickerConfig
    public var completeHandler: ((_ controller: ImagePickerViewController, _ result: [PhotoResult]?) -> Void)?

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
        
    }
}


extension ImagePickerViewController {
    func completeImagePicker(result: [PhotoResult]?) {
        completeHandler?(self, result)
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
        if config.autoComplete {
            if let img = image {
                completeImagePicker(result: [PhotoResult.image(data: img)])
            } else {
                completeImagePicker(result: nil)
            }
            controller.dismiss(animated: false, completion: nil)
        } else if let img = image {
            albumController.viewModel.saveImage(image: img, complete: { (success, error) in
                controller.dismiss(animated: false, completion: nil)
            })
        } else {
            controller.dismiss(animated: false, completion: nil)
        }
    }
    
    internal func photoPickerSelectCamera(_ controller: PhotoViewController) {
        
    }
    
    internal func photoPickerDidSelect(_ controller: PhotoViewController, model: PhotoModel) {
        let finish = config.maxSelect == photoController.viewModel.count
        if config.autoComplete && finish {
            completeImagePicker(result: photoController.viewModel.selectPhotos.map { PhotoResult.model(data: $0)})
        }
        navBar.setCount(photoController.viewModel.count)
        navBar.continuteButton.isEnabled = finish
    }
    
    internal func photoPickerDidDeselect(_ controller: PhotoViewController, model: PhotoModel) {
        let finish = config.maxSelect == photoController.viewModel.count
        navBar.continuteButton.isEnabled = finish
        navBar.setCount(photoController.viewModel.count)
    }

}
