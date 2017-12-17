//
//  FeedController.swift
//  NewsApps
//
//  Created by xcode on 17.10.2017.
//  Copyright © 2017 VSU. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import SafariServices

class FeedController: UIViewController, UITableViewDataSource {
    
    lazy var model = FeedModel(with: UIApplication.container)
    
    private lazy var fetchedResultsController: NSFetchedResultsController<FeedItemMO> = {
        let request: NSFetchRequest<FeedItemMO> = FeedItemMO.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "pubDate", ascending: false)]
        request.predicate = NSPredicate(format: "source.isEnabled = true")
        
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: model.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        performFetch()
        model.retreiveFeed()
    }
    
    private func performFetch() {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print(error)
        }
    }
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int
    {
        guard let objects = fetchedResultsController.fetchedObjects else { return 0 }
        return objects.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath)
        if let newsCell = cell as? NewsCell,
            let items = fetchedResultsController.fetchedObjects
        {
            let feedItem = items[indexPath.row]
            newsCell.newsTitleLabel.text = feedItem.title
            newsCell.newsDescriptionLabel.text = feedItem.desc
        }
        return cell
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String,
                                     sender: Any?) -> Bool {
        guard identifier == "feedDetails", let index = tableView.indexPathForSelectedRow?.row,
            let items = fetchedResultsController.fetchedObjects else { return true }
        
        let item = items[index]
        if item.content != nil {
            return true
        } else {
            present(SFSafariViewController(url: item.url), animated: true, completion: nil)
            return false
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch segue.destination {
        case let viewController as FeedDetailsController:
            guard let index = tableView.indexPathForSelectedRow?.row,
                let items = fetchedResultsController.fetchedObjects else {
                    assertionFailure("Something went wrong!")
                    return
            }
            viewController.feedItem = items[index]
            
        default:
            assertionFailure("Handle transition to \(segue.destination)")
        }
    }
}

extension FeedController: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>)
    {
        tableView.reloadData()
    }
}
