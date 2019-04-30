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
    var notesList: Noteslist!
    let searchController = UISearchController(searchResultsController: nil)
    var fetchLimit = 10
    var fetchOffset = 0
    
    //MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        notesList.numberOfItemsPerPage = 20
        (tableView as! PagingTableView).pagingDelegate = self
//                deleteAllRecords()
//        createDummyNotes(with: 40)
        
//        notesList.updateNotesList()
        //SearchBar setup
        searchBarSetup()

        
    }
    
    //MARK: SEGUES
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DetailNoteSegue" { //Fire wher user tap a row
            let controller = segue.destination as! CreateNoteViewController
            notesList.mode = .share
            controller.notesList = notesList
        }
        if segue.identifier == "CreateNewNoteSegue" {
            let controller = segue.destination as! CreateNoteViewController
            notesList.mode = .create
            controller.notesList = notesList
            controller.delegate = self
        }
        if segue.identifier == "EditNoteSegue" {
            let controller = segue.destination as! CreateNoteViewController
            notesList.mode = .edit
            controller.notesList = notesList
            controller.delegate = self
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
        return notesList.notes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoteItem", for: indexPath) as! NoteTableViewCell
        let note: Note
        if isFiltering() {
            note = notesList.filteredNotes[indexPath.row]
        } else {
            note = notesList.notes[indexPath.row]
        }
        cell.noteLabel.text = note.text
        cell.dateLabel.text = note.dateString
        cell.timeLabel.text = note.timeString

        return cell
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        notesList.selectedNote = getNote(at: indexPath, when: isFiltering())
        return indexPath
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let editAction = UITableViewRowAction(style: .normal, title: "Edit") { (rowAction, indexPath) in
            self.notesList.selectedNote = self.getNote(at: indexPath, when: self.isFiltering())
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
    
    private func deleteNote(at indexPath: IndexPath, when filtering: Bool) {
        if filtering {
            let note = notesList.filteredNotes[indexPath.row]
            notesList.managedContext.delete(note)
            notesList.filteredNotes.remove(at: indexPath.row)
            notesList.notes.removeAll { $0 == note }
        } else {
            let note = notesList.notes[indexPath.row]
            notesList.managedContext.delete(note)
            notesList.notes.remove(at: indexPath.row)
        }
        notesList.saveContext()
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
//        var searchTest = searchText.lowercased()
        if notesList.flag {
            var fetchedNotes = [Note]()
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Note")
            let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
            fetchRequest.sortDescriptors = [sortDescriptor]
            notesList.flag = false
            do {
                fetchedNotes = try notesList.managedContext.fetch(fetchRequest) as! [Note]
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
            notesList.notes = fetchedNotes
        }
        notesList.filteredNotes = (notesList.notes).filter({ (note) -> Bool in
            return (note.text?.lowercased().contains(searchText.lowercased()))!
        })
        tableView.reloadData()
    }
    
    private func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    //TODO: - Need finishing
    private func getNotesFromDB(_ fetchOffSet: Int) -> [Note] {
        var notes = [Note]()
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Note")
        fetchRequest.fetchLimit = fetchLimit
        fetchRequest.fetchOffset = fetchOffSet
        do {
            notes = try self.notesList.managedContext.fetch(fetchRequest) as! [Note]
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return notes
    }
    
    //MARK: - For testing purpose
    private func deleteAllRecords() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try self.notesList.managedContext.execute(deleteRequest)
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
        let _ = Note(text: text, date: Date(), insertInto: notesList.managedContext)
        notesList.saveContext()
    }
}

//MARK: - CreateNoteViewControllerDelegate
extension MainViewController: CreateNoteViewControllerDelegate {
    func createNoteViewController(_ controller: CreateNoteViewController, didFinishAdding note: Note) {
        notesList.notes.insert(note, at: 0)
        let indexPath = IndexPath(row: 0, section: 0)
        navigationController?.popViewController(animated: true)
        tableView.insertRows(at: [indexPath], with: .automatic)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
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
        navigationItem.rightBarButtonItem?.isEnabled = !searchController.searchBar.isFirstResponder
    }
}

//MARK: - PagingTableViewDelegate
extension MainViewController: PagingTableViewDelegate {
    func paginate(_ tableView: PagingTableView, to page: Int) {
        if notesList.flag {
            tableView.isLoading = true
            notesList.loadNotes(at: page) { (notes) in
                self.notesList.notes.append(contentsOf: notes)
                (self.tableView as! PagingTableView).isLoading = false
            }
        }

    }
}
