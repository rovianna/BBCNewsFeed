//
//  DateExtension.swift
//  BBCNewsFeed
//
//  Created by Rodrigo Vianna on 16/09/18.
//  Copyright © 2018 Rodrigo Vianna. All rights reserved.
//

import Foundation

extension Date {
    var shortDateFormat: String {
        let formatter = DateFormatter.dateShortDayFormatter
        formatter.dateStyle = .short
        let date = formatter.string(from: self)
        return date
    }
}

extension DateFormatter {
    static var localDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "pt-BR")
        return formatter
    }
    
    static var dateShortDayFormatter: DateFormatter {
        let formatter = localDateFormatter
        formatter.dateFormat = "EEEE, dd/MM"
        return formatter
    }
}
