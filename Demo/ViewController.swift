//
//  ViewController.swift
//  Demo
//
//  Created by Tbxark on 27/12/2016.
//  Copyright © 2016 Tbxark. All rights reserved.
//

import UIKit
import ImagePicker

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let vc = ImagePickerViewController.init(config: ImagePickerConfig())
        present(vc, animated: true, completion: nil)
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

