//
//  AlbumManager.swift
//  ImagePicker
//
//  Created by Tbxark on 26/12/2016.
//  Copyright © 2016 Tbxark. All rights reserved.
//

import UIKit
import Photos

class AlbumManager {
    var albums = Value<[AlbumModel]>([])
    var custom = Value<AlbumModel?>(nil)
    var customAssetCollection = Value<PHAssetCollection?>(nil)
    private let albumName: String?
    private let ablumQueue = DispatchQueue(label: "com.playalot.play.ablum", attributes: .concurrent)
    
    init(albumName: String?) {
        self.albumName = albumName
    }
    
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
            
            
            
            let allPhotoModel = AlbumModel(title: "All Photo", type: .allPhoto, count: allPhotos.count, fetchResult: allPhotos)
            albumsTemp.append(allPhotoModel)
            
            
            for i in 0..<smartCollection.count {
                let coll = smartCollection[i]
                let asset = PHAsset.fetchAssets(in: coll, options: nil)
                if asset.count > 0 {
                    let model = AlbumModel(title: coll.localizedTitle ?? "Unknow", type: .common, count: asset.count, fetchResult: asset)
                    albumsTemp.append(model)
                }
            }
            
            for i in 0..<userCollection.count {
                guard let list = userCollection[i] as? PHAssetCollection else {
                    continue
                }
                let asset = PHAsset.fetchAssets(in: list, options: nil)
                let isCustom =  self.albumName != nil  && list.localizedTitle != nil ? list.localizedTitle! == self.albumName! : false
                let model = AlbumModel(title: list.localizedTitle ?? "Unknow", type: (isCustom ? .default : .common), count: asset.count, fetchResult: asset)
                albumsTemp.append(model)
                if isCustom {
                    self.custom.value = model
                }
            }
            self.albums.value = albumsTemp
            handle?(albumsTemp)
        }
    }
    
    
    func createDefaultAlbumIfNeed(complete handle: @escaping (_ success: Bool) -> Void) {
        guard let name = albumName else { return }
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
                        self.customAssetCollection.value = list
                    }
                    if index == (count-1) {
                        if self.customAssetCollection.value == nil {
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
    
    
    func saveImage(image: UIImage, complete: ((Bool, Error?) -> Swift.Void)? = nil) {
        PHPhotoLibrary.shared().performChanges({ () -> Void in
            let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            guard let asset = assetChangeRequest.placeholderForCreatedAsset else {return}
            let assets = NSMutableArray()
            assets.add(asset)
            guard let collection = self.customAssetCollection.value else {
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
