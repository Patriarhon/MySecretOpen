//
//  StorageModule.swift
//  My Secret
//
//  Created by Petr on 26.05.2020.
//  Copyright © 2020 Petr. All rights reserved.
//

import Foundation
import CloudKit
import Alamofire
import SwiftyJSON

extension API {
    class SearchModule {
        static func getFilteredNotes(headingFilter: String, beginDate: Date?, endDate: Date?, limit: Int, cursor: CKQueryOperation.Cursor? = nil ,success: @escaping ([Story]) -> (), failure: @escaping (Error) -> ()) {
            
            let headingPredicate = headingFilter.isEmpty && beginDate != nil && endDate != nil ? NSPredicate(value: true) : NSPredicate(format: "allTokens TOKENMATCHES[cdl] %@", headingFilter)
            
//            var predicates = [NSPredicate]()
//            predicates.append(NSPredicate(format: "heading BEGINSWITH %@", headingFilter))
//            predicates.append(NSPredicate(format: "heading BEGINSWITH %@", headingFilter.capitalized))
//            predicates.append(NSPredicate(format: "heading BEGINSWITH %@", headingFilter.lowercased()))
//            predicates.append(NSPredicate(format: "heading BEGINSWITH %@", headingFilter.uppercased()))
            
//            let headingPredicate = NSPredicate(format: "heading BEGINSWITH %@", headingFilter)
            var datePredicate = NSPredicate(value: true)
            if let beginDate = beginDate, let endDate = endDate {
                datePredicate = NSPredicate(format: "date >= %@ and date < %@", beginDate as CVarArg, endDate as CVarArg)
            }
            
            let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [headingPredicate, datePredicate])
            
            let sort = NSSortDescriptor(key: "date", ascending: false)
            let query = CKQuery(recordType: "Story", predicate: compoundPredicate)
            query.sortDescriptors = [sort]
            
            let operation = CKQueryOperation(query: query)
            operation.desiredKeys = ["date", "heading", "photos", "place", "text", "headingColor", "placeColor", "textColor", "headingFontNumber", "placeFontNumber", "textFontNumber", "audio", "video"]
            operation.resultsLimit = limit
            
            var newStories = [Story]()
            
            operation.recordFetchedBlock = { record in
                if let story = Story(from: record) {
                    newStories.append(story)
                }
            }
            
            operation.queryCompletionBlock = { (cursor, error) in
                DispatchQueue.main.async {
                    if error == nil {
                        success(newStories)
                    } else {
                        failure(error!)
                    }
                }
            }
            
            privateDB.add(operation)
        }
    }
}
