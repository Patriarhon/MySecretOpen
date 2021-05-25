//
//  Review.swift
//  My Secret
//
//  Created by Petr on 09.08.2020.
//  Copyright © 2020 Petr. All rights reserved.
//

import Foundation
import CloudKit

struct Review {
    var name: String
    var profession: String
    var instagram: String
    var text: String
    var number: Int
    var local: String
 
    var photo: PhotoModel?
    
    init?(from record: CKRecord) {
        guard let name = record["name"] as? String,
            let profession = record["profession"] as? String,
            let instagram = record["instagram"] as? String,
            let text = record["text"] as? String,
            let number = record["number"] as? Int,
            let local = record["local"] as? String else {
                print("Can't init Review")
                return nil
        }
        
        self.name = name
        self.profession = profession
        self.instagram = instagram
        self.text = text
        self.number = number
        self.local = local
        
        if let recordPhoto = record["photo"] as? CKRecord.Reference {
            photo = PhotoModel(from: recordPhoto, image: nil)
        }
    }
    
}
