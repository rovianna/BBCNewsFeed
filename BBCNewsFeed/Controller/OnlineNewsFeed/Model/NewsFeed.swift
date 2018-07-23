//
//  NewsFeed.swift
//  BBCNewsFeed
//
//  Created by Rodrigo Vianna on 23/07/18.
//  Copyright © 2018 Rodrigo Vianna. All rights reserved.
//

import UIKit
import SWXMLHash

class NewsFeed {
    var header: String
    var description: String
    var date: String
    var link: String
    
    init(header: String, description: String, date: String, link: String) {
        self.header = header
        self.description = description
        self.date = date
        self.link = link
    }
    
    /* Sheesh */
    init(with data: XMLIndexer) {
        header = data["title"].element!.text
        description = data["description"].element!.text
        date = data["pubDate"].element!.text
        link = data["link"].element!.text
    }
    
}

