//
//  NotesList.swift
//  NotesKeeper
//
//  Created by Stas Shetko on 1/05/19.
//  Copyright © 2019 Stas Shetko. All rights reserved.
//

import UIKit
import CoreData

enum Mode {
    case create, edit, share
}
class NotesList {
    var notes = [Note]()
    var filteredNotes = [Note]()
    var selectedNote: Note?
    var managedContext: NSManagedObjectContext!
    var numberOfItemsPerPage = 20
    var mode: Mode?
    var isUpdated = false
    static var delay: Int?
    private var dispatchTime = DispatchTime.now() + DispatchTimeInterval.seconds(NotesList.delay ?? 0)

    
    init(with managedObjectContext: NSManagedObjectContext) {
        self.managedContext = managedObjectContext
    }
    
    func saveContext() {
        guard self.managedContext.hasChanges else { return }
        
        do {
            try self.managedContext.save()
        } catch let error as NSError {
            print("Unresolved error \(error), \(error.userInfo)")
        }
    }

    func loadNotes(at page: Int, onComplete: @escaping ([Note]) -> Void) {
        print("NotesList.delay  dispatchTime onComplete is \(dispatchTime)")

        DispatchQueue.main.asyncAfter(deadline: .now() + DispatchTimeInterval.seconds(DELAY ?? 0)) {
            var fetchNote = [Note]()
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Note")
            fetchRequest.fetchOffset = self.numberOfItemsPerPage * page
            fetchRequest.fetchLimit = self.numberOfItemsPerPage
            let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
            fetchRequest.sortDescriptors = [sortDescriptor]
            do {
                fetchNote = try self.managedContext.fetch(fetchRequest) as! [Note]
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
            guard fetchNote.count != 0 else {
                onComplete([])
                self.isUpdated = true
                return
            }
            onComplete(fetchNote)
        }
    }
    
}
