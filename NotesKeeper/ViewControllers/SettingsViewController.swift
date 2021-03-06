//
//  SettingsViewController.swift
//  NotesKeeper
//
//  Created by Stas Shetko on 1/05/19.
//  Copyright © 2019 Stas Shetko. All rights reserved.
//

import UIKit
import CoreData

/// Number of seconds to delay pagination to see ActivityIndicator
var DELAY = 1

protocol SettingsViewControllerDelegate: class {
    func settingsViewController(_ controller: SettingsViewController, didFinishSetting noteList: NotesList)
}

class SettingsViewController: UITableViewController {

    @IBOutlet weak var delayWhilePaginating: UITextField!
    @IBOutlet weak var numberOfRowsTextField: UITextField!
    var notesList: NotesList!
    weak var delegate: SettingsViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delayWhilePaginating.delegate = self
        numberOfRowsTextField.delegate = self
    }
    
    @IBAction func acceptSettings(_ sender: Any) {
        notesList.notes.removeAll()
        if let numberOfRows = Int(numberOfRowsTextField.text!) {
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            do {
                try self.notesList.managedContext.execute(deleteRequest)
            } catch let error as NSError {
                print("Could not delete all data. \(error), \(error.userInfo)")
            }
            createDummyNotes(with: numberOfRows)
        }
        
        if let delayStr = delayWhilePaginating.text, let delay = Int(delayStr) {
            DELAY = delay
        }
        notesList.isUpdated = false
        delegate?.settingsViewController(self, didFinishSetting: self.notesList)
    }
    
    @IBAction func deleteAllData(_ sender: Any?) {
        let alertVC = UIAlertController(title: "Удаление удалось", message: nil, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default) { (action) in
            self.notesList.notes.removeAll()
            }
        alertVC.addAction(alertAction)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try self.notesList.managedContext.execute(deleteRequest)
            present(alertVC, animated: true, completion: nil)
        } catch let error as NSError {
            print("Could not delete all data. \(error), \(error.userInfo)")
        }
        notesList.notes.removeAll()
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

extension SettingsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        delayWhilePaginating.resignFirstResponder()
        numberOfRowsTextField.resignFirstResponder()
        return true
    }
}
