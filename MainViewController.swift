//
//  MainViewController.swift
//  NotesKeeper
//
//  Created by Stas Shetko on 4/04/19.
//  Copyright © 2019 Stas Shetko. All rights reserved.
//

import UIKit

class MainViewController: UITableViewController {

    var notes = [Note]()
    
    private func dummyNotes(from text: [String]) -> [Note] {
        var notes = [Note]()
        for item in text {
            notes.append(Note(text: item, date: Date()))
        }
        return notes
    }
  
    let testContent = ["testing test testing test testingtesting testing test testing test testing test testing test testing test testing 100t ", "testing2 test2 testing", "testing3 test3 testing3 test3 testing3 test3 testing3 test3 testing3 test3 testing3 test3 testing3 test3 ", "testing4 test4 testing4 test4 testing4 test4 testing4 test4 /ntesting4 test4 testing4 test4 testing4 test4 testing4 test4 testing4 test4 testing4 test4 testing4 test4 testing4 test4 testing4 test4 testing4 test4 testing4 test4 testing4 test4 testing4 test4 testing4 test4 testing4 test4 testing4 test4 testing4 test4 testing4 test4 testing4 test4 testing4 test4 testing4 test4 testing4 test4 testing4 test4 testing4 test4 testing4 test4 testing4 test4 testing4 test4 testing4 test4 testing4 test4 testing4 test4 testing4 test4 testing4 test4 testing4 test4 "]

    override func viewDidLoad() {
        super.viewDidLoad()

        notes = dummyNotes(from: testContent)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoteItem", for: indexPath) as! NoteTableViewCell
        let note = notes[indexPath.row]
        cell.noteLabel.text = note.text
        cell.dateLabel.text = note.dateString
        cell.timeLabel.text = note.timeString

        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DetailNoteSegue" {
            let controller = segue.destination as! CreateNoteViewController
            let cell = sender as! NoteTableViewCell
            controller.noteText = cell.noteLabel.text!
            controller.editMode = false
        }
        if segue.identifier == "CreateNewNoteSegue" {
            let controller = segue.destination as! CreateNoteViewController
            controller.delegate = self
        }
    }

}

extension MainViewController: CreateNoteViewControllerDelegate {
    func createNoteViewController(_ controller: CreateNoteViewController, didFinishAdding note: Note) {
        notes.append(note)
        tableView.reloadData()
        navigationController?.popViewController(animated: true)
    }
}
