//
//  NewsFeed.swift
//  BBCNewsFeed
//
//  Created by Rodrigo Vianna on 23/07/18.
//  Copyright © 2018 Rodrigo Vianna. All rights reserved.
//

import UIKit
import SWXMLHash

class NewsFeed: NSObject, NSCoding {
    var header: String
    var news: String
    var date: String
    var link: String
    
    init(header: String, news: String, date: String, link: String) {
        self.header = header
        self.news = news
        self.date = date
        self.link = link
    }
    
    /* Sheesh */
    init(with data: XMLIndexer) {
        header = data["title"].element!.text
        news = data["description"].element!.text
        date = data["pubDate"].element!.text
        link = data["link"].element!.text
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let header = aDecoder.decodeObject(forKey: "header") as! String
        let news = aDecoder.decodeObject(forKey: "news") as! String
        let date = aDecoder.decodeObject(forKey: "date") as! String
        let link = aDecoder.decodeObject(forKey: "link") as! String
        
        self.init(header: header, news: news, date: date, link: link)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(header, forKey: "header")
        aCoder.encode(news, forKey: "news")
        aCoder.encode(date, forKey: "date")
        aCoder.encode(link, forKey: "link")
    }
    
}

