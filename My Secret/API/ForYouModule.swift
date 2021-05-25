//
//  ForYouModule.swift
//  My Secret
//
//  Created by Petr on 09.08.2020.
//  Copyright © 2020 Petr. All rights reserved.
//

import Foundation
import CloudKit
import Alamofire
import SwiftyJSON

extension API {
    class ForYouModule {
            static func getReviews(limit: Int, cursor: CKQueryOperation.Cursor? = nil ,success: @escaping ([Review]) -> (), failure: @escaping (Error) -> ()) {
                
    //            let headingPredicate = headingFilter.isEmpty && beginDate != nil && endDate != nil ? NSPredicate(value: true) : NSPredicate(format: "allTokens TOKENMATCHES[cdl] %@", headingFilter)
                
    //            var predicates = [NSPredicate]()
    //            predicates.append(NSPredicate(format: "heading BEGINSWITH %@", headingFilter))
    //            predicates.append(NSPredicate(format: "heading BEGINSWITH %@", headingFilter.capitalized))
    //            predicates.append(NSPredicate(format: "heading BEGINSWITH %@", headingFilter.lowercased()))
    //            predicates.append(NSPredicate(format: "heading BEGINSWITH %@", headingFilter.uppercased()))
                
    //            let headingPredicate = NSPredicate(format: "heading BEGINSWITH %@", headingFilter)
    //            var datePredicate = NSPredicate(value: true)
    //            if let beginDate = beginDate, let endDate = endDate {
    //                datePredicate = NSPredicate(format: "date >= %@ and date < %@", beginDate as CVarArg, endDate as CVarArg)
    //            }
    //
    //            let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [headingPredicate, datePredicate])
                
                var local = Locale.current.languageCode ?? "en"
                if local != "ru" {
                    local = "en"
                }
                let predicate = NSPredicate(format: "local = %@", local as CVarArg)
                
                let sort = NSSortDescriptor(key: "number", ascending: true)
                let query = CKQuery(recordType: "Review", predicate: predicate)
                query.sortDescriptors = [sort]
                
                let operation = CKQueryOperation(query: query)
                operation.desiredKeys = ["name", "profession", "instagram", "text", "number", "local", "photo"]
                operation.resultsLimit = limit
                
                var reviews = [Review]()
                
                operation.recordFetchedBlock = { record in
                    if let review = Review(from: record) {
                        reviews.append(review)
                    }
                }
                
                operation.queryCompletionBlock = { (cursor, error) in
                    DispatchQueue.main.async {
                        if error == nil {
                            success(reviews)
                        } else {
                            failure(error!)
                        }
                    }
                }
                
                publicDB.add(operation)
        }
        
        static func getPhotoData(photoID: CKRecord.ID, success: @escaping (Data) -> (), failure: @escaping (Error) -> ()) {
            publicDB.fetch(withRecordID: photoID) { (photoRecord, error) in
                if error != nil {
                    failure(error!)
                } else {
                    if let photo = photoRecord {
                        if let picture = photo["picture"] as? CKAsset, let url = picture.fileURL {
                            do {
                                let imageData = try Data(contentsOf: url)
                                success(imageData)
                            } catch {
                                failure(error)
                            }
                        }
                    }
                }
            }
        }
    }
    
}
