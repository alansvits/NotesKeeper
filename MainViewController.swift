//
//  MainViewController.swift
//  NotesKeeper
//
//  Created by Stas Shetko on 4/04/19.
//  Copyright © 2019 Stas Shetko. All rights reserved.
//

import UIKit
import CoreData

class MainViewController: UITableViewController {
    
    var managedContext: NSManagedObjectContext!
    let notesList = Noteslist()
    let searchController = UISearchController(searchResultsController: nil)
    var fetchLimit = 20
    var fetchOffset = 0
    
    //MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
//                deleteAllRecords()
//        createDummyNotes(with: 30)
        updateNotesList()
        //SearchBar setup
        searchBarSetup()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        notesList = getNotesFromDB(notesList.count) as! [Note]
//        print("\n notesList.notes.count in viewWillAppear: \(notesList.notes.count)")

    }
    //MARK: SEGUES
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DetailNoteSegue" { //Fire wher user tap a row
            let controller = segue.destination as! CreateNoteViewController
            notesList.mode = .share
            controller.notesList = notesList
            controller.managedContext = managedContext
        }
        if segue.identifier == "CreateNewNoteSegue" {
            let controller = segue.destination as! CreateNoteViewController
            notesList.mode = .create
            controller.notesList = notesList
            controller.delegate = self
            controller.managedContext = managedContext
        }
        if segue.identifier == "EditNoteSegue" {
            let controller = segue.destination as! CreateNoteViewController
            notesList.mode = .edit
            controller.notesList = notesList
            controller.delegate = self
            controller.managedContext = managedContext
        }
    }

    // MARK: - Table view methods
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return notesList.filteredNotes.count
        }
//        print("\n numberOfRowsInSection notesList.count is \(notesList.notes.count)")
        return notesList.notes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoteItem", for: indexPath) as! NoteTableViewCell
        let note: Note
        if isFiltering() {
            note = notesList.filteredNotes[indexPath.row]
        } else {
//            print("\n cellForRowAt notesList.count is \(notesList.notes.count)")
            note = notesList.notes[indexPath.row]
        }
        cell.noteLabel.text = note.text
        cell.dateLabel.text = note.dateString
        cell.timeLabel.text = note.timeString

        return cell
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        notesList.selectedNote = getNote(at: indexPath, when: isFiltering())
//        notesList.selectedNoteIndexPath = indexPath
        return indexPath
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        if indexPath.row == notesList.count - 1 {
//            let newPart = getNotesFromDB(notesList.count) as! [Note]
//            if newPart.count > 0 {
//                print("\n newPart.count in willDisplay cell: \(newPart.count)")
//                notesList += newPart
//                print("\n notesList.count in willDisplay cell: \(notesList.count)")
//            self.perform(#selector(reloadTable), with: nil, afterDelay: 1.0)
//            }
//        }
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let editAction = UITableViewRowAction(style: .normal, title: "Edit") { (rowAction, indexPath) in
            self.notesList.selectedNote = self.getNote(at: indexPath, when: self.isFiltering())
//            self.notesList.selectedNoteIndexPath = indexPath
            self.performSegue(withIdentifier: "EditNoteSegue", sender: tableView)
        }
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (rowAction, indexPath) in
            self.deleteNote(at: indexPath, when: self.isFiltering())
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        editAction.backgroundColor = UIColor.green
        return [deleteAction, editAction]
    }

    // MARK: - Private instance methods
    private func searchBarSetup() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.hidesNavigationBarDuringPresentation = false
        definesPresentationContext = true
    }
    
    private func updateNotesList() {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Note")
        do {
//            print("\n Returns the number of objects \(try managedContext.count(for: fetchRequest))")
            notesList.notes = try managedContext.fetch(fetchRequest) as! [Note]
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    private func deleteNote(at indexPath: IndexPath, when filtering: Bool) {
        if filtering {
            let note = self.notesList.filteredNotes[indexPath.row]
            let date = note.date!
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
            fetchRequest.predicate = NSPredicate(format: "date = %@", date as NSDate)
            
            do {
                let fetchResult = try self.managedContext.fetch(fetchRequest)
                let noteToDelete = fetchResult[0] as! NSManagedObject
                self.managedContext.delete(noteToDelete)
                
                do  {
                    try self.managedContext.save()
                } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                }
            } catch let error as NSError {
                print("Could not delete. \(error), \(error.userInfo)")
            }
            self.notesList.filteredNotes.remove(at: indexPath.row)
            self.updateNotesList()
        } else {
            let note = self.notesList.notes[indexPath.row]
            let date = note.date!
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
            fetchRequest.predicate = NSPredicate(format: "date = %@", date as NSDate)
            
            do {
                let fetchResult = try self.managedContext.fetch(fetchRequest)
                let noteToDelete = fetchResult[0] as! NSManagedObject
                self.managedContext.delete(noteToDelete)
                
                do  {
                    try self.managedContext.save()
                } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                }
            } catch let error as NSError {
                print("Could not delete. \(error), \(error.userInfo)")
            }
            self.notesList.notes.remove(at: indexPath.row)
        }
    }
    
    private func getNote(at indexPath: IndexPath, when isFilteting: Bool) -> Note {
        let note: Note
        if isFilteting {
            note = notesList.filteredNotes[indexPath.row]
        } else {
            note = notesList.notes[indexPath.row]
        }
        return note
    }
    //MARK: Searching helper methods
    private func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    private func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        notesList.filteredNotes = (notesList.notes).filter({ (note) -> Bool in
            return (note.text?.lowercased().contains(searchText.lowercased()))!
        })
        tableView.reloadData()
    }
    
    private func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    //TODO: - Need finishing
    private func getNotesFromDB(_ fetchOffSet: Int) -> [Any] {
        var record = [Any]() /* capacity: 0 */
        //        var context: NSManagedObjectContext? = self.getManagedObjectContext()
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Note")
        fetchRequest.fetchLimit = fetchLimit
        fetchRequest.fetchOffset = fetchOffSet
        let entityDesc = NSEntityDescription.entity(forEntityName: "Note", in: self.managedContext)
        fetchRequest.entity = entityDesc
        var fetchedOjects = try? self.managedContext.fetch(fetchRequest)
        for i in 0..<fetchedOjects!.count {
            let note: Note = fetchedOjects![i] as! Note
            record.append(note)
        }
        return record
    }
    
    @objc private func reloadTable() {
        tableView.reloadData()
    }
    //MARK: - For testing purpose
    private func deleteAllRecords() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try managedContext.execute(deleteRequest)
        } catch let error as NSError {
            print("Could not delete all data. \(error), \(error.userInfo)")
        }
    }
    
    private func createDummyNotes(with numberOfItems: Int) {
        for item in 1...numberOfItems {
            saveNote(with: String(item))
        }
    }
    
    private func saveNote(with text: String) {
        let entity = NSEntityDescription.entity(forEntityName: "Note", in: managedContext)!
        let note = NSManagedObject(entity: entity, insertInto: managedContext)
        note.setValue(text, forKey: "text")
        note.setValue(Date(), forKey: "date")
        do {
            try managedContext.save()
            notesList.notes.append(note as! Note)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
}

//MARK: - CreateNoteViewControllerDelegate
extension MainViewController: CreateNoteViewControllerDelegate {
    func createNoteViewController(_ controller: CreateNoteViewController, didFinishAdding note: Note) {
        notesList.notes.append(note)
//        print("\n notesList.count in didFinishAdding: \(notesList.count)")

        tableView.reloadData()
        navigationController?.popViewController(animated: true)
    }
    
    func createNoteViewController(_ controller: CreateNoteViewController, didFinishEditing editedNote: Note) {
        tableView.reloadData()
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UISearchResultsUpdating Delegate
extension MainViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
