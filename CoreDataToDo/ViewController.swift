//
//  ViewController.swift
//  CoreDataSwiftBook2
//
//  Created by Эдип on 27.09.2021.
//


import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let tableView: UITableView = {
        let mytableView = UITableView()
        mytableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        return mytableView
    }()
    
    var toDoItems: [Task] = []
    
    override func viewWillAppear(_ animated: Bool) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        
        do {
            toDoItems = try context.fetch(fetchRequest)
        } catch  {
            print(error.localizedDescription)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tableView)
        tableView.frame = view.bounds
    
        navigationItem.title = "To Do List"
        //navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))
        
        
        tableView.delegate = self
        tableView.dataSource = self
    }

    
    @objc func didTapAdd() {
        let alertcController = UIAlertController(title: "Add Task", message: "add new task", preferredStyle: .alert)
        let okAlertAction = UIAlertAction(title: "Ok", style: .default) {action in
            let textField = alertcController.textFields?[0]
            self.saveTask(taskToDo: (textField?.text)!)
            self.tableView.reloadData()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertcController.addTextField { textField in
            textField.placeholder = "Enter new item"
        }
        alertcController.addAction(okAlertAction)
        alertcController.addAction(cancelAction)
        present(alertcController, animated: true, completion: nil)
    }
    
    func saveTask(taskToDo: String) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "Task", in: context)
        let taskObject = NSManagedObject(entity: entity!, insertInto: context) as! Task
        taskObject.taskToDo = taskToDo
        
        do {
            try context.save()
            toDoItems.append(taskObject)
            print("Saved")
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toDoItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let task = toDoItems[indexPath.row]
        cell.textLabel?.text = task.taskToDo
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
            
            context.delete(toDoItems[indexPath.row])
          
            do {
                try context.save()
            } catch let errror as NSError {
                print(errror.localizedDescription)
            }
            
            tableView.reloadData()
        }
    }

}

