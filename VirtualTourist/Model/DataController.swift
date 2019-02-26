//
//  DataController.swift
//  VirtualTourist
//
//  Created by Salwa Tanko on 1/19/19.
//  Copyright © 2019 Udacity. All rights reserved.
//

import Foundation
import CoreData

class DataController {
    
    let persistentConainer: NSPersistentContainer
    var viewContext: NSManagedObjectContext {
        return persistentConainer.viewContext
    }
    
    init(modelName: String) {
        persistentConainer = NSPersistentContainer(name: modelName)
    }
    
    func load(completion: (() -> Void)? = nil) {
        persistentConainer.loadPersistentStores { storeDescription, error in
            
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            self.autoSaveViewContext()
            completion?()
        }
    }
}

// MARK: Autosaving

extension DataController {
    func autoSaveViewContext(interval:TimeInterval = 30) {
        print("autoSaving")
        
        guard interval > 0 else {
            print("cannot set negative autosave interval")
            return
        }
        
        if viewContext.hasChanges {
            try? viewContext.save()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            self.autoSaveViewContext(interval: interval)
        }
    }
}

