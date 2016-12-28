//
//  AlbumManager.swift
//  ImagePicker
//
//  Created by Tbxark on 26/12/2016.
//  Copyright © 2016 Tbxark. All rights reserved.
//

import UIKit
import Photos

public class AlbumManager {
    
    public static var customAssetCollection: PHAssetCollection? {
        get {
            if let c = _customAssetCollection { return c }
            createDefaultAlbumIfNeed(complete: { _ in })
            return nil
        }
    }
    private static var _customAssetCollection: PHAssetCollection?

    private let ablumQueue = DispatchQueue(label: "com.imagepicker", attributes: .concurrent)
    private var appAblumIndex: Int?
    var albums = Value<[AlbumModel]>([])
    var custom = Value<PHAssetCollection?>(nil)
    

    
    func fetchAllAlbum(complete handle: ((_ result: [AlbumModel]) -> Void)? = nil){
        PHPhotoLibrary.requestAuthorization { authorizationStatus in
            guard authorizationStatus == .authorized else {
                handle?([])
                return
            }
            var albumsTemp = [AlbumModel]()
            let allPhotosOptions = PHFetchOptions()
            allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
            
            let allPhotos: PHFetchResult<PHAsset> = PHAsset.fetchAssets(with: allPhotosOptions)
            let smartCollection: PHFetchResult<PHAssetCollection> = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil)
            let userCollection: PHFetchResult<PHCollection> = PHCollectionList.fetchTopLevelUserCollections(with: nil)
            
            
            
            let allPhotoModel = AlbumModel(title: ImagePickerConfig.AblumName.all, type: .allPhoto, count: allPhotos.count, fetchResult: allPhotos)
            albumsTemp.append(allPhotoModel)
            
            
            for i in 0..<smartCollection.count {
                let coll = smartCollection[i]
                let asset = PHAsset.fetchAssets(in: coll, options: nil)
                if asset.count > 0 {
                    let model = AlbumModel(title: coll.localizedTitle ?? ImagePickerConfig.AblumName.unknow,
                                           type: .common,
                                           count: asset.count,
                                           fetchResult: asset)
                    albumsTemp.append(model)
                }
            }
            
            for i in 0..<userCollection.count {
                guard let list = userCollection[i] as? PHAssetCollection else {
                    continue
                }
                let asset = PHAsset.fetchAssets(in: list, options: nil)
                let isCustom = list.localizedTitle != nil ? list.localizedTitle! == ImagePickerConfig.AblumName.app : false
                let model = AlbumModel(title: list.localizedTitle ?? "Unknow", type: (isCustom ? .default : .common), count: asset.count, fetchResult: asset)
                albumsTemp.append(model)
                if isCustom {
                    self.appAblumIndex = albumsTemp.count - 1
                    self.custom.value = list
                }
            }
            self.albums.value = albumsTemp
            handle?(albumsTemp)
        }
    }
    
    
    func refreshAblumArray() {
        ablumQueue.async { () -> Void in
            var origin = self.albums.value
            let allPhotosOptions = PHFetchOptions()
            allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
            let allPhotos: PHFetchResult = PHAsset.fetchAssets(with: allPhotosOptions)
            let allPhotoModel = AlbumModel(title: ImagePickerConfig.AblumName.all, type: .allPhoto, count: allPhotos.count, fetchResult: allPhotos)
            origin[0] = allPhotoModel
            
            guard let defaultAlbum = self.custom.value, let index = self.appAblumIndex else {
                self.albums.value = origin
                return
            }
            let asset = PHAsset.fetchAssets(in: defaultAlbum, options: nil)
            let model = AlbumModel(title: ImagePickerConfig.AblumName.app, type:  .default, count: asset.count, fetchResult: asset)
            if origin.count > index && origin[index].title == model.title {
                origin[index] = model
            }
            self.albums.value = origin
        }
    }
    
    
    public static func createDefaultAlbumIfNeed(complete handle: @escaping (_ success: Bool) -> Void) {
        let name = ImagePickerConfig.AblumName.app
        PHPhotoLibrary.requestAuthorization { (authorizationStatus) in
            guard authorizationStatus == .authorized else {
                handle(false)
                return
            }
            let userCollection = PHCollectionList.fetchTopLevelUserCollections(with: nil)
            let count = userCollection.count
            userCollection.enumerateObjects({ (list: PHCollection, index: Int, stop: UnsafeMutablePointer<ObjCBool>) in
                if let list = list as? PHAssetCollection  {
                    if list.localizedTitle == name {
                        _customAssetCollection = list
                    }
                    if index == (count-1) {
                        if _customAssetCollection == nil {
                            PHPhotoLibrary.shared().performChanges({
                                PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: name)
                            }, completionHandler: { (success: Bool, error: Error?) in
                               handle(success)
                            })
                        } else {
                            handle(false)
                        }
                    }
                }
            })
        }
    }
    
    
     public static func saveImage(image: UIImage, complete: ((Bool, Error?) -> Swift.Void)? = nil) {
        PHPhotoLibrary.shared().performChanges({ () -> Void in
            let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            guard let asset = assetChangeRequest.placeholderForCreatedAsset else {return}
            let assets = NSMutableArray()
            assets.add(asset)
            guard let collection = customAssetCollection else {
                complete?(false, nil)
                return
            }
            guard let assetCollectionChangeRequest = PHAssetCollectionChangeRequest(for: collection) else {
                complete?(false, nil)
                return
            }
            assetCollectionChangeRequest.addAssets(assets)
        }, completionHandler: complete)
    
    }
    
}
