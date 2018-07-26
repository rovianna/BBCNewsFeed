//
//  Command.swift
//  BBCNewsFeed
//
//  Created by Rodrigo Vianna on 25/07/18.
//  Copyright © 2018 Rodrigo Vianna. All rights reserved.
//

import UIKit

protocol Favorite {
    func favorite(button: UIButton)
    func undo(button: UIButton)
}
class NewsFeedFavorite: Favorite {    
    func favorite(button: UIButton){
        button.setTitle("UNDO", for: .normal)
        button.setTitleColor(UIColor.red, for: .normal)
        button.setImage(nil, for: .normal)
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            button.setTitle(nil, for: .normal)
            button.setImage(#imageLiteral(resourceName: "favorite_star"), for: .normal)
        }
    }
    
    func undo(button: UIButton) {
        button.setTitle("UNDO", for: .normal)
        button.setTitleColor(UIColor.red, for: .normal)
        button.setImage(nil, for: .normal)
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            button.setImage(#imageLiteral(resourceName: "star"), for: .normal)
            button.setTitle(nil, for: .normal)
        }
    }
}

protocol Command {
    func execute()
    func undo()
}

class FavoriteCommand: Command {
    var button: UIButton
    
    init(button: UIButton) {
        self.button = button
    }
    
    func execute() {
        NewsFeedFavorite().favorite(button: button)
    }
    
    func undo() {
        NewsFeedFavorite().undo(button: button)
    }
    
    
}
