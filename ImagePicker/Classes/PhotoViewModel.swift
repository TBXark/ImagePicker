//
//  PhotoViewModel.swift
//  ImagePicker
//
//  Created by Tbxark on 26/12/2016.
//  Copyright © 2016 Tbxark. All rights reserved.
//

import UIKit
import Photos

class PhotoViewModel {
    
    
    private(set) var selectPhotos = [PhotoModel]()
    var count: Int { return selectPhotos.count }
    
    
    func select(photo: PhotoModel) {
        selectPhotos.append(photo)
    }
    
    
    func remove(photo: PhotoModel) {
        guard let i = indexOf(photo: photo) else { return }
        selectPhotos.remove(at: i)
    }
    
    
    func indexOf(photo: PhotoModel) -> Int? {
        return selectPhotos.index { (test) -> Bool in
            return test.asset.localIdentifier == photo.asset.localIdentifier
        }
    }
    
    func isSelected(photo: PhotoModel) -> Bool {
        return selectPhotos.contains(where: { (test) -> Bool in
            return test.asset.localIdentifier == photo.asset.localIdentifier
        })
    }
}
