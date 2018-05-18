//
//  TodoListViewController.swift
//  Todoey
//
//  Created by Matej Taborsky on 10/05/2018.
//  Copyright © 2018 Matej Taborsky. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipetTableViewController {

    var todoItems: Results<TodoListItem>?
    let realm = try! Realm()
    
    var categorySelected: Category? {
        didSet {
            loadItems()
        }
    }
    
    @IBOutlet weak var addNewItem: UIBarButtonItem!
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 80.0
        tableView.separatorStyle = .none
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        guard let colorHex = categorySelected?.bgColor
            else { fatalError() }
        
        guard let navBar = navigationController?.navigationBar
            else { fatalError("Navigation controller does not exist") }
        
        guard let navbarColor = UIColor(hexString: colorHex)
            else { fatalError() }
        
        tableView.backgroundColor = UIColor(hexString: colorHex)
            
        title = categorySelected?.name
        
        navBar.barTintColor = navbarColor
        
        navBar.tintColor = ContrastColorOf(navbarColor, returnFlat: true)
        
        navBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: ContrastColorOf(navbarColor, returnFlat: true)]
        
        searchBar.barTintColor = navbarColor
        searchBar.searchBarStyle = .minimal

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.barTintColor = FlatGray()
        navigationController?.navigationBar.tintColor = FlatWhite()
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: FlatWhite()]
        
    }
    
    
    // MARK: - Tableview Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = todoItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            cell.accessoryType = item.status ? .checkmark : .none
            
            if let color = UIColor(hexString: categorySelected!.bgColor)!.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(todoItems!.count)) {
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
                cell.tintColor = ContrastColorOf(color, returnFlat: true)
            }
            
            
        } else {
            cell.textLabel?.text = "No items added"
        }
        
        return cell
    }
    
    
    //MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    item.status = !item.status
                }
            } catch {
                print("Error saving done status, \(error)")
            }
        }
        
        tableView.reloadData()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    // MARK: - Add new Items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoy Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
            if let currentCategory = self.categorySelected {
                do {
                    try self.realm.write {
                        let newTodoItem = TodoListItem()
                        newTodoItem.title = textField.text!
                        newTodoItem.date = Date()
                        currentCategory.items.append(newTodoItem)
                    }
                } catch {
                    print("Error saving new items, \(error)")
                }
            }
            
            self.tableView.reloadData()

        }
        
        alert.addTextField { (alertTextField: UITextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    
    // Mark: - Mode Manupulation Methods
    func loadItems () {

        todoItems = categorySelected?.items.sorted(byKeyPath: "date", ascending: true)
        
        tableView.reloadData()
    }

    override func updateModel(at indexPath: IndexPath) {
        if let todoForDeletion = self.todoItems?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(todoForDeletion)
                }
            } catch {
                print("Error deleting category, \(error)")
            }
        }
    }
}

//MARK: - SEARCH BAR
extension TodoListViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "title", ascending: true)
        
        tableView.reloadData()

    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()

            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}

