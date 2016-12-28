//
//  UIImage+ImagePicker.swift
//  ImagePicker
//
//  Created by Tbxark on 28/12/2016.
//  Copyright © 2016 Tbxark. All rights reserved.
//

import UIKit


private let ImagePickerBundle: Bundle? = {
    guard let path = Bundle(for: ImagePickerViewController.self).path(forResource: "Image", ofType: "bundle"),
        let bundle = Bundle(path: path) else { return nil }
    return bundle
}()

extension UIImage {
    static func ip_imageWithName(_ name: String) -> UIImage? {
        return UIImage(named: name, in: ImagePickerBundle, compatibleWith: nil)
    }

}
