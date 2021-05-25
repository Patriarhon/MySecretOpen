//
//  NoteModel.swift
//  My Secret
//
//  Created by Petr on 15.05.2020.
//  Copyright © 2020 Petr. All rights reserved.
//

import Foundation
import Firebase
import CloudKit

struct Story: Equatable {
    static func == (lhs: Story, rhs: Story) -> Bool {
        return lhs.recordID == rhs.recordID &&
        lhs.heading == rhs.heading &&
        lhs.text == rhs.text &&
        lhs.place == rhs.place &&
        lhs.headingColor == rhs.headingColor &&
        lhs.placeColor == rhs.placeColor &&
        lhs.textColor == rhs.textColor &&
        lhs.headingFontNumber == rhs.headingFontNumber &&
        lhs.placeFontNumber == rhs.placeFontNumber &&
        lhs.textFontNumber == rhs.textFontNumber &&
        lhs.date == rhs.date
    }
    
    var recordID: CKRecord.ID?
    
    var heading: String?
    var text: String?
    var place: String?
    
    var headingColor: UIColor
    var placeColor: UIColor
    var textColor: UIColor
    
    var headingFontNumber: Int
    var placeFontNumber: Int
    var textFontNumber: Int
    
    var date: Date
    var photos = [PhotoModel]()
    
    var audio:  AudioModel?
    var video:  VideoModel?
    
    init?(from record: CKRecord) {
        guard let heading = record["heading"] as? String,
            let date = record["date"] as? Date else {
                print("Can't init Story")
                                return nil
        }
        
        self.recordID = record.recordID
        self.heading = heading
        self.date = date
        self.place = record["place"] as? String
        self.text = record["text"] as? String
        
        if let headingColorString = record["headingColor"] as? String {
            headingColor = UIColor(hexString: headingColorString)
        } else {
            self.headingColor = StringType.heading.defaultColor
        }
        
        if let placeColorString = record["placeColor"] as? String {
            placeColor = UIColor(hexString: placeColorString)
        } else {
            self.placeColor = StringType.place.defaultColor
        }
        
        if let textColorString = record["textColor"] as? String {
            textColor = UIColor(hexString: textColorString)
        } else {
            self.textColor = StringType.thoughts.defaultColor
        }
        
        headingFontNumber = record["headingFontNumber"] as? Int ?? 0
        placeFontNumber = record["placeFontNumber"] as? Int ?? 0
        textFontNumber = record["textFontNumber"] as? Int ?? 0
        
        if let recordPhotos = record["photos"] as? [CKRecord.Reference] {
            photos = recordPhotos.compactMap {PhotoModel(from: $0)}
        }
        
        if let recordAudio = record["audio"] as? CKRecord.Reference {
            audio = AudioModel(from: recordAudio)
        }
        
        if let recordVideo = record["video"] as? CKRecord.Reference {
            video = VideoModel(from: recordVideo)
        }
    }
    
    init(date: Date) {
        self.date = date
        
        self.headingColor = StringType.heading.defaultColor
        self.placeColor = StringType.place.defaultColor
        self.textColor = StringType.thoughts.defaultColor
        
        headingFontNumber = 0
        placeFontNumber = 0
        textFontNumber = 0
    }
    
    func toRecord() -> (storyRecord: CKRecord, photoAssets: [CKAsset], audioAsset: CKAsset?, videoAsset: CKAsset?) {
        let record: CKRecord
        
        if let recordID = recordID {
            record = CKRecord(recordType: "Story", recordID: recordID)
        } else {
            record = CKRecord(recordType: "Story")
        }
        
        if let heading = heading {
            record["heading"] = heading as CKRecordValue
        }
        
        if let place = place {
            record["place"] = place as CKRecordValue
        }
        
        if let text = text {
            record["text"] = text as CKRecordValue
        }
        
        record["headingColor"] = headingColor.hexString as CKRecordValue
        record["placeColor"] = placeColor.hexString as CKRecordValue
        record["textColor"] = textColor.hexString as CKRecordValue
        
        record["headingFontNumber"] = headingFontNumber
        record["placeFontNumber"] = placeFontNumber
        record["textFontNumber"] = textFontNumber
        
        record["date"] = date as CKRecordValue
        
        let savedPhotos = photos.compactMap {$0.cloudReference}
        record["photos"] = savedPhotos
        
        var photoAssets = [CKAsset]()
        
        for photo in photos {
            if let image = photo.image {
                let data = image.jpegData(compressionQuality: 0.4) // UIImage -> NSData, see also UIImageJPEGRepresentation
                let url = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(NSUUID().uuidString+".dat")
                do {
                    try data!.write(to: url!) //.writeToURL(url, options: [])
                } catch let e as NSError {
                    print("Error! \(e)");
                    
                }
//                photo.url = url
                photoAssets.append(CKAsset(fileURL: url!))
            } else {
                
            }
        }
        
        record["audio"] = audio?.cloudReference
        
        var audioAsset: CKAsset? = nil
        if let audioUrl = audio?.url {
           audioAsset = CKAsset(fileURL: audioUrl)
        }
        
        record["video"] = video?.cloudReference
        
        var videoAsset: CKAsset? = nil
        if let videoUrl = video?.url {
           videoAsset = CKAsset(fileURL: videoUrl)
        }
        
        return (storyRecord: record, photoAssets: photoAssets, audioAsset: audioAsset, videoAsset: videoAsset)
    }
    
//    init?(from map: [String: Any]) {
//        
//        guard let id = map["id"] as? String,
//            let date =  map["date"] as? Timestamp else {
//                print("Can't init StoryModel")
//                return nil
//        }
//        
//        self.recordName = id
//        self.date = date.dateValue()
//        heading = map["heading"] as? String
//        thoughts = map["thoughts"] as? String
//        location = map["location"] as? String
//        
//        if let photosMap = map["photos"] as? [String] {
//            photos = photosMap.compactMap { PhotoModel(from: $0) }
//        }
//    }
}

class PhotoModel {
//    var url: URL?
    let image: UIImage?
    let cloudReference: CKRecord.Reference?
    
    init?(from assetReference: CKRecord.Reference? = nil, image: UIImage? = nil) {
        guard assetReference != nil || image != nil else {
            print("Can't init PhotoModel")
            return nil
        }
//        self.url = url
        self.image = image
        self.cloudReference = assetReference
    }
}

class AudioModel {
    var url: URL?
    let cloudReference: CKRecord.Reference?
    
    init?(from assetReference: CKRecord.Reference? = nil, url: URL? = nil) {
        guard assetReference != nil || url != nil else {
            print("Can't init AudioModel")
            return nil
        }
        self.url = url
        self.cloudReference = assetReference
    }
}

class VideoModel {
    var url: URL?
    let cloudReference: CKRecord.Reference?
    
    init?(from assetReference: CKRecord.Reference? = nil, url: URL? = nil) {
        guard assetReference != nil || url != nil else {
            print("Can't init VideoModel")
            return nil
        }
        self.url = url
        self.cloudReference = assetReference
    }
}
