//
//  ImageProvider.swift
//  My Secret
//
//  Created by Petr on 07.06.2020.
//  Copyright © 2020 Petr. All rights reserved.
//

import Foundation
import Kingfisher
import CloudKit


struct ImageProvider: ImageDataProvider {
    var cacheKey: String { return photoID.recordName }
    let photoID: CKRecord.ID
    let isPrivate: Bool
    
    init(photoID: CKRecord.ID, isPrivate: Bool = true) {
        self.photoID = photoID
        self.isPrivate = isPrivate
    }
    
    func data(handler: @escaping (Result<Data, Error>) -> Void) {
        
        if isPrivate {
            API.StoryModule.getPhotoData(photoID: photoID, success: { (data) in
                handler(.success(data))
            }) { (error) in
                handler(.failure(error))
            }
        } else {
            API.ForYouModule.getPhotoData(photoID: photoID, success: { (data) in
                handler(.success(data))
            }) { (error) in
                handler(.failure(error))
            }
        }
        
        
    }
}
