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
    var notesList: [NSManagedObject] = []
    var selectedNote: Note?
    var selectedNoteIndexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
        for item in notesList {
//            print("objectID is \(item.objectID)")
            
            let note = item as! Note
            let date = note.date?.description
//            print(date)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notesList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoteItem", for: indexPath) as! NoteTableViewCell
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
        return indexPath
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let editAction = UITableViewRowAction(style: .normal, title: "Edit") { (rowAction, indexPath) in
            self.selectedNote = (self.notesList[indexPath.row] as! Note)
            self.selectedNoteIndexPath = indexPath
            self.performSegue(withIdentifier: "EditNoteSegue", sender: tableView)
        }
        
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (rowAction, indexPath) in
            let note = self.notesList[indexPath.row] as! Note
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

            self.notesList.remove(at: indexPath.row)
            
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        editAction.backgroundColor = UIColor.green
        return [deleteAction, editAction]
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DetailNoteSegue" {
            let controller = segue.destination as! CreateNoteViewController
            controller.note = selectedNote
            controller.createMode = false
            controller.editMode = false
            controller.shareMode = true
            controller.managedContext = managedContext
        }
        if segue.identifier == "CreateNewNoteSegue" {
            let controller = segue.destination as! CreateNoteViewController
            controller.delegate = self
            controller.createMode = true
            controller.editMode = false
            controller.shareMode = false
            controller.managedContext = managedContext
        }
        if segue.identifier == "EditNoteSegue" {
            let controller = segue.destination as! CreateNoteViewController
            controller.delegate = self
            controller.managedContext = managedContext
            controller.createMode = false
            controller.editMode = true
            controller.shareMode = false
            controller.note = selectedNote
            controller.selectedNoteIndexPath = selectedNoteIndexPath
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
    
    func createNoteViewController(_ controller: CreateNoteViewController, didFinishEditing editedNote: Note) {
        if let indexPath = selectedNoteIndexPath {
            let range = indexPath.row...indexPath.row
            notesList.replaceSubrange(range, with: [editedNote])
            tableView.reloadData()
            navigationController?.popViewController(animated: true)
        }
        
    }

}
