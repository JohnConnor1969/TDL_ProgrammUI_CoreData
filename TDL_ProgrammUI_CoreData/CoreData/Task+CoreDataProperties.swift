//
//  Task+CoreDataProperties.swift
//  TDL_ProgrammUI_CoreData
//
//  Created by Valeriy Pokatilo on 21.08.2020.
//  Copyright © 2020 Valeriy Pokatilo. All rights reserved.
//
//

import Foundation
import CoreData


extension Task {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Task> {
        return NSFetchRequest<Task>(entityName: "Task")
    }

    @NSManaged public var name: String?

}
