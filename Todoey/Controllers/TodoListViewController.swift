//
//  TodoListViewController.swift
//  Todoey
//
//  Created by Matej Taborsky on 10/05/2018.
//  Copyright © 2018 Matej Taborsky. All rights reserved.
//

import UIKit

class TodoListViewController: UITableViewController {

    var itemArray = [TodoListItem]()
    
    let todolistarrayKey = "TodoListArray"
    
    let defaults = UserDefaults.standard
    
    @IBOutlet weak var addNewItem: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let newItem = TodoListItem()
        newItem.title = "Kupit plienky"
        itemArray.append(newItem)
        
        let newItem1 = TodoListItem()
        newItem1.title = "Kupit podlozky"
        itemArray.append(newItem1)
        
        let newItem2 = TodoListItem()
        newItem2.title = "Kupit parene buchty"
        itemArray.append(newItem2)
        
        if let items = defaults.array(forKey: todolistarrayKey) as? [TodoListItem] {
            itemArray = items
        }

    }
    
    // MARK: - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        let item: TodoListItem = itemArray[indexPath.row]
        
        cell.textLabel?.text = item.title
        
        cell.accessoryType = item.status ? .checkmark : .none
        
        return cell
    }
    
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        itemArray[indexPath.row].status = !itemArray[indexPath.row].status
        
        tableView.reloadData()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    
    // MARK: - Add new Items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoy Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            let newTodoItem = TodoListItem()
            newTodoItem.title = textField.text!
            
            self.itemArray.append(newTodoItem)
            
            self.defaults.set(self.itemArray, forKey: self.todolistarrayKey)
            
            self.tableView.reloadData()
        }
        
        alert.addTextField { (alertTextField: UITextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
}
