//
//  AlbumViewController.swift
//  ImagePicker
//
//  Created by Tbxark on 26/12/2016.
//  Copyright © 2016 Tbxark. All rights reserved.
//

import UIKit
import Photos

protocol AlbumViewControllerDelegate: class {
    func albumViewController(_ controller: AlbumViewController, didLoad albums: [AlbumModel])
    func albumViewController(_ controller: AlbumViewController, didSelect album: AlbumModel)
}

class AlbumViewController: UIViewController {

    weak var delegate: AlbumViewControllerDelegate?
    fileprivate lazy var albumList: UITableView = {
        let tableView = UITableView()
        tableView.register(AlbumTableViewCell.self, forCellReuseIdentifier: AlbumTableViewCell.iden)
        tableView.tableFooterView = UIView()
        tableView.rowHeight = AlbumTableViewCell.height
        tableView.dataSource = self
        tableView.delegate   = self
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: -44, right: 0)
        tableView.backgroundColor = UIColor.white
        return tableView
    }()
    let viewModel: AlbumManager
    fileprivate let config: ImagePickerConfig
    
    
    init(config: ImagePickerConfig) {
        self.config = config
        viewModel = AlbumManager(albumName: config.appAblumName)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        shareInit()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}


extension AlbumViewController {
    func shareInit() {
        view.addSubview(albumList)
        albumList.frame = view.bounds
        viewModel.albums.didChange = {[weak self] data in
            self?.reloadData(data: data)
        }
        viewModel.fetchAllAlbum()
    }
    func  reloadData(data: [AlbumModel])  {
        DispatchQueue.main.async {
            self.delegate?.albumViewController(self, didLoad: data)
            self.albumList.reloadData()
        }
    }
}


extension AlbumViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = viewModel.albums.value[indexPath.row]
        delegate?.albumViewController(self, didSelect: model)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.albums.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AlbumTableViewCell.iden, for: indexPath) as! AlbumTableViewCell
        let model = viewModel.albums.value[indexPath.row]
        cell.configureWithDataModel(model)
        return cell
    }
}
