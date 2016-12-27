//
//  CameraViewController.swift
//  ImagePicker
//
//  Created by Tbxark on 26/12/2016.
//  Copyright © 2016 Tbxark. All rights reserved.
//

import UIKit


protocol CameraViewControllerDelegate: class {
    func cameraViewController(_ controller: CameraViewController, capture image: UIImage?)
}

class CameraViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }


}
