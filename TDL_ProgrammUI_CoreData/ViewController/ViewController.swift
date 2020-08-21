//
//  ViewController.swift
//  TDL_ProgrammUI_CoreData
//
//  Created by Valeriy Pokatilo on 21.08.2020.
//  Copyright © 2020 Valeriy Pokatilo. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UITableViewController {
    
    // MARK: - Properies
    
    private let cellID = "cell"
    private let manageContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private var tasks: [Task] = []
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
    }
    
    // MARK: - Functions

    private func setupView() {
        view.backgroundColor = .white
        setupNavigationBar()
    }

    private func setupNavigationBar() {
        navigationController?.navigationBar.barTintColor = .red
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white ]

        title = "Tasks list"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add",
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(addNewTask))
        navigationController?.navigationBar.tintColor = .white
    }
    
    @objc private func addNewTask() {
        showAlert(title: "New task", message: "Enter task title.")
    }

}

// MARK: - UITableViewDataSource

extension ViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        
        let task = tasks[indexPath.row]
        cell.textLabel?.text = task.name
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension ViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID)
        
        let task = tasks[indexPath.row]
        
        showAlert(title: "Edit task", message: "Enter new value", currentTask: task) { (newValue) in
                    
            cell?.textLabel?.text = newValue
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let task = tasks[indexPath.row]
        
        if editingStyle == .delete {
            deleteTask(task, indexPath: indexPath)
        }
    }
}

// MARK: - Work with CoreData

extension ViewController {
    private func fetchDataRomDB() {
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        
        do {
            tasks = try manageContext.fetch(fetchRequest)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    private func saveToBD(_ taskName: String) {
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "Task", in: manageContext)
            else { return }
        let task = NSManagedObject(entity: entityDescription, insertInto: manageContext) as! Task
        
        task.name = taskName
        
        do {
            try manageContext.save()
            tasks.append(task)
            
            self.tableView.insertRows(at: [IndexPath(row: tasks.count - 1, section: 0)], with: .automatic)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    private func editTask(_ task: Task, newName: String) {
        do {
            task.name = newName
            try manageContext.save()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    private func  deleteTask(_ task: Task, indexPath: IndexPath) {
        manageContext.delete(task)
        
        do {
            try manageContext.save()
            tasks.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        } catch let error {
            print(error.localizedDescription)
        }
    }
}

// MARK: - Alert

extension ViewController {
    private func showAlert(title: String,
                           message: String,
                           currentTask: Task? = nil,
                           complition: ((String) -> Void)? = nil) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let save = UIAlertAction(title: "Save", style: .default) { _ in
            guard let newValue = alert.textFields?.first?.text else { return }
            guard !newValue.isEmpty else { return }
            
            currentTask != nil ? self.editTask(currentTask!, newName: newValue) : self.saveToBD(newValue)
            if complition != nil { complition!(newValue)}
        }
        
        
        let cancel = UIAlertAction(title: "Cancel", style: .destructive) { _ in
            if let indexPath = self.tableView.indexPathForSelectedRow {
                self.tableView.deselectRow(at: indexPath, animated: true)
            }
        }
        
        alert.addTextField()
        alert.addAction(save)
        alert.addAction(cancel)
        
        if currentTask != nil {
            alert.textFields?.first?.text = currentTask?.name
        }
        
        present(alert, animated: true)
    }
}

