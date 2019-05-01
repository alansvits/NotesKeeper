//
//  CreateNoteViewController.swift
//  NotesKeeper
//
//  Created by Stas Shetko on 26/04/19.
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
    var notesList: NotesList!
    
    //MARK: - METHODS
    override func viewDidLoad() {
        super.viewDidLoad()
        
        saveButton = UIBarButtonItem(title: "Сохранить", style: .plain, target: self, action: #selector(saveNoteButtonPressed(_:)))
        shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareButtonPressed(_:)))
        editButton = UIBarButtonItem(title: "Редактировать", style: .plain, target: self, action: #selector(editButtonPressed(_:)))
        
        let backButton = UIBarButtonItem(title: "Назад", style: .plain, target: self, action: #selector(backBarButtonPressed(_:)))
        
        if notesList.mode! == .create || notesList.mode! == .edit {
            navigationItem.leftBarButtonItem = backButton
        }

        chooseRightBarButton()
        setupTextView()
    }
    
    @objc func backBarButtonPressed(_ sender: Any) {
        if notesList.mode! == .create && textView.text != "" {
            let action = UIAlertController(title: "Сохранить новую заметку?", message: nil, preferredStyle: .alert)
            let alertActionYes = UIAlertAction(title: "Да", style: .default) { (action) in
                self.saveNoteButtonPressed(nil)
            }
            let alertActionNo = UIAlertAction(title: "Нет", style: .destructive) { (action) in
                self.navigationController?.popViewController(animated: true)
            }
            action.addAction(alertActionYes)
            action.addAction(alertActionNo)
            self.present(action, animated: true, completion: nil)
        } else if notesList.mode! == .edit {
            print("notesList.mode! == .edit ")
            let action = UIAlertController(title: "Сохранить изменения?", message: nil, preferredStyle: .alert)
            let alertActionYes = UIAlertAction(title: "Да", style: .default) { (action) in
                self.editButtonPressed(nil)
            }
            let alertActionNo = UIAlertAction(title: "Нет", style: .destructive) { (action) in
                self.navigationController?.popViewController(animated: true)
            }
            action.addAction(alertActionYes)
            action.addAction(alertActionNo)
            self.present(action, animated: true, completion: nil)
        } else {
            print("notesList else")
            self.navigationController?.popViewController(animated: true)
        }

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
    
    @objc func editButtonPressed(_ sender: Any?) {
        if notesList.mode! == .edit  {
            if let note = notesList.selectedNote {
                editNote()
                delegate?.createNoteViewController(self, didFinishEditing: note)
                self.notesList.selectedNote = nil
            }
        }
    }
    
    @objc func saveNoteButtonPressed(_ sender: Any?) {
        if notesList.mode! == .create {
            let text = textView.text!
            let note = Note(text: text, date: Date(), insertInto: notesList.managedContext)
            notesList.saveContext()
            delegate?.createNoteViewController(self, didFinishAdding: note)
        }
    }
    
    //MARK: - Private Methods
    private func editNote() {
        notesList.selectedNote?.text = textView.text
        notesList.selectedNote?.date = Date()
        notesList.saveContext()
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
