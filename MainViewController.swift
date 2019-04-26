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
    var notes = [NoCoreDataNoteItem]()
    var notesList: [NSManagedObject] = []
    var selectedNote: Note?
    
    private func dummyNotes(from text: [String]) -> [NoCoreDataNoteItem] {
        var notes = [NoCoreDataNoteItem]()
        for item in text {
            notes.append(NoCoreDataNoteItem(text: item, date: Date()))
        }
        return notes
    }
  
    let testContent = ["testing test testing test testingtesting testing test testing test testing test testing test testing test testing 100t ", "testing2 test2 testing", "testing3 test3 testing3 test3 testing3 test3 testing3 test3 testing3 test3 testing3 test3 testing3 test3 ", "testing4 test4 testing4 test4 testing4 test4 testing4 test4 /ntesting4 test4 testing4 test4 testing4 test4 testing4 test4 testing4 test4 testing4 test4 testing4 test4 testing4 test4 testing4 test4 testing4 test4 testing4 test4 testing4 test4 testing4 test4 testing4 test4 testing4 test4 testing4 test4 testing4 test4 testing4 test4 testing4 test4 testing4 test4 testing4 test4 testing4 test4 testing4 test4 testing4 test4 testing4 test4 testing4 test4 testing4 test4 testing4 test4 testing4 test4 testing4 test4 testing4 test4 testing4 test4 testing4 test4 "]

    override func viewDidLoad() {
        super.viewDidLoad()

        notes = dummyNotes(from: testContent)
    }
    
    fileprivate func updateNotesList() {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Note")
        do {
            notesList = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateNotesList()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return notes.count
        return notesList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoteItem", for: indexPath) as! NoteTableViewCell
//        let note = notes[indexPath.row]
//        cell.noteLabel.text = note.text
//        cell.dateLabel.text = note.dateString
//        cell.timeLabel.text = note.timeString
//
//        return cell
        if let note = notesList[indexPath.row] as? Note {
            cell.noteLabel.text = note.text
            cell.dateLabel.text = note.dateString
            cell.timeLabel.text = note.timeString
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        selectedNote = notesList[indexPath.row] as? Note
        print("selectedNote in willSelectRowAt is \(selectedNote!)")
        return indexPath
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DetailNoteSegue" {
            let controller = segue.destination as! CreateNoteViewController
            controller.note = selectedNote
            print("selectedNote in DetailNoteSegue is \(selectedNote!)")
            controller.editMode = false
            controller.managedContext = managedContext
        }
        if segue.identifier == "CreateNewNoteSegue" {
            let controller = segue.destination as! CreateNoteViewController
            controller.delegate = self
            controller.managedContext = managedContext
        }
    }
    
    private func saveNote(text: String) {
        let entity = NSEntityDescription.entity(forEntityName: "Note", in: managedContext)!
        let note = NSManagedObject(entity: entity, insertInto: managedContext)
        note.setValue(text, forKey: "text")
        note.setValue(Date(), forKey: "date")
        do {
            try managedContext.save()
            notesList.append(note)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }

}

extension MainViewController: CreateNoteViewControllerDelegate {
    func createNoteViewController(_ controller: CreateNoteViewController, didFinishAdding note: Note) {
        notesList.append(note)
        tableView.reloadData()
        navigationController?.popViewController(animated: true)
    }
}
