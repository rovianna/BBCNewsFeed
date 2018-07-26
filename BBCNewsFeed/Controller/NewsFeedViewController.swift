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
        validateNewsLastBuildDate()
        self.newsFeedTableView.insertSubview(tableRefreshControl, at: 0)
    }
    
    @objc func handleRefresh(_ sender: UIRefreshControl) {
        validateNewsLastBuildDate()
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
    
    func validateNewsLastBuildDate() {
        let lastBuild = userDefaults.object(forKey: "lastBuildDate") as? String
        validateLastBuildDate { (result) in
            switch result {
            case .success(let data):
                if let build = lastBuild {
                    if build == data {
                        self.getOfflineNewsFeed()
                        self.showInformView(status: .updateNotNeeded)
                    }
                }else {
                    userDefaults.set(data, forKey: "lastBuildDate")
                    self.getOnlineNewsFeed()
                    self.showInformView(status: .updateNeeded)
                }
            case .failure(let error):
                self.showError(error: error)
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
        let offlineRepository = LocalNewsFeedRepository()
        offlineRepository.getAll { (result) in
            switch result {
            case .success(let data):
                self.newsFeed = data
            case .failure(let error):
                self.showError(error: error)
            }
        }
    }
    
    func getOnlineNewsFeed() {
        let onlineRepository = OnlineNewsFeedRepository()
        onlineRepository.getAll { (result) in
            switch result {
            case .success(let data):
                self.newsFeed = data
                let encodedData = NSKeyedArchiver.archivedData(withRootObject: self.newsFeed)
                userDefaults.set(encodedData, forKey: "newsFeed")
            case .failure(let error):
                self.showError(error: error)
            }
        }
    }
    
    func validateLastBuildDate(completion: @escaping(Result<String>) -> Void) {
        Alamofire.request("http://feeds.bbci.co.uk/portuguese/rss.xml", method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil).responseString { (response) in
            switch response.result {
            case .success(let data):
                let newsXML = SWXMLHash.parse(data)
                let buildDate = newsXML["rss"]["channel"]["lastBuildDate"].element!.text
                DispatchQueue.main.async {
                    completion(Result.success(buildDate))
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(Result.failure(error))
                }
            }
        }
    }
    
}

extension NewsFeedViewController: NewsFeedDelegate {
    func newsFeedDataSource(_ newsFeedDataSource: NewsFeedDataSource, selectedItem: NewsFeed) {
        if let url = URL(string: selectedItem.link) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
