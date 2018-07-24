//
//  NewsFeedViewController.swift
//  BBCNewsFeed
//
//  Created by Rodrigo Vianna on 24/07/18.
//  Copyright © 2018 Rodrigo Vianna. All rights reserved.
//

import UIKit
import Alamofire
import SWXMLHash

protocol NewsFeedRepository {
    func getOnlineNewsFeed()
    func getOfflineNewsFeed()
}

fileprivate let userDefaults = UserDefaults.standard

class NewsFeedViewController: UIViewController {

    @IBOutlet weak var newsFeedTableView: UITableView!
    
    lazy var tableRefreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh(_:)), for: .valueChanged)
        refreshControl.tintColor = .black
        return refreshControl
    }()
    var newsFeed = [NewsFeed]() {
        didSet {
            loadNewsFeed(newsFeed)
        }
    }
    var source: NewsFeedDataSource?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if Connectivity.isConnectedToInternet {
            getOnlineNewsFeed()
        } else {
            newsFeed = retrieveLocalNewsFeed()
        }
        self.newsFeedTableView.insertSubview(tableRefreshControl, at: 0)
    }

    @objc func handleRefresh(_ sender: UIRefreshControl) {
        getOnlineNewsFeed()
        tableRefreshControl.endRefreshing()
    }
    
    func loadNewsFeed(_ newsFeed: [NewsFeed]) {
        receiveNewsFeed(newsFeed)
    }
    
    func receiveNewsFeed(_ newsFeed: [NewsFeed]) {
        let source = NewsFeedDataSource(tableView: newsFeedTableView, newsFeed: newsFeed)
        applyDataSource(source: source)
    }
    
    func applyDataSource(source: NewsFeedDataSource) {
        self.source = source
    }
    
    func retrieveLocalNewsFeed() -> [NewsFeed] {
        let decodedData = userDefaults.object(forKey: "newsFeed") as! Data
        let decodedNews = NSKeyedUnarchiver.unarchiveObject(with: decodedData) as! [NewsFeed]
        return decodedNews
    }
    
    func saveNewsFeedLocally(_ newsFeed: [NewsFeed]) {
        let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: newsFeed)
        userDefaults.set(encodedData, forKey: "newsFeed")
        userDefaults.synchronize()
    }
    
}

extension NewsFeedViewController: NewsFeedRepository {
    func getOfflineNewsFeed() {
        let decodedData = userDefaults.object(forKey: "newsFeed") as! Data
        let decodedNews = NSKeyedUnarchiver.unarchiveObject(with: decodedData) as! [NewsFeed]
        self.newsFeed = decodedNews
    }
    
    func getOnlineNewsFeed() {
        Alamofire.request("http://feeds.bbci.co.uk/portuguese/rss.xml", method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil).responseString { (response) in
            switch response.result {
            case .success(let data):
                let xml = SWXMLHash.parse(data)
                for elem in xml["rss"]["channel"]["item"].all {
                    let news = NewsFeed(with: elem)
                    self.newsFeed.append(news)
                }
                self.saveNewsFeedLocally(self.newsFeed)
            case .failure(let error):
                self.showError(error: error)
            }
        }
    }
    
    
}