//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Harshita Gali on 15/09/2022.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    var categoryArray : Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadCategories()
        tableView.separatorStyle = .none

    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let navBar = navigationController?.navigationBar else{
            fatalError("Navigation controller does not exist")
        }
        navBar.backgroundColor = UIColor(hexString: "1D9BF6")
    }
    
    //MARK: -TableView DataSource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray?.count ?? 1
    }
   
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       // Fetch a cell of the appropriate type.
       
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
       // Configure the cell’s contents

       if let category  = categoryArray?[indexPath.row]{
            guard let categoryColor = UIColor(hexString: category.color)else{
                fatalError()
            }
            cell.textLabel!.text = categoryArray?[indexPath.row].name ?? "No Categories Added yet"
            cell.backgroundColor = categoryColor
            cell.textLabel?.textColor = ContrastColorOf(categoryColor, returnFlat: true)
        }
       
    
       return cell
    }

    
    //MARK: -TableView Manipulation Methods
    
    func save(category : Category){
        do{
            try realm.write{
            try realm.add(category)
            }
        }catch{
            print("Cannot save new categories \(error)")
        }
        tableView.reloadData()
    }
    
    func loadCategories(){
        
        //Realm Code
        categoryArray = realm.objects(Category.self)
        
        tableView.reloadData()
        
        //CoreData code
//        let request :  NSFetchRequest<Category>= Category.fetchRequest()
//        do{
//        categoryArray = try context.fetch(request)
//
//        }catch{
//            print("Cannot save new categories \(error)")
//        }
//        tableView.reloadData()
    }
    
    //Delete data from Swipe
    
    override func updateModel(at indexPath: IndexPath) {
        if let categoryForDeletion = self.categoryArray?[indexPath.row]{
            do{
                try self.realm.write{
                    try self.realm.delete(categoryForDeletion)
                }
            }catch{
                print("Error Deleting a row , \(error)")
            }
        }
    }

    
    //MARK: -add new Categories
    
    @IBAction func AddButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
         
         let alert = UIAlertController(title: "Add new Category", message: "", preferredStyle: .alert)
         
         let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
             //what will happen once the user clicks the Add Item button onour UIAlert
             let newCategory = Category()
             newCategory.name = textField.text!
             newCategory.color = UIColor.randomFlat().hexValue()

             self.save(category: newCategory)
             }
             alert.addTextField { (field) in
                 field.placeholder = " Create new Category"
             textField = field
             }
         
         alert.addAction(action)
         present(alert, animated: true, completion: nil)
         
        
    }
        
    //MARK: -TableView Deligate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow{
            destinationVC.selectedCategory = categoryArray?[indexPath.row]
            
        }
    }
}


