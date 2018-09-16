//
//  NewsFeedDataSource.swift
//  BBCNewsFeed
//
//  Created by Rodrigo Vianna on 24/07/18.
//  Copyright © 2018 Rodrigo Vianna. All rights reserved.
//

import UIKit

protocol NewsFeedDelegate {
    func newsFeedDataSource(_ newsFeedDataSource: NewsFeedDataSource, selectedItem: NewsFeed)
}

class NewsFeedDataSource: NSObject, UITableViewDelegate, UITableViewDataSource {
    weak var tableView: UITableView?
    
    var newsFeed = [NewsFeed]() {
        didSet {
            onMain {
                self.tableView?.reloadData()
            }
        }
    }
    
    var delegate: NewsFeedDelegate?
    
    init(tableView: UITableView, newsFeed: [NewsFeed]) {
        super.init()
        self.newsFeed = newsFeed
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView = tableView
    }
    
    func onMain(block: @escaping ()->()) {
        DispatchQueue.main.async {
            block()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsFeed.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let nib = UINib(nibName: "NewsFeedTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "news")
        let news = newsFeed[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "news", for: indexPath) as! NewsFeedTableViewCell
        cell.configure(news: news)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let news = newsFeed[indexPath.row]
        delegate?.newsFeedDataSource(self, selectedItem: news)
    }
}

extension NewsFeedDataSource: NewsFeedTableViewCellDelegate {
    func newsFeedTableViewCell(_ newsFeedTableViewCell: NewsFeedTableViewCell, didSelect news: NewsFeed) {
        
    }
    
    func newsFeedTableViewCell(_ newsFeedTableViewCell: NewsFeedTableViewCell, didDeselect news: NewsFeed) {
        
    }
}

