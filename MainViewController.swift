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
    
    @IBOutlet weak var sortBarButton: UIBarButtonItem!
    @IBOutlet weak var clickMeBarButton: UIBarButtonItem!
    var notesList: NotesList!
    let searchController = UISearchController(searchResultsController: nil)
    
    //MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        (tableView as! PagingTableView).pagingDelegate = self
        searchBarSetup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
    
    @IBAction func sortBarButtonPressed(_ sender: Any) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let descendingSortAction = UIAlertAction(title: "От новых к старым", style: .default) { (action) in
            if self.isFiltering() {
                self.notesList.filteredNotes.sort(by: { $0.date! > $1.date! })
            } else {
                self.notesList.notes.sort(by: { $0.date! > $1.date! })
            }
            self.sortBarButton.image = UIImage(imageLiteralResourceName: "sorting-descending")
            self.tableView.reloadData()
        }
        
        let ascendingSortAction = UIAlertAction(title: "От старых к новым", style: .default) { (action) in
            if self.isFiltering() {
                self.notesList.filteredNotes.sort(by: { $0.date! < $1.date! })
            } else {
                self.notesList.notes.sort(by: { $0.date! < $1.date! })
            }
            self.sortBarButton.image = UIImage(imageLiteralResourceName: "sorting-ascending")
            self.tableView.reloadData()
        }
        let alphabeticalSortAction = UIAlertAction(title: "По алфавиту", style: .default) { (action) in
            if self.isFiltering() {
                self.notesList.filteredNotes.sort(by: { $0.text!.lowercased() < $1.text!.lowercased()})
            } else {
                self.notesList.notes.sort(by: { $0.text!.lowercased() < $1.text!.lowercased()})
            }
            self.sortBarButton.image = UIImage(imageLiteralResourceName: "sorting-alphabetically")
            self.tableView.reloadData()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionSheet.addAction(descendingSortAction)
        actionSheet.addAction(ascendingSortAction)
        actionSheet.addAction(alphabeticalSortAction)
        actionSheet.addAction(cancelAction)
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    //MARK: SEGUES
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DetailNoteSegue" { //Fire when user tap a row
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
        if segue.identifier == "testingSettingsSegue" {
            let controller = segue.destination as! SettingsViewController
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
        guard let note = notesList.getNote(at: indexPath, when: isFiltering()) else {
            return cell
        }
        cell.configureWith(note)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        notesList.selectedNote = notesList.getNote(at: indexPath, when: isFiltering())
        return indexPath
    }

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let editAction = UITableViewRowAction(style: .normal, title: "Edit") { (rowAction, indexPath) in
            self.notesList.selectedNote = self.notesList.getNote(at: indexPath, when: self.isFiltering())
            self.performSegue(withIdentifier: "EditNoteSegue", sender: tableView)
        }
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (rowAction, indexPath) in
            self.notesList.deleteNote(at: indexPath, when: self.isFiltering())
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        editAction.backgroundColor = UIColor.green
        return [deleteAction, editAction]
    }

    // MARK: - Private instance methods
    private func searchBarSetup() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }
    
    //MARK: Searching helper methods
    private func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    private func filterContentForSearchText(_ searchText: String, scope: String = "All") {
/*        if !notesList.isUpdated {
            var fetchedNotes = [Note]()
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Note")
            let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
            fetchRequest.sortDescriptors = [sortDescriptor]
            notesList.isUpdated = true
            do {
                fetchedNotes = try notesList.managedContext.fetch(fetchRequest) as! [Note]
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
            notesList.notes = fetchedNotes
        }*/
        notesList.updateNotes()
        notesList.filteredNotes = (notesList.notes).filter({ (note) -> Bool in
            return (note.text?.lowercased().contains(searchText.lowercased()))!
        })
        tableView.reloadData()
        if notesList.filteredNotes.count != 0 {
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }
    
    private func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
}

//MARK: - CreateNoteViewControllerDelegate
extension MainViewController: CreateNoteViewControllerDelegate {
    func createNoteViewController(_ controller: CreateNoteViewController, didFinishAdding note: Note) {
        notesList.notes.insert(note, at: 0)
        let indexPath = IndexPath(row: 0, section: 0)
        navigationController?.popViewController(animated: true)
        tableView.insertRows(at: [indexPath], with: .automatic)
        tableView.scrollToRow(at: indexPath, at: .top, animated: true)
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
        
        //Disable ClickME and Create buttons
        navigationItem.rightBarButtonItem?.isEnabled = !searchController.searchBar.isFirstResponder
        navigationItem.leftBarButtonItem?.isEnabled = !searchController.searchBar.isFirstResponder
    }
}

//MARK: - PagingTableViewDelegate
extension MainViewController: PagingTableViewDelegate {
    func paginate(_ tableView: PagingTableView, to page: Int) {
        if !notesList.isUpdated {
            tableView.isLoading = true
            notesList.loadNotes(at: page) { (notes) in
                self.notesList.notes.append(contentsOf: notes)
                tableView.isLoading = false
            }
        }

    }
}

extension MainViewController: SettingsViewControllerDelegate {
    func settingsViewController(_ controller: SettingsViewController, didFinishSetting noteList: NotesList) {
        self.notesList = noteList
        self.notesList.isUpdated = false
        (tableView as! PagingTableView).reset()
        navigationController?.popViewController(animated: true)
    }
}
