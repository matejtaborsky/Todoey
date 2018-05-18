//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Matej Taborsky on 15/05/2018.
//  Copyright © 2018 Matej Taborsky. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipetTableViewController {
    
    let realm = try! Realm()
    var categoryList: Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        loadCategories()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.rowHeight = 80.0
        tableView.separatorStyle = .none
        
        navigationController?.navigationBar.barTintColor = FlatGray()
        navigationController?.navigationBar.tintColor = FlatWhite()
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: FlatWhite()]
    }
    
    
    //
    // MARK: - ADD NEW CATEGORIES
    //
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()

        let alert = UIAlertController(title: "New Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Category", style: .default) {
            (action) in
            
            let newCategory = Category()
            newCategory.name = textField.text!
            newCategory.bgColor = UIColor.randomFlat.hexValue()
            
            self.save(category: newCategory)
        }
        
        alert.addTextField { (alertTextField: UITextField) in
            alertTextField.placeholder = "Add new category"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    
    //
    // MARK: TABLE VIEW DATASOURCE METHODS
    //
    
    // 1. Define custom cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if (categoryList?.count)! > 0 {
            let cat = categoryList?[indexPath.row]
            
            cell.textLabel?.text = cat?.name
            cell.backgroundColor = HexColor((cat?.bgColor)!)
            cell.accessoryType = .disclosureIndicator
            cell.tintColor = ContrastColorOf(cell.backgroundColor!, returnFlat: true)
            
            cell.textLabel?.textColor = ContrastColorOf(cell.backgroundColor!, returnFlat: true)
            
        } else {
            cell.textLabel?.text =  "No categories added yet!"
        }
        
        return cell
    }
    
    // 2. Define number of rows
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let _numberOfRowsInSection = categoryList?.count == 0 ? 1 : categoryList?.count ?? 1
        
        return _numberOfRowsInSection
    }
    
    
    //
    // MARK: - TABLEVIEW DELEGATE METHODS
    //
    
    // 1.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "gotoItems", sender: self)
    }
    
    // 2. Send data to todoListVC
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.categorySelected = categoryList?[indexPath.row]
        }
    }
    
    // 3. Add swipe options using UITableViewRowAction (UIContextualAction another way)
//    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
//
//        let updateHandler: (UITableViewRowAction, IndexPath) -> Void = { _, indexPath in
//            print("Update row")
//        }
//
//        let deleteHandler: (UITableViewRowAction, IndexPath) -> Void = { _, indexPath in
//
//            print("Delete row: \(String(describing: self.categoryList![indexPath.row]))")
//
//            do {
//                try self.realm.write {
//                    self.realm.delete(self.categoryList![indexPath.row])
//                }
//                tableView.reloadData()
//            } catch {
//                print("Error deleting category, \(error)")
//            }
//        }
//
//        let updateAction = UITableViewRowAction(style: .normal, title: "Update", handler: updateHandler)
//        updateAction.backgroundColor = UIColor.cyan
//
//
//        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete", handler: deleteHandler)
//
//
//        return [deleteAction, updateAction]
//    }
    
    //
    // MARK: - DATA MANIPULATION METHODS
    //

    // 1. Load data
    func loadCategories() {
        
        categoryList = realm.objects(Category.self).sorted(byKeyPath: "name", ascending: true)
        
        tableView.reloadData()
    }
    
    // 2. Save data
    func save(category: Category) {
        
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Error saving context \(error)")
        }
        
        tableView.reloadData()
    }
    
    // 3. Delete data
    override func updateModel(at indexPath: IndexPath) {
        if let categoryForDeletion = self.categoryList?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(categoryForDeletion)
                }
            } catch {
                print("Error deleting category, \(error)")
            }
        }
    }
    
}
