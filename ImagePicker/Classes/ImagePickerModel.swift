//
//  ImagePickerModel.swift
//  ImagePicker
//
//  Created by Tbxark on 26/12/2016.
//  Copyright © 2016 Tbxark. All rights reserved.
//

import UIKit
import Photos

public enum AlbumType {
    case allPhoto
    case common
    case `default`
}
public struct AlbumModel {
    public var title: String
    public var type: AlbumType
    public var count: Int
    public var fetchResult: PHFetchResult<PHAsset>
}


public struct PhotoModel {
    var select = false
    public let asset: PHAsset
    init(_ asset: PHAsset) {
        self.asset = asset
    }    
}
