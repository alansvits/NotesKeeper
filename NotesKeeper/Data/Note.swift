//
//  Note.swift
//  NotesKeeper
//
//  Created by Stas Shetko on 4/04/19.
//  Copyright © 2019 Stas Shetko. All rights reserved.
//

import Foundation

class Note {
    var date: Date
    var text = ""
    
    var dateString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy"
        return dateFormatter.string(from: date)
    }
    
    var timeString: String {
        let dateTimeFormatter = DateFormatter()
        dateTimeFormatter.dateFormat = "HH:mm"
        return dateTimeFormatter.string(from: date)
    }
    
    init(text: String, date: Date) {
        self.text = text
        self.date = date
    }

}
