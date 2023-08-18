//
//  ViewController.swift
//  ToDo
//
//  Created by Nevin Özkan on 14.08.2023.
//

import UIKit
import CoreData

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {

    var models : [(title: String, note: String)] = []
    @IBOutlet weak var myTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myTableView.dataSource = self
        myTableView.delegate = self
        fetchData()
        
        func fetchData() {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
            do {
                let result = try context.fetch(fetchRequest)
                for data in result as! [NSManagedObject] {
                    let title = data.value(forKey: "title") as! String
                    let note = data.value(forKey: "note") as! String
                    models.append((title: title, note: note))
                }
            } catch {
                print("Failed to fetch data")
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return models.count
       }
       
       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
           
           let row = models[indexPath.row]
           
           cell.textLabel?.text = row.title
           cell.detailTextLabel?.text = row.note
           
           return cell
       }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let model = models[indexPath.row]
        
        guard let vc = storyboard?.instantiateViewController(identifier: "NoteViewController") as? NoteViewController else { return }
        
        vc.title = "Note"
        vc.noteTitle = model.title
        vc.note = model.note
        
        vc.managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        navigationController?.pushViewController(vc, animated: true)
    }
    

    @IBAction func btnAdd(_ sender: Any) {
        guard let vc = storyboard?.instantiateViewController(identifier: "NewViewController") as? NewViewController else { return }
        
        vc.title = "New Note"
        
        vc.completion = { [weak self] noteTitle, note in
            guard let self = self else { return }
            
            if !noteTitle.isEmpty, !note.isEmpty {
                // Core Data üzerine veri ekleme
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
                let entity = NSEntityDescription.entity(forEntityName: "Note", in: context)!
                let newNote = NSManagedObject(entity: entity, insertInto: context)
                newNote.setValue(noteTitle, forKey: "title")
                newNote.setValue(note, forKey: "note")
                
                appDelegate.saveContext() // Veriyi kaydet
                
                // Veriyi modele ekleme
                    self.models.append((title: noteTitle, note: note))
                
                // Tabloyu güncelleme
                    self.myTableView.reloadData()
                
                self.navigationController?.popToRootViewController(animated: true)
                
                
            } else {
                // ...
            }
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }

    
   
}

extension HomeViewController {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: nil) { (action, sourceView, completionHandler) in
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let itemToRemove = self.models[indexPath.row]
            
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Note")
            fetchRequest.predicate = NSPredicate(format: "title == %@", itemToRemove.title)
            
            if let objectToDelete = try? context.fetch(fetchRequest).first as? NSManagedObject {
                context.delete(objectToDelete)
                appDelegate.saveContext()
                
                self.models.remove(at: indexPath.row)
                self.myTableView.reloadData()
            }
            
            completionHandler(true)
        }
        
        delete.image = UIImage(systemName: "trash")
        delete.backgroundColor = .red
        
        return UISwipeActionsConfiguration(actions: [delete])
    }
}


