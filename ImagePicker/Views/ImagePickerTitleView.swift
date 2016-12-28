//
//  ImagePickerTitleView.swift
//  ImagePicker
//
//  Created by Tbxark on 26/12/2016.
//  Copyright © 2016 Tbxark. All rights reserved.
//

import UIKit


typealias TKTitleViewStateChange = (Bool) -> Void

class TKImagePickerTitleView: UIView {
    var title: String = "" {
        didSet {
            textLable.text = title
        }
    }
    var isOpen = false {
        didSet {
            stateImage.transform = isOpen ? CGAffineTransform.identity.rotated(by: CGFloat(M_PI)) : CGAffineTransform.identity
            
        }
    }
    var stateChange: TKTitleViewStateChange?
    
    fileprivate var textLable = UILabel()
    fileprivate var stateImage = UIImageView()
    
    
    init() {
        super.init(frame: CGRect.zero)
        shareInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        shareInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        shareInit()
    }
    
    
    
    
    func shareInit() {
        isUserInteractionEnabled = true
        addSubview(textLable)
        addSubview(stateImage)
        
        stateImage.contentMode = .scaleAspectFit
        stateImage.image = UIImage(named: "ip_select_album")
        
        textLable.textColor = UIColor.darkGray
        textLable.textAlignment = .center
        textLable.font = UIFont.systemFont(ofSize: 16)
        
        let cons = makeConstraints(vlfs: ["H:|-0-[img]-0-|",
                               "H:|-0-[txt]-0-|",
                               "V:|-0-[txt]-0-[img(==6)]-0-|"], views: ["img": stateImage, "txt": textLable])
        
        addConstraints(cons)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(TKImagePickerTitleView.stateChange(_:)))
        addGestureRecognizer(tap)
    }
    
    func stateChange(_ tap: UITapGestureRecognizer) {
        isOpen = !isOpen
        stateChange?(isOpen)
    }
    
}
