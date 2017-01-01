//
//  Photo+CoreDataProperties.swift
//  Virtual Tourist
//
//  Created by Michael Kroth on 1/1/17.
//  Copyright © 2017 MGK Technology Solutions, LLC. All rights reserved.
//

import Foundation
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo");
    }

    @NSManaged public var data: NSData?
    @NSManaged public var url: String?
    @NSManaged public var pin: Pin?

}
