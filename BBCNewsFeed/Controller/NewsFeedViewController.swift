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
            showInformView(status: .offline)
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
        self.newsFeedTableView.reloadData()
    }
    
    func receiveNewsFeed(_ newsFeed: [NewsFeed]) {
        let source = NewsFeedDataSource(tableView: newsFeedTableView, newsFeed: newsFeed)
        applyDataSource(source: source)
    }
    
    func applyDataSource(source: NewsFeedDataSource) {
        source.delegate = self
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
    
    func retrieveOnlineNewsFeed(xml: XMLIndexer) {
        for elem in xml["rss"]["channel"]["item"].all {
            let news = NewsFeed(with: elem)
            self.newsFeed.append(news)
        }
        self.saveNewsFeedLocally(self.newsFeed)
    }
    
    func validateNewsLastBuildDate(_ lastBuildDate: String, xml: XMLIndexer) {
        if userDefaults.object(forKey: "lastBuildDate") == nil {
            userDefaults.set(lastBuildDate, forKey: "lastBuildDate")
            self.retrieveOnlineNewsFeed(xml: xml)
        } else {
            let buildDate = userDefaults.object(forKey: "lastBuildDate") as! String
            if buildDate == lastBuildDate {
                self.newsFeed = self.retrieveLocalNewsFeed()
                showInformView(status: .updateNotNeeded)
            } else {
                userDefaults.set(lastBuildDate, forKey: "lastBuildDate")
                self.retrieveOnlineNewsFeed(xml: xml)
                showInformView(status: .updateNeeded)
            }
        }
    }
    
    func showInformView(status: UserAlertView.InfoStatus) {
        switch status {
        case .offline: layoutInformView(status: .offline)
        case .updateNeeded: layoutInformView(status: .updateNeeded)
        case .updateNotNeeded: layoutInformView(status: .updateNotNeeded)
        }
    }
    
    func layoutInformView(status: UserAlertView.InfoStatus) {
        let userAlert = UserAlertView.instance
        UIView.animate(withDuration: 0.3) {
            self.view.addSubview(userAlert)
            self.view.bringSubview(toFront: userAlert)
        }
        userAlert.translatesAutoresizingMaskIntoConstraints = false
        userAlert.topAnchor.constraint(equalTo: newsFeedTableView.topAnchor).isActive = true
        userAlert.leadingAnchor.constraint(equalTo: newsFeedTableView.leadingAnchor).isActive = true
        userAlert.trailingAnchor.constraint(equalTo: newsFeedTableView.trailingAnchor).isActive = true
        userAlert.heightAnchor.constraint(equalToConstant: 50).isActive = true
        userAlert.configureViewBy(status: status)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            UIView.animate(withDuration: 0.5, animations: {
                userAlert.removeFromSuperview()
            })
        }
    }
    
    func getOfflineNewsFeed() {
        let decodedData = userDefaults.object(forKey: "newsFeed") as! Data
        let decodedNews = NSKeyedUnarchiver.unarchiveObject(with: decodedData) as! [NewsFeed]
        self.newsFeed = decodedNews
    }
    
    func getOnlineNewsFeed() {

    }
    
}

extension NewsFeedViewController: NewsFeedDelegate {
    func newsFeedDataSource(_ newsFeedDataSource: NewsFeedDataSource, selectedItem: NewsFeed) {
        if let url = URL(string: selectedItem.link) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
