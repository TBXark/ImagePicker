//
//  VLFMaker.swift
//  ImagePicker
//
//  Created by Tbxark on 26/12/2016.
//  Copyright © 2016 Tbxark. All rights reserved.
//

import UIKit



extension UIView {
    func makeConstraints(vlfs: [String], views: [String: UIView]) -> [NSLayoutConstraint] {
        var temp = [NSLayoutConstraint]()
        for vlf in vlfs {
            let res = NSLayoutConstraint.constraints(withVisualFormat: vlf,
                                                     options: NSLayoutFormatOptions(rawValue: 0),
                                                     metrics: nil,
                                                     views: views)
            temp.append(contentsOf: res)
        }
        views.values.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        return temp
    }
    
    
}
