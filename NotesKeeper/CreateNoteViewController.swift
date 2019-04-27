//
//  CreateNoteViewController.swift
//  NotesKeeper
//
//  Created by Stas Shetko on 4/04/19.
//  Copyright © 2019 Stas Shetko. All rights reserved.
//

import UIKit
import CoreData

protocol CreateNoteViewControllerDelegate: class {
    func createNoteViewController(_ controller: CreateNoteViewController, didFinishAdding note: Note)
    func createNoteViewController(_ controller: CreateNoteViewController, didFinishEditing editedNote: Note)
}

class CreateNoteViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    
    weak var delegate: CreateNoteViewControllerDelegate?
    var saveButton: UIBarButtonItem!
    var shareButton: UIBarButtonItem?
    var selectedNoteIndexPath: IndexPath?
    var createMode = true
    var editMode = false
    var shareMode = false
    var note: Note?
    var managedContext: NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        saveButton = UIBarButtonItem(title: "Сохранить", style: .plain, target: self, action: #selector(saveNoteButtonPressed(_:)))
        shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareButtonPressed(_:)))
//        showSaveButton()
        chooseRightBarButtonTitle()
        
        textView.contentInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        textView.text = note?.text ?? ""
        setupTextView()
        
        let noteID = note?.objectID
        print("\n\nCreateNoteViewController, noteID is \(String(describing: noteID))\n\n")
        
    }
    
    @objc func shareButtonPressed(_ sender: Any) {
        let text = [textView.text]
        let activityViewController = UIActivityViewController(activityItems: text, applicationActivities: nil)
        present(activityViewController, animated: true, completion: {})
    }
    
    @objc func saveNoteButtonPressed(_ sender: Any) {
        if editMode && !createMode {
            if let note = note {
                editNote()
                delegate?.createNoteViewController(self, didFinishEditing: note)
                self.note = nil
                print("\n\nif editMode && !createMode: \(note.objectID)\n\n")
            }
        }
        if createMode && !editMode {
            let text = textView.text!
            let entity = NSEntityDescription.entity(forEntityName: "Note", in: managedContext)!
            
            let note = NSManagedObject(entity: entity, insertInto: managedContext)
            note.setValue(text, forKey: "text")
            note.setValue(Date(), forKey: "date")
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
            self.note = nil
            delegate?.createNoteViewController(self, didFinishAdding: note as! Note)
        }
    }
    
    private func editNote() {
        note?.text = textView.text
        note?.date = Date()
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not saved edited note. \(error), \(error.userInfo)")
        }
    }
    
    private func showSaveButton() {
        if !createMode && !editMode {
            navigationItem.rightBarButtonItem = nil
        } else {
            navigationItem.rightBarButtonItem = saveButton
        }
    }
    
    private func setupTextView() {
        if createMode || editMode {
            textView.isEditable = true
            textView.becomeFirstResponder()
        } else {
            textView.isEditable = false
            textView.resignFirstResponder()
        }
    }
    
    private func chooseRightBarButtonTitle() {
        if createMode {
            navigationItem.rightBarButtonItem = saveButton
            navigationItem.rightBarButtonItem?.title = "Сохранить"
            editMode = false
            shareMode = false
        }
        if editMode {
            navigationItem.rightBarButtonItem = saveButton
            navigationItem.rightBarButtonItem?.title = "Редактировать"
            createMode = false
            shareMode = false
        }
        if shareMode {
            navigationItem.rightBarButtonItem = shareButton
            createMode = false
            editMode = false
        }
    }

}
