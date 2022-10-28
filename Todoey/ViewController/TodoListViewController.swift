//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    var itemArray : Results<Item>?
  
    @IBOutlet weak var searchBar: UISearchBar!
    
    var selectedCategory : Category?{
        didSet{
            loadData()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tableView.separatorStyle = .none
        
    }
    override func viewWillAppear(_ animated: Bool) {
        if let colorHex = selectedCategory?.color{
            title = selectedCategory!.name
   
            guard let navBar = navigationController?.navigationBar else{
                fatalError("Navigation controller does not exist")
            }
            if let navBarColor = UIColor(hexString: colorHex){
                navBar.backgroundColor = navBarColor
                searchBar.barTintColor = navBarColor
                navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(navBarColor, returnFlat: true) ]
                navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
            }
            }
           
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Fetch a cell of the appropriate type.
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        // Configure the cell’s contents.
        if let item = itemArray?[indexPath.row] {
            cell.textLabel!.text = item.title
            
            if let color = UIColor(hexString: selectedCategory!.color)?.darken(byPercentage: (CGFloat(indexPath.row)/CGFloat(itemArray!.count))){
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }
            
            cell.accessoryType = item.done ? .checkmark : .none
        }
        else{
            cell.textLabel?.text = "No items added"
        }
        
        
        //        if item.done == true{
        //            cell.accessoryType = .checkmark
        //        }
        //        else{
        //            cell.accessoryType = .none
        //        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print(itemArray[indexPath.row])
        
        if let items = itemArray?[indexPath.row]{
            do{
                try realm.write{
                    //delete data
                    //realm.delete(items)
                    //update data
                    items.done = !items.done
                }
            }catch{
                print("Error saving done status \(error)")
            }
        }
        tableView.reloadData()
        
        var cellAtRowAccesoryType = tableView.cellForRow(at: indexPath)?.accessoryType
        
        if cellAtRowAccesoryType == .checkmark{
            cellAtRowAccesoryType = Optional.none
        }else{
            cellAtRowAccesoryType = .checkmark
        }
        
        tableView.reloadData()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    //MARK - Add new Items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            //what will happen once the user clicks the Add Item button onour UIAlert
            if let currentCategory = self.selectedCategory{
                do{
                    try self.realm.write{
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                    }
                }catch{
                    print("Error in adding new items \(error)")
                }
            }
            self.tableView.reloadData()
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = " Create new Item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
        
    }
    
    //MARK: -TableView manipulation items
    
    func loadData(){
        itemArray = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let itemToDelete = self.itemArray?[indexPath.row]{
            do{
                try self.realm.write{
                    try self.realm.delete(itemToDelete)
                }
            }catch{
                print("Error in deleting itema \(error)")
            }
        }
    }
}
//MARK - UISearchBarDelegate

extension TodoListViewController : UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        itemArray = itemArray?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)

        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0{
            loadData()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            
        }
    }
}
