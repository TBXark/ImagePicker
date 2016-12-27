//
//  PhotoViewController.swift
//  ImagePicker
//
//  Created by Tbxark on 26/12/2016.
//  Copyright © 2016 Tbxark. All rights reserved.
//

import UIKit
import Photos

protocol PhotoViewControllerDelegate: class {
    func photoPickerSelectCamera(_ controller: PhotoViewController)
    func photoPickerDidSelect(_ controller: PhotoViewController, model: PhotoModel)
    func photoPickerDidDeselect(_ controller: PhotoViewController, model: PhotoModel)
}


class PhotoViewController: UIViewController {
    
    fileprivate(set) lazy var imageList: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = PhotoCollectionViewCell.size
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 1
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.register(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: PhotoCollectionViewCell.iden)
        collectionView.dataSource = self
        collectionView.delegate   = self
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: -44, right: 0)
        collectionView.backgroundColor = UIColor.white
        collectionView.allowsSelection = true
        collectionView.allowsMultipleSelection = true
        return collectionView
    }()
    
    fileprivate let imgRequestOption: PHImageRequestOptions = {
        let op = PHImageRequestOptions()
        op.resizeMode = .fast
        op.isNetworkAccessAllowed = true
        return op
    }()
    
    
    
    // Data
    var albumDataModel: PHFetchResult<PHAsset>? {
        didSet {
            // 读取相册照片信息
            guard let albums = albumDataModel, albums.count > 0 else { return }
            var temp = [PhotoModel]()
            for i in 0..<albums.count {
                let asset = albums[i]
                if asset.mediaType == .image {
                    var assetModel = PhotoModel(asset)
                    assetModel.select = viewModel.isSelected(photo: assetModel)
                    temp.append(assetModel)
                } //去除非图片内容
            }
            temp.sort { (first, second) -> Bool in
                let fd: Date? = first.asset.modificationDate ?? first.asset.creationDate
                let sd: Date? = second.asset.modificationDate ?? second.asset.creationDate
                guard let fdd = fd, let sdd = sd else { return false }
                return fdd.timeIntervalSince1970 - sdd.timeIntervalSince1970 > 0
            }
            allPhotos = temp
        }
    }
    var allPhotos = [PhotoModel]() {
        didSet {
            imageList.reloadData()
            allPhotos.enumerated().flatMap { (offset: Int, element: PhotoModel) -> IndexPath? in
                guard element.select else { return nil }
                return  needCamera ? IndexPath(row: offset + 1, section: 0) :  IndexPath(row: offset, section: 0)
            }.forEach { (idx) in
                imageList.selectItem(at: idx, animated: false, scrollPosition: [])
            }
            
            updateCachedAssets()
        }
    }
    let viewModel = PhotoViewModel()

    fileprivate lazy var imageManager = PHCachingImageManager()
    fileprivate var previousPreheatRect = CGRect.zero
    fileprivate var needCamera: Bool = true
    fileprivate var maxSelectCount: Int
    weak var delegate: PhotoViewControllerDelegate?
    
    
    init(config: ImagePickerConfig) {
        maxSelectCount = config.maxSelect
        needCamera = config.needCamera
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        shareInit()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateCachedAssets()
    }
    
    deinit {
        resetCachedAssets()
    }
}

extension PhotoViewController {
    func shareInit() {
        view.addSubview(imageList)
        imageList.frame = view.bounds
    }
}


extension PhotoViewController: UICollectionViewDelegateFlowLayout {
    
    
    func didSelectedState(index: IndexPath, mode: Bool? = nil) {
        let row = index.row
        if needCamera && row == 0 {
            delegate?.photoPickerSelectCamera(self)
            return
        }
        let i = needCamera ? row - 1 : row
        var model = allPhotos[i]
        let select = mode ?? !model.select
        if select && viewModel.selectPhotos.count >= maxSelectCount {  return }
        if  select {
            let cell = imageList.cellForItem(at: IndexPath(row: row, section: 0)) as! PhotoCollectionViewCell
            model.select = true
            allPhotos[i] = model
            viewModel.select(photo: model)
            cell.changeState(select: true, index: allPhotos.count)
            delegate?.photoPickerDidSelect(self, model: model)
        } else {
            model.select = false
            allPhotos[i] = model
            viewModel.remove(photo: model)
            let array = imageList.indexPathsForSelectedItems
            guard var selectIndexs = array else {return}
            let origin = selectIndexs
            selectIndexs.append(index)
            imageList.reloadItems(at: selectIndexs)
            for index in origin {
                imageList.selectItem(at: index, animated: false, scrollPosition: UICollectionViewScrollPosition())
            }
            delegate?.photoPickerDidDeselect(self, model: model)
        }

    
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateCachedAssets()
    }
    
    // 选择图片
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        didSelectedState(index: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        didSelectedState(index: indexPath, mode: false)
    }
}

extension PhotoViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allPhotos.count + (needCamera ? 1 : 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionViewCell.iden, for: indexPath) as! PhotoCollectionViewCell
        let row = indexPath.row
        if row == 0 && needCamera {
            cell.configureWithCameraMode()
        } else {
            let idx = needCamera ? row - 1 : row
            let model = allPhotos[idx]
            cell.configureWithDataModel(model)
            if let i = viewModel.indexOf(photo: model) {
                cell.changeState(select: true, index: i)
            } else {
                cell.changeState(select: false, index: nil)
            }
            cell.setImage(nil)
            let scale = UIScreen.main.scale
            let size =  CGSize(width: PhotoCollectionViewCell.size.width * scale, height: PhotoCollectionViewCell.size.height * scale)
            imageManager.requestImage(for: model.asset, targetSize: size, contentMode: .aspectFill, options: imgRequestOption) {
                (image, info :[AnyHashable: Any]?) -> Void in
                guard let img = image else { return }
                if cell.assetIdentifier == model.asset.localIdentifier {
                    cell.setImage(img)
                }
            }
        }
        return cell
    }
}


// MARK: - Image Cache Manager
extension PhotoViewController {
    fileprivate func resetCachedAssets() {
        imageManager.stopCachingImagesForAllAssets()
        previousPreheatRect = CGRect.zero
    }
    
    fileprivate func updateCachedAssets() {
        func computeDifferenceBetweenRect(_ oldRect: CGRect, andRect newRect: CGRect, removedHandler: (CGRect) -> Void, addedHandler: (CGRect) -> Void) {
            if (newRect.intersects(oldRect)) {
                let oldMaxY = oldRect.maxY
                let oldMinY = oldRect.minY
                let newMaxY = newRect.maxY
                let newMinY = newRect.minY
                if newMaxY > oldMaxY {
                    let rectToAdd = CGRect(x: newRect.origin.x, y: oldMaxY, width: newRect.size.width, height: (newMaxY - oldMaxY))
                    addedHandler(rectToAdd)
                }
                if oldMinY > newMinY {
                    let rectToAdd = CGRect(x: newRect.origin.x, y: newMinY, width: newRect.size.width, height: (oldMinY - newMinY))
                    addedHandler(rectToAdd)
                }
                if newMaxY < oldMaxY {
                    let rectToRemove = CGRect(x: newRect.origin.x, y: newMaxY, width: newRect.size.width, height: (oldMaxY - newMaxY))
                    removedHandler(rectToRemove)
                }
                if oldMinY < newMinY {
                    let rectToRemove = CGRect(x: newRect.origin.x, y: oldMinY, width: newRect.size.width, height: (newMinY - oldMinY))
                    removedHandler(rectToRemove)
                }
            } else {
                addedHandler(newRect)
                removedHandler(oldRect)
            }
        }

       
        guard isViewLoaded && view.window != nil else { return }
        var preheatRect: CGRect = imageList.bounds
        preheatRect = preheatRect.insetBy(dx: 0.0, dy: -0.5 * preheatRect.height)
        let delta: CGFloat = abs(preheatRect.midY-previousPreheatRect.midY)
        
        
        if delta > imageList.bounds.height / 3 {
            var addedIndexPaths = [IndexPath]()
            var removedIndexPaths = [IndexPath]()
            
            computeDifferenceBetweenRect(previousPreheatRect, andRect:preheatRect, removedHandler: { (removedRect: CGRect) in
                let indexPaths = self.imageList.ip_indexPathsForElementsInRect(removedRect)
                removedIndexPaths.append(contentsOf: indexPaths)
                
            }, addedHandler: { (addedRect: CGRect) in
                let indexPaths = self.imageList.ip_indexPathsForElementsInRect(addedRect)
                addedIndexPaths.append(contentsOf: indexPaths)
            })
            
            func assetsAtIndexPaths(_ indexPaths: [IndexPath]) -> [PHAsset] {
                if indexPaths.count == 0 { return [] }
                var assets = [PHAsset]()
                for index in indexPaths {
                    if (index as NSIndexPath).row == 0 { continue }
                    if let asset = albumDataModel?[(index as NSIndexPath).row - 1] {
                        assets.append(asset)
                    }
                }
                return assets
            }
            
            let assetsToStartCaching = assetsAtIndexPaths(addedIndexPaths)
            let assetsToStopCaching = assetsAtIndexPaths(removedIndexPaths)
            
            let scale = UIScreen.main.scale
            let size =  CGSize(width: PhotoCollectionViewCell.size.width * scale, height: PhotoCollectionViewCell.size.height * scale)
            imageManager.startCachingImages(for: assetsToStartCaching,
                                            targetSize: size,
                                            contentMode: .aspectFill,
                                            options: imgRequestOption)
            
            imageManager.stopCachingImages(for: assetsToStopCaching,
                                           targetSize: size,
                                           contentMode: .aspectFill,
                                           options: imgRequestOption)
            
            previousPreheatRect = preheatRect
            
        }
    }
}


extension UICollectionView {
    func ip_indexPathsForElementsInRect(_ rect: CGRect) -> [IndexPath] {
        guard  let allLayoutAttributes = collectionViewLayout.layoutAttributesForElements(in: rect) else {
            return []
        }
        if allLayoutAttributes.count == 0 { return [] }
        var ips = [IndexPath]()
        for attr in allLayoutAttributes {
            ips.append(attr.indexPath)
        }
        return ips
    }
}

