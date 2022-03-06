//
//  CoreDataStack.swift
//  PeggleClone
//
//  Created by Kyle キラ on 6/2/22.
//

import UIKit
import CoreData

class CoreDataStack {
    static let shared = CoreDataStack()

    let persistentContainer: NSPersistentContainer
    let backgroundContext: NSManagedObjectContext
    let mainContext: NSManagedObjectContext

    private init() {
        persistentContainer = NSPersistentContainer(name: "PeggleClone")

        let description = persistentContainer.persistentStoreDescriptions.first
        description?.type = NSSQLiteStoreType

        persistentContainer.loadPersistentStores { _, error in
            guard error == nil else {
                fatalError("was unable to laod store \(error!)")
            }
        }

        mainContext = persistentContainer.viewContext

        backgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        backgroundContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        backgroundContext.parent = self.mainContext
    }
}
