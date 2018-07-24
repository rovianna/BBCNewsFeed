//
//  UserAlertView.swift
//  BBCNewsFeed
//
//  Created by Rodrigo Vianna on 24/07/18.
//  Copyright © 2018 Rodrigo Vianna. All rights reserved.
//

import UIKit

class UserAlertView: UIView {

    class var instance: UserAlertView {
        let nib = UINib(nibName: "UserAlertView", bundle: nil)
        let view = nib.instantiate(withOwner: nil, options: nil).first as! UserAlertView
        return view
    }
    
    @IBOutlet weak var infoStatusLabel: UILabel!
    
    enum InfoStatus {
        case updateNeeded
        case updateNotNeeded
        case offline
    }
    
    func configureViewBy(status: InfoStatus) {
        switch status {
        case .offline: offlineStatus()
        case .updateNeeded: updateNeeded()
        case .updateNotNeeded: updateNotNeeded()
        }
    }
    
    func updateNotNeeded() {
        self.backgroundColor = .green
        infoStatusLabel.text = "Você já possui a última versão"
    }
    
    func offlineStatus() {
        self.backgroundColor = .gray
        infoStatusLabel.text = "Você está offline, carregando última versão"
    }
    
    func updateNeeded() {
        self.backgroundColor = .yellow
        infoStatusLabel.text = "Você atualizou sua última versão"
    }
}
