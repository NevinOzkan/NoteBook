//
//  NoteViewController.swift
//  ToDo
//
//  Created by Nevin Özkan on 14.08.2023.
//

import UIKit
import CoreData

class NoteViewController: UIViewController {
    
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var textViewSubTitle: UITextView!
    
    public var noteTitle = String()
    public var note = String()
    public var managedObjectContext: NSManagedObjectContext?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        labelTitle.text = noteTitle
        textViewSubTitle.text = note
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveButtonTapped(_:)))
 
    }
    
    
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        // Güncelleme işlemleri burada yapılacak.
        if let updatedNote = textViewSubTitle.text, let managedObjectContext = managedObjectContext {
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Note")
            fetchRequest.predicate = NSPredicate(format: "title == %@", noteTitle)
            
            do {
                if let objectToUpdate = try managedObjectContext.fetch(fetchRequest).first as? NSManagedObject {
                    objectToUpdate.setValue(updatedNote, forKey: "note")
                    
                    try managedObjectContext.save()
                    
                    note = updatedNote
                    textViewSubTitle.text = updatedNote
                }
            } catch {
                print("Failed to update note: \(error)")
            }
        }
    }
}
