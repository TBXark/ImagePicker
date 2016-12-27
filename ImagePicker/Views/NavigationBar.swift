//
//  NavigationBar.swift
//  ImagePicker
//
//  Created by Tbxark on 26/12/2016.
//  Copyright © 2016 Tbxark. All rights reserved.
//

import UIKit

class NavigationBar: UIView {
    
    let cancelButton: UIButton
    let continuteButton: UIButton
    let countLabel: UILabel
    let titleView = TKImagePickerTitleView()
    init() {
        
        let h: CGFloat  = 54
        let w: CGFloat  = UIScreen.main.bounds.width
        cancelButton = {
            let btn = UIButton()
            btn.setImage(UIImage(named: "nav_close_button"), for: .normal)
            btn.imageView?.contentMode = .scaleAspectFill
            return btn
        }()
        continuteButton  = {
            let text = UIButton()
            text.setTitle("继续", for: .normal)
            text.setBackgroundImage(UIImage(named: "btn_bg_enable"), for: .normal)
            text.setBackgroundImage(UIImage(named: "btn_bg_disable"), for: .disabled)
            text.setTitleColor(UIColor.darkGray, for: .normal)
            text.setTitleColor(UIColor.gray, for: .disabled)
            text.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
            text.layer.cornerRadius = 2
            text.clipsToBounds = true
            return text
        }()
        countLabel = {
            let label = UILabel()
            label.isHidden = true
            label.layer.cornerRadius = 10
            label.clipsToBounds = true
            label.backgroundColor = ImagePickerConfig.defaultColor
            label.textColor = UIColor.white
            label.textAlignment = .center
            label.font = UIFont.boldSystemFont(ofSize: 13)
            return label
        }()
        
        super.init(frame: CGRect(x: 0, y: 0, width: w, height: h))
        backgroundColor = UIColor.white
        isUserInteractionEnabled = true
        
        addSubview(cancelButton)
        addSubview(continuteButton)
        addSubview(countLabel)
        addSubview(titleView)
        
        let views: [String: UIView] = ["cancelButton": cancelButton,
                                       "continuteButton": continuteButton,
                                       "countLabel": countLabel,
                                       "titleView": titleView]
        let s = 10 + 60 + 10 + 20 + 10 - 10 - 30
        let cons = makeConstraints(vlfs: ["H:|-10-[cancelButton(==30)]-\(s)-[titleView]-10-[countLabel(==20)]-10-[continuteButton(==60)]-10-|",
                                          "V:|-\((h-30)/2)-[cancelButton(==30)]",
                                          "V:|-\((h-30)/2)-[titleView(==30)]",
                                          "V:|-\((h-20)/2)-[countLabel(==20)]",
                                          "V:|-\((h-30)/2)-[continuteButton(==30)]",
                                          ], views: views)
        addConstraints(cons)
        
        
        let line: UIView = {
            let view = UIView(frame: CGRect(x:8, y: h - 1, width: w - 16, height: 1))
            view.backgroundColor = UIColor(white: 0.96, alpha: 1)
            return view
        }()
        addSubview(line)
        backgroundColor = UIColor.white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setContinuteEnable(_ enable: Bool) {
        continuteButton.isEnabled = enable
    }
    
    func setCount(_ count: Int) {
        countLabel.isHidden = count == 0
        countLabel.text = "\(count)"
    }
    
    func setTitle(_ title: String, state: Bool) {
        titleView.title = title
        titleView.isOpen = state
    }

}
