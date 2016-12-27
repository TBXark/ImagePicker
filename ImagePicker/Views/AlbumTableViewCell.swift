//
//  AlbumTableViewCell.swift
//  ImagePicker
//
//  Created by Tbxark on 26/12/2016.
//  Copyright © 2016 Tbxark. All rights reserved.
//

import UIKit
import Photos

class AlbumTableViewCell: UITableViewCell {
    
    static let iden = "AlbumTableViewCell"
    static let height: CGFloat = 100
    fileprivate let albumCover = UIImageView()
    fileprivate let albumName  = UILabel()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        shareInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    func shareInit() {
        selectionStyle = .none
        albumCover.contentMode = .scaleAspectFill
        albumCover.clipsToBounds = true
        albumCover.backgroundColor = UIColor(white: 0.9, alpha: 1)
        
        albumName.font = UIFont.boldSystemFont(ofSize: 16)
        albumName.textColor = UIColor.darkGray
        
        
        contentView.addSubview(albumName)
        contentView.addSubview(albumCover)
        
        let cons = contentView.makeConstraints(vlfs: ["H:|-14-[img(==\(AlbumTableViewCell.height - 14 * 2))]-14-[txt]-14-|",
                                           "V:|-14-[img]-14-|",
                                           "V:|-14-[txt]-14-|"], views: ["img": albumCover, "txt": albumName])
        contentView.addConstraints(cons)
    }
    
    
    func configureWithDataModel(_ dataModel: AlbumModel) {
        guard let asset = dataModel.fetchResult.lastObject else {
            albumCover.image = nil
            albumName.text = ""
            return }
        PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: AlbumTableViewCell.height, height: AlbumTableViewCell.height), contentMode: .aspectFit, options: nil) { (image, _: [AnyHashable: Any]?) -> Void in
           self.albumCover.image = image
        }
        
        let title = NSString(format: "\(dataModel.title)(\(dataModel.count))" as NSString)
        let attr  = NSMutableAttributedString(string: title as String, attributes: [NSFontAttributeName:UIFont.boldSystemFont(ofSize: 18), NSForegroundColorAttributeName:UIColor.black])
        let range = title.range(of: "(\(dataModel.count))")
        attr.addAttributes([NSFontAttributeName:UIFont.systemFont(ofSize: 18)], range: range)
        albumName.attributedText = attr

    }
}
