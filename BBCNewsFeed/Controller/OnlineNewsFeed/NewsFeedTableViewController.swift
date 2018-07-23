//
//  NewsFeedTableViewController.swift
//  BBCNewsFeed
//
//  Created by Rodrigo Vianna on 23/07/18.
//  Copyright © 2018 Rodrigo Vianna. All rights reserved.
//

import UIKit
import Alamofire
import SWXMLHash

fileprivate let nib = UINib(nibName: "NewsFeedTableViewCell", bundle: nil)

class NewsFeedTableViewController: UITableViewController {
    
    lazy var tableRefreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh(_:)), for: .valueChanged)
        refreshControl.tintColor = .black
        return refreshControl
    }()
    
    var newsFeed = [NewsFeed]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(nib, forCellReuseIdentifier: "news")
        requestTest()
        self.tableView.insertSubview(tableRefreshControl, at: 0)
    }

    
    @objc func handleRefresh(_ sender: UIRefreshControl) {
        requestTest()
        tableRefreshControl.endRefreshing()
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsFeed.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let news = newsFeed[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "news", for: indexPath) as! NewsFeedTableViewCell
        cell.configure(news: news)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cell = tableView.dequeueReusableCell(withIdentifier: "news") as! NewsFeedTableViewCell
        return cell.frame.size.height
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let news = newsFeed[indexPath.row]
        if let url = URL(string: news.link) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}

extension NewsFeedTableViewController {
    func requestTest(){
        Alamofire.request("http://feeds.bbci.co.uk/portuguese/rss.xml", method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil).responseString { (response) in
            switch response.result {
            case .success(let data):
                let xml = SWXMLHash.parse(data)
                for elem in xml["rss"]["channel"]["item"].all {
                    let news = NewsFeed(with: elem)
                    self.newsFeed.append(news)
                }
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
}
