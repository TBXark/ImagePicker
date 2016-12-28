//
//  ImagePickerConfig.swift
//  ImagePicker
//
//  Created by Tbxark on 26/12/2016.
//  Copyright © 2016 Tbxark. All rights reserved.
//

import UIKit

public struct ImagePickerConfig {
    
    struct HUG {
        static var show: (()->Void) = {}
        static var dismiss: (()->Void) = {}
        static var error: ((Error?)->Void) = { _ in}
    }

    
    public static var defaultColor = UIColor.darkGray
    public static var numOfRow = (phone: 4, pad: 6)

    public var appAblumName = "ImagePicker"

    
    public var maxSelect = 1
    public var needCamera = true
    public var autoComplete = false
//    public var hug
        
    public init() {}
    
}
