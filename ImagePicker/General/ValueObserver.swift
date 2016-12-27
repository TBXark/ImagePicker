//
//  ValueObserver.swift
//  ImagePicker
//
//  Created by Tbxark on 26/12/2016.
//  Copyright © 2016 Tbxark. All rights reserved.
//

import UIKit

class Value<T> {
    var didChange: ((T) -> Void)?
    var value: T {
        didSet {
            didChange?(value)
        }
    }
    init(_ value: T) {
        self.value = value
    }
}
