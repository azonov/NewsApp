//
//  SettingsController.swift
//  NewsApps
//
//  Created by xcode on 12.12.2017.
//  Copyright © 2017 VSU. All rights reserved.
//

import UIKit
import CoreData

class SettingsController: UITableViewController {
    
    private static let cellIdentifier = "cellWithSwitch"
    
    lazy var model = SettingsModel(with: UIApplication.container)
    
    private lazy var fetchedResultsController: NSFetchedResultsController<SourceMO> = {
        let request: NSFetchRequest<SourceMO> = SourceMO.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "url", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: model.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        performFetch()
    }
    
    private func performFetch() {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print(error)
        }
    }
    
    override func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int
    {
        guard let objects = fetchedResultsController.fetchedObjects else { return 0 }
        return objects.count
    }
    
    override func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: SettingsController.cellIdentifier,
                                                 for: indexPath)
        
        if let newsCell = cell as? SwitchCell,
            let items = fetchedResultsController.fetchedObjects
        {
            let source = items[indexPath.row]
            newsCell.title.text = source.name
            newsCell.switchControl.isOn = source.isEnabled
            newsCell.actionClosure = { [weak self] isOn in
                source.isEnabled = isOn
                self?.model.save(source: source)
            }
        }
        
        return cell
    }
}

extension SettingsController: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>)
    {
        tableView.reloadData()
    }
}
