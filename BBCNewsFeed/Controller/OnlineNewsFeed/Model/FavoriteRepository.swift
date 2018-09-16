//
//  FavoriteRepository.swift
//  BBCNewsFeed
//
//  Created by Rodrigo Vianna on 16/09/18.
//  Copyright © 2018 Rodrigo Vianna. All rights reserved.
//

import UIKit
import Alamofire

protocol Repository {
    func getAll(completion: @escaping(Result<[NewsFeed]>)-> Void)
    func saveFavorites(newsFeed: NewsFeed)
    func removeFavorite(newsFeed: NewsFeed)
}

fileprivate let userDefault = UserDefaults.standard

class Favorites: Repository {
    func getAll(completion: @escaping (Result<[NewsFeed]>) -> Void) {
        let decodedData = userDefault.object(forKey: "favoriteFeed") as! Data
        let decodedNews = NSKeyedUnarchiver.unarchiveObject(with: decodedData) as! [NewsFeed]
        DispatchQueue.main.async {
            completion(Result.success(decodedNews))
        }
    }
    
    func saveFavorites(newsFeed: NewsFeed) {
        let decodedData = userDefault.object(forKey: "favoriteFeed") as! Data
        var decodedNews = NSKeyedUnarchiver.unarchiveObject(with: decodedData) as! [NewsFeed]
        decodedNews.append(newsFeed)
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: decodedNews)
        userDefault.set(encodedData, forKey: "favoriteFeed")
    }
    
    func removeFavorite(newsFeed: NewsFeed) {
        let decodedData = userDefault.object(forKey: "favoriteFeed") as! Data
        let decodedNews = (NSKeyedUnarchiver.unarchiveObject(with: decodedData) as! [NewsFeed]).filter { $0 != newsFeed }
        let encondedData = NSKeyedArchiver.archivedData(withRootObject: decodedNews)
        userDefault.set(encondedData, forKey: "favoriteFeed")
    }
    
}
