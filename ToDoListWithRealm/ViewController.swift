//
//  ViewController.swift
//  ToDoListWithRealm
//
//  Created by Artak Ter-Stepanyan on 09.02.24.
//

import UIKit
import RealmSwift

class ViewController: UIViewController {
    
    let realm = try? Realm()
    
    @IBOutlet weak var toDoTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    
    
    @IBAction func addToDo(_ sender: Any) {
        let alert = UIAlertController(title: "New Item", message: "Enter new Item", preferredStyle: .alert)
        
        alert.addTextField(configurationHandler: nil)
        alert.addAction(UIAlertAction(title: "Submit", style: .cancel, handler: {[weak self] _ in
            guard let field = alert.textFields?.first, let text = field.text, !text.isEmpty else {
                return
            }
            self?.createItem(text: text)
        }))
        present(alert, animated: true)
    }
    
    func createItem(text: String) {
        let todo = ToDo()
        todo.task = text
        
        realm?.beginWrite()
        realm?.add(todo)
        toDoTableView.reloadData()
        try? realm?.commitWrite()
    }
    
    func editItem(todo: ToDo, newText: String) {

        realm?.beginWrite()

        todo.task = newText
        
        do {
            try realm?.commitWrite()
            toDoTableView.reloadData()
        } catch {
            print("Error editing item: \(error)")
        }
    }
    
    func deleteItem(todo: ToDo) {
        realm?.beginWrite()
        realm?.delete(todo)
        toDoTableView.reloadData()
        try? realm?.commitWrite()
    }
}


class ToDo: Object {
    @objc dynamic var task: String = ""
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return realm?.objects(ToDo.self).count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = toDoTableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath)
        
        if let todo = realm?.objects(ToDo.self)[indexPath.row] {
                   cell.textLabel?.text = todo.task
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        toDoTableView.deselectRow(at: indexPath, animated: true)
        let item = realm?.objects(ToDo.self)[indexPath.row]
        let sheet = UIAlertController(title: "Edit", message: nil, preferredStyle: .actionSheet)

        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        sheet.addAction(UIAlertAction(title: "Edit", style: .default, handler: { _ in

            let alert = UIAlertController(title: "Edit Item", message: "Enter your Item", preferredStyle: .alert)

            alert.addTextField(configurationHandler: nil)
            alert.textFields?.first?.text = item?.task
            alert.addAction(UIAlertAction(title: "Save", style: .cancel, handler: {[weak self] _ in
                guard let field = alert.textFields?.first, let newTask = field.text, !newTask.isEmpty else {
                    return
                }

                self?.editItem(todo: item!, newText: newTask)
            }))
            self.present(alert, animated: true)

        }))
        sheet.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            self.deleteItem(todo: item!)
        }))
        present(sheet, animated: true)
    }
}

