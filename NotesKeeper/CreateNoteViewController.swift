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
}

class CreateNoteViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    
    weak var delegate: CreateNoteViewControllerDelegate?
    var saveButton: UIBarButtonItem!
    var editMode = true
    var note: Note?
    var managedContext: NSManagedObjectContext!
//    var noteText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        saveButton = UIBarButtonItem(title: "Сохранить", style: .plain, target: self, action: #selector(saveNoteButtonPressed(_:)))
        showSaveButton(mode: editMode)

        textView.contentInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        textView.text = note?.text ?? ""
        setupTextView(mode: editMode)
        
    }
    
    @objc func saveNoteButtonPressed(_ sender: Any) {
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
    
    private func showSaveButton(mode: Bool) {
        if !mode {
            navigationItem.rightBarButtonItem = nil
        } else {
            navigationItem.rightBarButtonItem = saveButton
        }
    }
    
    private func setupTextView(mode: Bool) {
        if mode {
            textView.isEditable = true
            textView.becomeFirstResponder()
        } else {
            textView.isEditable = false
            textView.resignFirstResponder()
        }
    }

}
