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
        
    }
    
    func undo(button: UIButton) {
        
    }
}

protocol Command {
    func execute()
    func undo()
}
