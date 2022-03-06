//
//  AppDelegate.swift
//  PeggleClone
//
//  Created by Kyle キラ on 21/1/22.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

            registerUserDefaults()

            let defaults = UserDefaults.standard
            let isPreloaded = defaults.bool(forKey: "isPreloaded")
            if !isPreloaded {
                preloadData()
                defaults.set(true, forKey: "isPreloaded")
            }

            return true
        }

    //https://gist.github.com/xavierchia/ef43abb270003ae63e5bbb7eb5404645
    func preloadData() {
        let sourceSqliteURLs = [
            Bundle.main.url(forResource: "PeggleClone", withExtension: "sqlite"),
            Bundle.main.url(forResource: "PeggleClone", withExtension: "sqlite-wal"),
            Bundle.main.url(forResource: "PeggleClone", withExtension: "sqlite-shm")]

        let destSqliteURLs = [
            URL(fileURLWithPath: NSPersistentContainer.defaultDirectoryURL().relativePath + "/PeggleClone.sqlite"),
            URL(fileURLWithPath: NSPersistentContainer.defaultDirectoryURL().relativePath + "/PeggleClone.sqlite-wal"),
            URL(fileURLWithPath: NSPersistentContainer.defaultDirectoryURL().relativePath + "/PeggleClone.sqlite-shm")]

        for index in 0...sourceSqliteURLs.count - 1 {
            do {
                guard let sqLiteURL = sourceSqliteURLs[index] else {
                    return
                }

                try FileManager.default.copyItem(
                    at: sqLiteURL,
                    to: destSqliteURLs[index])
            } catch {
            }
        }
    }

    private func registerUserDefaults() {
        UserDefaults.standard.register(defaults: [
            "CreateNewBoardText": "New...",
            "pegRadius": 20.0,
            "ballRadius": 20.0,
            "blockMass": 10.0,
            "cannonAnchorY": 0.45,
            "ballLaunchSpeed": 800.0,
            "bucketSpeed": 100.0,
            "ballMinimumVelocityY": 50.0,
            "ballMinimumAcceralationY": 50.0,
            "cannonRotationOffset": 300.0,
            "gameGravity": 500.0,
            "immovableMass": 10_000.0,
            "explosionRadius": 200.0,
            "explosionMultiplier": 300.0,
            "loadPageTitle": "Design Levels",
            "playBoardsPageTitle": "Select Level"
        ])
    }

    // MARK: UISceneSession Lifecycle

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions) -> UISceneConfiguration {

            UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
        }

    func application(
        _ application: UIApplication,
        didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {

        }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "PeggleClone")
        container.loadPersistentStores(completionHandler: { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

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

}
