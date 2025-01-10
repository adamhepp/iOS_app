//
//  TodayViewController.swift
//  TodayExtApp
//
//  Created by Adam Hepp on 12/13/19.
//  Copyright © 2019 Adam Hepp. All rights reserved.
//

import UIKit
import NotificationCenter
import CoreData
import SwiftUI

var nextTest = upcomingTest()

class TodayViewController: UIViewController, NCWidgetProviding {
    
    // MARK: - Core Data
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSCustomPersistentContainer(name: "Remind_SwiftUI")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    private var fetchedResultsController: NSFetchedResultsController<Test>!
    
    // MARK: - Extension setup
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let managedContext = persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<Test>(entityName: "Test")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Test.date), ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "date >= %@", argumentArray: [Date()])
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedContext, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try fetchedResultsController.performFetch()
            if fetchedResultsController.fetchedObjects?.first == nil {
                nextTest.date = Date()
                nextTest.subject = ""
                nextTest.type = ""
            } else {
                nextTest.date = (fetchedResultsController.fetchedObjects?.first!.date)!
                nextTest.subject = (fetchedResultsController.fetchedObjects?.first!.subject)!
                nextTest.type = (fetchedResultsController.fetchedObjects?.first!.type)!
            }
        } catch let error as NSError {
            print("\(error.userInfo)")
        }
        
        fetchedResultsController.delegate = self
    }
    
    // MARK: - Hosting SwiftUI in UIKit
    
    @IBSegueAction func addSwiftUIView(_ coder: NSCoder) -> UIViewController? {
        return UIHostingController(coder: coder, rootView: WidgetView())
    }
    
    // MARK: - Widget update method
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        completionHandler(NCUpdateResult.newData)
    }
    
}

// MARK: - SwiftUI View

struct WidgetView: View {
    
    // MARK: - View body
    
    var body: some View {
        
        VStack(alignment: .center) {
            Text(nextTest.type == "" ? "No upcoming tests" : nextTest.type)
                .font(.title)
            Text(nextTest.type == "" ? "" : nextTest.subject)
                .font(.headline)
            Text(nextTest.type == "" ? "" : formatDateAndTime(date: nextTest.date))
                .font(.caption)
        }
        
    }
    
}

// MARK: - NSFetchedResultsControllerDelegate protocol

extension TodayViewController: NSFetchedResultsControllerDelegate {}
