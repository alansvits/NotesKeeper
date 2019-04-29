//
//  Note+Extension.swift
//  NotesKeeper
//
//  Created by Stas Shetko on 4/04/19.
//  Copyright © 2019 Stas Shetko. All rights reserved.
//

import UIKit
import CoreData

extension Note {
    var dateString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy"
        return dateFormatter.string(from: self.date!)
    }
    
    var timeString: String {
        let dateTimeFormatter = DateFormatter()
        dateTimeFormatter.dateFormat = "HH:mm"
        return dateTimeFormatter.string(from: self.date!)
    }

    convenience init(text: String, date: Date, insertInto managedObjectContext: NSManagedObjectContext) {
        let entity = NSEntityDescription.entity(forEntityName: "Note", in: managedObjectContext)!
        self.init(entity: entity, insertInto: managedObjectContext)
        self.text = text
        self.date = date
    }
}
