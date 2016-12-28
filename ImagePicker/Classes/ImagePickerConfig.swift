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
    
    
    public struct AblumName {
        public static var all = "全部照片"
        public static var unknow = "未命名"
        public static var app = "Play"
    }

    
    public static var defaultColor = UIColor.darkGray
    public static var numOfRow: Int = 4
    

    
    public var maxSelect = 1
    public var needCamera = true
    public var autoComplete = false
//    public var hug
        
    public init() {}
    public init(max: Int, auto: Bool = false) {
        maxSelect = max
        autoComplete = auto
    }
    
}
