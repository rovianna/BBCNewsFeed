//
//  Repository.swift
//  BBCNewsFeed
//
//  Created by Rodrigo Vianna on 25/07/18.
//  Copyright © 2018 Rodrigo Vianna. All rights reserved.
//

import UIKit
import Alamofire
import SWXMLHash

fileprivate let userDefaults = UserDefaults.standard

protocol Repository {
    func getAll() -> [NewsFeed]
}

class LocalNewsFeedRepository: Repository {
    func getAll() -> [NewsFeed] {
        var newsFeed = [NewsFeed]()
        let decodedData = userDefaults.object(forKey: "newsFeed") as! Data
        let decodedNews = NSKeyedUnarchiver.unarchiveObject(with: decodedData) as! [NewsFeed]
        newsFeed = decodedNews
        return newsFeed
    }
}

class OnlineNewsFeedRepository: Repository {
    func getAll() -> [NewsFeed] {
        var newsFeed = [NewsFeed]()
        Alamofire.request("http://feeds.bbci.co.uk/portuguese/rss.xml", method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil).responseString { (response) in
            switch response.result {
            case .success(let data):
                let xml = SWXMLHash.parse(data)
                let lastBuildDate = xml["rss"]["channel"]["lastBuildDate"].description
                for elem in xml["rss"]["channel"]["item"].all {
                    let news = NewsFeed(with: elem)
                    newsFeed.append(news)
                }
            case .failure(let error):
                break
            }
        }
        return newsFeed
    }
}
