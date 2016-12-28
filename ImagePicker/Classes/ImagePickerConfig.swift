//
//  ImagePickerConfig.swift
//  ImagePicker
//
//  Created by Tbxark on 26/12/2016.
//  Copyright © 2016 Tbxark. All rights reserved.
//

import UIKit

public struct ImagePickerConfig {
    
    public struct HUG {
        public static var show: (()->Void) = {}
        public static var dismiss: (()->Void) = {}
        public static var error: ((Error?)->Void) = { _ in}
    }

    
    public static var defaultColor = UIColor.darkGray
    public static var numOfRow: Int = 4
    
    public var appAblumName = "Play"

    
    public var maxSelect = 1
    public var needCamera = true
    public var autoComplete = false
//    public var hug
        
    public init() {}
    
}
