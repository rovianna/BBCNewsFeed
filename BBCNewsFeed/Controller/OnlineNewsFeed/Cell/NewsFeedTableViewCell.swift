//
//  NewsFeedTableViewCell.swift
//  BBCNewsFeed
//
//  Created by Rodrigo Vianna on 23/07/18.
//  Copyright © 2018 Rodrigo Vianna. All rights reserved.
//

import UIKit

protocol NewsFeedTableViewCellDelegate {
    func newsFeedTableViewCell(_ newsFeedTableViewCell: NewsFeedTableViewCell, didSelect news: NewsFeed)
    func newsFeedTableViewCell(_ newsFeedTableViewCell: NewsFeedTableViewCell, didDeselect news: NewsFeed)
}

class NewsFeedTableViewCell: UITableViewCell {
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    
    var delegate: NewsFeedTableViewCellDelegate?
    var newsFeed: NewsFeed?
    lazy var newsCommand = FavoriteCommand.init(button: favoriteButton)

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    func configure(news: NewsFeed){
        headerLabel.text = news.header
        descriptionLabel.text = news.news
        dateLabel.text = news.date
        newsFeed = news
    }
    
    func configureDateFrom(_ news: NewsFeed) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM YYYY"
        dateFormatter.locale = Locale(identifier: "en_US")
        guard let date = dateFormatter.date(from: news.date) else { return Date() }
        return date
    }
    
    @IBAction func favoriteAction(_ sender: UIButton) {
        let favorite = Favorites()
        if sender.imageView?.image == #imageLiteral(resourceName: "star") {
            newsCommand.execute()
            if let news = newsFeed {
                favorite.saveFavorites(newsFeed: news)
            }
        } else {
            newsCommand.undo()
            if let news = newsFeed {
                favorite.removeFavorite(newsFeed: news)
            }
        }
    }
}

