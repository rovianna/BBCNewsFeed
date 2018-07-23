//
//  Conectivity.swift
//  BBCNewsFeed
//
//  Created by Rodrigo Vianna on 23/07/18.
//  Copyright © 2018 Rodrigo Vianna. All rights reserved.
//

import UIKit
import Alamofire

class Connectivity {
    class var isConnectedToInternet: Bool {
        return NetworkReachabilityManager()!.isReachable
    }
}
