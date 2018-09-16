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

protocol NewsFeedRepository {
    func getAll(completion: @escaping(Result<[NewsFeed]>) -> Void)
}

class LocalNewsFeedRepository: NewsFeedRepository {
    func getAll(completion: @escaping (Result<[NewsFeed]>) -> Void) {
        var newsFeed = [NewsFeed]()
        let decodedData = userDefaults.object(forKey: "newsFeed") as! Data
        let decodedNews = NSKeyedUnarchiver.unarchiveObject(with: decodedData) as! [NewsFeed]
        newsFeed = decodedNews
        DispatchQueue.main.async {
            completion(Result.success(newsFeed))
        }
    }
}

class OnlineNewsFeedRepository: NewsFeedRepository {
    func getAll(completion: @escaping(Result<[NewsFeed]>) -> Void) {
        var newsFeed = [NewsFeed]()
        Alamofire.request("http://feeds.bbci.co.uk/portuguese/rss.xml", method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil).responseString { (response) in
            switch response.result {
            case .success(let data):
                let newsXML = SWXMLHash.parse(data)
                newsFeed = newsXML["rss"]["channel"]["item"].all.compactMap({ news in NewsFeed(with: news)})
                DispatchQueue.main.async {
                    completion(Result.success(newsFeed))
                }
            case .failure(let error):
                completion(Result.failure(error))
            }
        }
    }
}
