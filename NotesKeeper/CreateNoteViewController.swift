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
    var editButton: UIBarButtonItem!
    var notesList: Noteslist!
//    var managedContext: NSManagedObjectContext!
    
    //MARK: - METHODS
    override func viewDidLoad() {
        super.viewDidLoad()
        
        saveButton = UIBarButtonItem(title: "Сохранить", style: .plain, target: self, action: #selector(saveNoteButtonPressed(_:)))
        shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareButtonPressed(_:)))
        editButton = UIBarButtonItem(title: "Редактировать", style: .plain, target: self, action: #selector(editButtonPressed(_:)))
        
        chooseRightBarButton()
        setupTextView()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        notesList.selectedNote = nil
    }
    
    @objc func shareButtonPressed(_ sender: Any) {
        let text = [textView.text]
        let activityViewController = UIActivityViewController(activityItems: text as [Any], applicationActivities: nil)
        present(activityViewController, animated: true, completion: {})
    }
    
    @objc func editButtonPressed(_ sender: Any) {
        if notesList.mode! == .edit  {
            if let note = notesList.selectedNote {
                editNote()
                delegate?.createNoteViewController(self, didFinishEditing: note)
                self.notesList.selectedNote = nil
//                print("\n\nif editMode && !createMode: \(note.objectID)\n\n")
            }
        }
    }
    
    @objc func saveNoteButtonPressed(_ sender: Any) {
        if notesList.mode! == .create {
            let text = textView.text!
            let note = Note(text: text, date: Date(), insertInto: notesList.managedContext)
            notesList.saveManagedContext()
//            do {
//                try notesList.managedContext.save()
//            } catch let error as NSError {
//                print("Could not save. \(error), \(error.userInfo)")
//            }
            delegate?.createNoteViewController(self, didFinishAdding: note)
        }
    }
    
    //MARK: - Private Methods
    private func editNote() {
        notesList.selectedNote?.text = textView.text
        notesList.selectedNote?.date = Date()
        notesList.saveManagedContext()
    }
    
    private func setupTextView() {
        textView.contentInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        textView.text = notesList?.selectedNote?.text ?? ""
        if notesList.mode! == .share {
            textView.isEditable = false
            textView.resignFirstResponder()
        } else {
            textView.isEditable = true
            textView.becomeFirstResponder()
        }
    }
    
    private func chooseRightBarButton() {
        if let mode = notesList.mode {
            switch mode {
            case .create:
                navigationItem.rightBarButtonItem = saveButton
            case .edit:
                navigationItem.rightBarButtonItem = editButton
            case .share:
                navigationItem.rightBarButtonItem = shareButton
            }
        } else {
            print("Mode is \(String(describing: notesList.mode))")
        }
    }

}
