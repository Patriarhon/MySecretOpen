//
//  NoteModule.swift
//  My Secret
//
//  Created by Petr on 17.05.2020.
//  Copyright © 2020 Petr. All rights reserved.
//

import Foundation
import CloudKit
import Alamofire
import SwiftyJSON

extension API {
    class StoryModule {
        
        static func getNotes(limit: Int, cursor: CKQueryOperation.Cursor? = nil ,success: @escaping ([Story]) -> (), failure: @escaping (Error) -> ()) {
            let pred = NSPredicate(value: true)
            let sort = NSSortDescriptor(key: "date", ascending: false)
            let query = CKQuery(recordType: "Story", predicate: pred)
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
        
        static func saveNew(story: Story, success: @escaping (CKRecord?) -> (), failure: @escaping (Error) -> ()) {
            
            let tuple = story.toRecord()
            let storyRecord = tuple.storyRecord
            let photoAssets = tuple.photoAssets
            let audioAsset = tuple.audioAsset
            let videoAsset = tuple.videoAsset
            
            var isPhotoSaved = false
            var isAudioSaved = false
            var isVideoSaved = false
            
            privateDB.save(storyRecord) {  record, error in
                if let error = error {
                    failure(error)
                } else {
                    var successPhotoCount = 0
                    if photoAssets.isEmpty {
                        isPhotoSaved = true
                        if isAudioSaved && isVideoSaved {
                            success(record)
                        }
                    }
                    ////////// - video
                    
                    if let videoAsset = videoAsset {
                        add(storyRecord: record!, video: videoAsset, success: { (videoRecord) in
                            let videoReference = CKRecord.Reference(recordID: videoRecord.recordID, action: .none)
                            record!["video"] = videoReference
                            
                            isVideoSaved = true
                            if isPhotoSaved && isAudioSaved {
                                privateDB.save(record!) { (updatedRecord, error) in
                                    if let error = error {
                                        failure(error)
                                    } else {
                                        
                                        for photo in photoAssets {
                                            do { try FileManager.default.removeItem(at: photo.fileURL!) }
                                            catch let e { print("Error deleting temp file: \(e)") }
                                        }
                                        success(record)
                                    }
                                }
                            }
                            
                        }) { (error) in
                            print(error.localizedDescription)
                            
                            if let record = record {
                                privateDB.delete(withRecordID: record.recordID) { (recordId, errorOfDeleting) in
                                    DispatchQueue.main.async {
                                        failure(error)
                                    }
                                }
                            }
                        }
                    } else {
                        isVideoSaved = true
                        if isPhotoSaved && isAudioSaved {
                            let seconds = 1.2
                            DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                                success(record)
                            }
                            
                        }
                    }
                    
                    ////////// - audio
                    
                    if let audioAsset = audioAsset {
                        add(storyRecord: record!, audio: audioAsset, success: { (audioRecord) in
                            let audioReference = CKRecord.Reference(recordID: audioRecord.recordID, action: .none)
                            record!["audio"] = audioReference
                            
                            isAudioSaved = true
                            if isPhotoSaved  && isVideoSaved {
                                privateDB.save(record!) { (updatedRecord, error) in
                                    if let error = error {
                                        failure(error)
                                    } else {
                                        
                                        for photo in photoAssets {
                                            do { try FileManager.default.removeItem(at: photo.fileURL!) }
                                            catch let e { print("Error deleting temp file: \(e)") }
                                        }
                                        success(record)
                                    }
                                }
                            }
                            
                        }) { (error) in
                            print(error.localizedDescription)
                            
                            if let record = record {
                                privateDB.delete(withRecordID: record.recordID) { (recordId, errorOfDeleting) in
                                    DispatchQueue.main.async {
                                        failure(error)
                                    }
                                }
                            }
                        }
                    } else {
                        isAudioSaved = true
                        if isPhotoSaved && isVideoSaved {
                            let seconds = 1.2
                            DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                                success(record)
                            }
                            
                        }
                    }
                    
                    ////// - photos
                   
                    for photo in photoAssets {
                        add(storyRecord: record!, photo: photo, success: { (photoRecord) in
                            successPhotoCount += 1
                            let photoReference = CKRecord.Reference(recordID: photoRecord.recordID, action: .none)
                            var photoReferences  = ((record?["photos"]) as? [CKRecord.Reference]) ?? [CKRecord.Reference]()
                            photoReferences.append(photoReference)
                            record!["photos"] = photoReferences
                            
                            if successPhotoCount == photoAssets.count {
                                
                                isPhotoSaved = true
                                if isAudioSaved  && isVideoSaved {
                                    privateDB.save(record!) { (updatedRecord, error) in
                                        if let error = error {
                                            failure(error)
                                        } else {
                                            
                                            for photo in photoAssets {
                                                do { try FileManager.default.removeItem(at: photo.fileURL!) }
                                                catch let e { print("Error deleting temp file: \(e)") }
                                            }
                                            
                                            if let audioUrl = audioAsset?.fileURL {
                                                do { try FileManager.default.removeItem(at: audioUrl) }
                                                catch let e { print("Error deleting temp file: \(e)") }
                                                success(record)
                                            } else {
                                                success(record)
                                            }
                                            
                                        }
                                    }
                                }
                            }
                        }) { (error) in
                            print(error.localizedDescription)
                            
                            if let record = record {
                                privateDB.delete(withRecordID: record.recordID) { (recordId, errorOfDeleting) in
                                    DispatchQueue.main.async {
                                        failure(error)
                                    }
                                }
                            }
                            
                        }
                    }
                }
            }
        }
        
        static func getPhotoData(photoID: CKRecord.ID, success: @escaping (Data) -> (), failure: @escaping (Error) -> ()) {
            privateDB.fetch(withRecordID: photoID) { (photoRecord, error) in
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
        
        static func getVideoUrl(videoID: CKRecord.ID, success: @escaping (URL) -> (), failure: @escaping (Error) -> ()) {
            privateDB.fetch(withRecordID: videoID) { (videoRecord, error) in
                if error != nil {
                    failure(error!)
                } else {
                    if let videoRecord = videoRecord {
                        if let video = videoRecord["video"] as? CKAsset, let url = video.fileURL {
//                            do {
//                                let videoData = try Data(contentsOf: url)
                                success(url)
//                            } catch {
//                                failure(error)
//                            }
                        }
                    }
                }
            }
        }
        
        static func getAudioUrl(audioID: CKRecord.ID, success: @escaping (URL) -> (), failure: @escaping (Error) -> ()) {
            privateDB.fetch(withRecordID: audioID) { (audioRecord, error) in
                if error != nil {
                    failure(error!)
                } else {
                    if let audioRecord = audioRecord {
                        if let audio = audioRecord["audio"] as? CKAsset, let url = audio.fileURL {
                            success(url)
                        }
                    }
                }
            }
        }
        
        private static func add(storyRecord: CKRecord, photo: CKAsset, success: @escaping (CKRecord) -> (), failure: @escaping (Error) -> ()) {
            let photoRecord = CKRecord(recordType: "Photo")
            let reference = CKRecord.Reference(recordID: storyRecord.recordID, action: .deleteSelf)
            photoRecord["picture"] = photo
            photoRecord["owningStory"] = reference as CKRecordValue
            
            privateDB.save(photoRecord) { record, error in
                DispatchQueue.main.async {
                    if error == nil {
                        success(record!)
                    } else {
                        failure(error!)
                    }
                }
            }
        }
        
        private static func add(storyRecord: CKRecord, audio: CKAsset, success: @escaping (CKRecord) -> (), failure: @escaping (Error) -> ()) {
            let audioRecord = CKRecord(recordType: "Audio")
            let reference = CKRecord.Reference(recordID: storyRecord.recordID, action: .deleteSelf)
            audioRecord["audio"] = audio
            audioRecord["owningStory"] = reference as CKRecordValue
            
            privateDB.save(audioRecord) { record, error in
                DispatchQueue.main.async {
                    if error == nil {
                        success(record!)
                    } else {
                        failure(error!)
                    }
                }
            }
        }
        
        private static func add(storyRecord: CKRecord, video: CKAsset, success: @escaping (CKRecord) -> (), failure: @escaping (Error) -> ()) {
            let videoRecord = CKRecord(recordType: "Video")
            let reference = CKRecord.Reference(recordID: storyRecord.recordID, action: .deleteSelf)
            videoRecord["video"] = video
            videoRecord["owningStory"] = reference as CKRecordValue
            
            privateDB.save(videoRecord) { record, error in
                DispatchQueue.main.async {
                    if error == nil {
                        success(record!)
                    } else {
                        failure(error!)
                    }
                }
            }
        }
        
        
        static func update(story: Story, photosForDelete: [CKRecord.Reference], audioForDelete: CKRecord.Reference?, videoForDelete: CKRecord.Reference?, success: @escaping (CKRecord?) -> (), failure: @escaping (Error) -> ()) {
            let tuple = story.toRecord()
            let storyRecord = tuple.storyRecord
            let photoAssets = tuple.photoAssets
            let audioAsset = tuple.audioAsset
            let videoAsset = tuple.videoAsset
            
            var isPhotoSaved = false
            var isAudioSaved = false
            var isVideoSaved = false
            
            privateDB.fetch(withRecordID: storyRecord.recordID) { (record, error) in
                if let error = error {
                    failure(error)
                } else {
                    record?["heading"] = storyRecord["heading"]
                    record?["date"] = storyRecord["date"]
                    record?["place"] = storyRecord["place"]
                    record?["text"] = storyRecord["text"]
                    record?["text"] = storyRecord["text"]
                    record?["headingColor"] = storyRecord["headingColor"]
                    record?["placeColor"] = storyRecord["placeColor"]
                    record?["textColor"] = storyRecord["textColor"]
                    record?["headingFontNumber"] = storyRecord["headingFontNumber"]
                    record?["placeFontNumber"] = storyRecord["placeFontNumber"]
                    record?["textFontNumber"] = storyRecord["textFontNumber"]
                    record?["photos"] = storyRecord["photos"]
                    record?["audio"] = storyRecord["audio"]
                    record?["video"] = storyRecord["video"]
                    
                    
                    privateDB.save(record ?? storyRecord) {  record, error in
                        if let error = error {
                            failure(error)
                        } else {
                            var successPhotoCount = 0
                            if photoAssets.isEmpty {
                                
                                var recordsIDsForDelete = photosForDelete.compactMap {$0.recordID}
                                if let audioForDeleteID = audioForDelete?.recordID {
                                    recordsIDsForDelete.append(audioForDeleteID)
                                }
                                
                                let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: recordsIDsForDelete)
                                   operation.modifyRecordsCompletionBlock = {
                                    (savedRecords: [CKRecord]?, deletedRecordIDs: [CKRecord.ID]?, error: Error?) in
                                       print("deleted all records")
                                    isPhotoSaved = true
                                    if isAudioSaved && isVideoSaved {
                                        privateDB.save(record!) { (updatedRecord, error) in
                                            if let error = error {
                                                failure(error)
                                            } else {
                                                
                                                for photo in photoAssets {
                                                    do { try FileManager.default.removeItem(at: photo.fileURL!) }
                                                    catch let e { print("Error deleting temp file: \(e)") }
                                                }
                                                
                                                var recordsIDsForDelete = photosForDelete.compactMap {$0.recordID}
                                                if let audioForDeleteID = audioForDelete?.recordID {
                                                    recordsIDsForDelete.append(audioForDeleteID)
                                                }
                                                if let videoForDeleteID = videoForDelete?.recordID {
                                                    recordsIDsForDelete.append(videoForDeleteID)
                                                }
                                                
                                                let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: recordsIDsForDelete)
                                                   operation.modifyRecordsCompletionBlock = {
                                                    (savedRecords: [CKRecord]?, deletedRecordIDs: [CKRecord.ID]?, error: Error?) in
                                                       print("deleted all records")
                                                    success(record)
                                                   }

                                                privateDB.add(operation)
                                            }
                                        }
                                    }
                                    
                                   }

                                privateDB.add(operation)
                                
                            }
                            
                            if let videoAsset = videoAsset {
                                add(storyRecord: record!, video: videoAsset, success: { (videoRecord) in
                                    let videoReference = CKRecord.Reference(recordID: videoRecord.recordID, action: .none)
                                    record!["video"] = videoReference
                                    
                                    isVideoSaved = true
                                    if isPhotoSaved && isAudioSaved {
                                        privateDB.save(record!) { (updatedRecord, error) in
                                            if let error = error {
                                                failure(error)
                                            } else {
                                                
                                                for photo in photoAssets {
                                                    do { try FileManager.default.removeItem(at: photo.fileURL!) }
                                                    catch let e { print("Error deleting temp file: \(e)") }
                                                }
                                                
                                                var recordsIDsForDelete = photosForDelete.compactMap {$0.recordID}
                                                if let audioForDeleteID = audioForDelete?.recordID {
                                                    recordsIDsForDelete.append(audioForDeleteID)
                                                }
                                                if let videoForDeleteID = videoForDelete?.recordID {
                                                    recordsIDsForDelete.append(videoForDeleteID)
                                                }
                                                
                                                let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: recordsIDsForDelete)
                                                   operation.modifyRecordsCompletionBlock = {
                                                    (savedRecords: [CKRecord]?, deletedRecordIDs: [CKRecord.ID]?, error: Error?) in
                                                       print("deleted all records")
                                                    success(record)
                                                   }

                                                privateDB.add(operation)
                                            }
                                        }
                                    }
                                    
                                }) { (error) in
                                    print(error.localizedDescription)
                                    
                                    if let record = record {
                                        privateDB.delete(withRecordID: record.recordID) { (recordId, errorOfDeleting) in
                                            DispatchQueue.main.async {
                                                failure(error)
                                            }
                                        }
                                    }
                                }
                            } else {
                                isVideoSaved = true
                                if isPhotoSaved && isAudioSaved {
                                    let seconds = 1.2
                                    DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                                        for photo in photoAssets {
                                            do { try FileManager.default.removeItem(at: photo.fileURL!) }
                                            catch let e { print("Error deleting temp file: \(e)") }
                                        }
                                        
                                        var recordsIDsForDelete = photosForDelete.compactMap {$0.recordID}
                                        if let audioForDeleteID = audioForDelete?.recordID {
                                            recordsIDsForDelete.append(audioForDeleteID)
                                        }
                                        if let videoForDeleteID = videoForDelete?.recordID {
                                            recordsIDsForDelete.append(videoForDeleteID)
                                        }
                                        
                                        let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: recordsIDsForDelete)
                                           operation.modifyRecordsCompletionBlock = {
                                            (savedRecords: [CKRecord]?, deletedRecordIDs: [CKRecord.ID]?, error: Error?) in
                                               print("deleted all records")
                                            success(record)
                                           }

                                        privateDB.add(operation)
                                    }
                                    
                                }
                            }
                            
                            if let audioAsset = audioAsset {
                                add(storyRecord: record!, audio: audioAsset, success: { (audioRecord) in
                                    let audioReference = CKRecord.Reference(recordID: audioRecord.recordID, action: .none)
                                    record!["audio"] = audioReference
                                    
                                    isAudioSaved = true
                                    if isPhotoSaved && isVideoSaved {
                                        privateDB.save(record!) { (updatedRecord, error) in
                                            if let error = error {
                                                failure(error)
                                            } else {
                                                
                                                for photo in photoAssets {
                                                    do { try FileManager.default.removeItem(at: photo.fileURL!) }
                                                    catch let e { print("Error deleting temp file: \(e)") }
                                                }
                                                
                                                var recordsIDsForDelete = photosForDelete.compactMap {$0.recordID}
                                                if let audioForDeleteID = audioForDelete?.recordID {
                                                    recordsIDsForDelete.append(audioForDeleteID)
                                                }
                                                if let videoForDeleteID = videoForDelete?.recordID {
                                                    recordsIDsForDelete.append(videoForDeleteID)
                                                }
                                                
                                                let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: recordsIDsForDelete)
                                                   operation.modifyRecordsCompletionBlock = {
                                                    (savedRecords: [CKRecord]?, deletedRecordIDs: [CKRecord.ID]?, error: Error?) in
                                                       print("deleted all records")
                                                    success(record)
                                                   }

                                                privateDB.add(operation)
                                            }
                                        }
                                    }
                                    
                                }) { (error) in
                                    print(error.localizedDescription)
                                    
                                    if let record = record {
                                        privateDB.delete(withRecordID: record.recordID) { (recordId, errorOfDeleting) in
                                            DispatchQueue.main.async {
                                                failure(error)
                                            }
                                        }
                                    }
                                }
                            } else {
                                isAudioSaved = true
                                if isPhotoSaved && isVideoSaved {
                                    success(record)
                                }
                            }
                            
                            for photo in photoAssets {
                                add(storyRecord: record!, photo: photo, success: { (photoRecord) in
                                    successPhotoCount += 1
                                    let photoReference = CKRecord.Reference(recordID: photoRecord.recordID, action: .none)
                                    var photoReferences  = ((record?["photos"]) as? [CKRecord.Reference]) ?? [CKRecord.Reference]()
                                    photoReferences.append(photoReference)
                                    record!["photos"] = photoReferences
                                    
                                    if successPhotoCount == photoAssets.count {
                                        
                                        isPhotoSaved = true
                                        if isAudioSaved && isVideoSaved {
                                            privateDB.save(record!) { (updatedRecord, error) in
                                                if let error = error {
                                                    failure(error)
                                                } else {
                                                    
                                                    for photo in photoAssets {
                                                        do { try FileManager.default.removeItem(at: photo.fileURL!) }
                                                        catch let e { print("Error deleting temp file: \(e)") }
                                                    }
                                                    
                                                    var recordsIDsForDelete = photosForDelete.compactMap {$0.recordID}
                                                    if let audioForDeleteID = audioForDelete?.recordID {
                                                        recordsIDsForDelete.append(audioForDeleteID)
                                                    }
                                                    if let videoForDeleteID = videoForDelete?.recordID {
                                                        recordsIDsForDelete.append(videoForDeleteID)
                                                    }
                                                    
                                                    let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: recordsIDsForDelete)
                                                       operation.modifyRecordsCompletionBlock = {
                                                        (savedRecords: [CKRecord]?, deletedRecordIDs: [CKRecord.ID]?, error: Error?) in
                                                           print("deleted all records")
                                                        success(record)
                                                       }

                                                    privateDB.add(operation)
                                                    
                                                }
                                            }
                                        }
                                    }
                                }) { (error) in
                                    print(error.localizedDescription)
                                    
//                                    if let record = record {
//                                        db.delete(withRecordID: record.recordID) { (recordId, errorOfDeleting) in
//                                            DispatchQueue.main.async {
//                                                failure(error)
//                                            }
//                                        }
//                                    }
                                    
                                }
                            }
                        }
                    }
                }
            }
        }
        
        static func delete(story: Story, success: @escaping (CKRecord.ID?) -> (), failure: @escaping (Error) -> ()) {
            let storyRecord = story.toRecord().storyRecord
            
            privateDB.delete(withRecordID: storyRecord.recordID) { (recordId, error) in
                DispatchQueue.main.async {
                    if let error = error {
                        failure(error)
                    } else {
                        success(recordId)
                    }
                }
                
            }
        }
        
        static func deleteAllStories(success: @escaping (CKRecordZone.ID?) -> (), failure: @escaping (Error) -> ()) {
            privateDB.delete(withRecordZoneID: CKRecordZone.default().zoneID) { (recordZoneID, error) in
                DispatchQueue.main.async {
                    if let error = error {
                        failure(error)
                    } else {
                        success(recordZoneID)
                    }
                }
            }
        }
    }
}
