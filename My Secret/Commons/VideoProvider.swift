//
//  VideoProvider.swift
//  My Secret
//
//  Created by Petr on 22.07.2020.
//  Copyright © 2020 Petr. All rights reserved.
//

import Foundation
import Kingfisher
import CloudKit
import AVKit


struct VideoProvider: ImageDataProvider {
    var cacheKey: String { return videoID.recordName }
    let videoID: CKRecord.ID
    
    init(videoID: CKRecord.ID) {
        self.videoID = videoID
    }
    
    func data(handler: @escaping (Result<Data, Error>) -> Void) {
        
        API.StoryModule.getVideoUrl(videoID: videoID, success: { (videoURL) in
            
            let videoData = try? Data(contentsOf: videoURL)

            let documentsPath = self.getDocumentsDirectory()
            let destinationPath = documentsPath.appendingPathComponent("filename.mov")

            FileManager.default.createFile(atPath: destinationPath.path, contents: videoData, attributes:nil)

            let newURL = destinationPath
            
            self.getThumbnailImageFromVideoUrl(url: newURL) { (thumbImage) in
                let data = UIImage(cgImage: (thumbImage?.cgImage!)!).jpegData(compressionQuality: 1)
                handler(.success(data!))
            }
//            guard let previewImageData = self.videoPreviewImage(url: videoURL) else {
//                return
//            }
//            handler(.success(data))
        }) { (error) in
            handler(.failure(error))
        }
            
            
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func getThumbnailImageFromVideoUrl(url: URL, completion: @escaping ((_ image: UIImage?)->Void)) {
        DispatchQueue.global().async { //1
            let asset = AVAsset(url: url) //2
            let avAssetImageGenerator = AVAssetImageGenerator(asset: asset) //3
            avAssetImageGenerator.appliesPreferredTrackTransform = true //4
            let thumnailTime = CMTimeMake(value: 1, timescale: 1) //5
            do {
                let cgThumbImage = try avAssetImageGenerator.copyCGImage(at: thumnailTime, actualTime: nil) //6
                let thumbImage = UIImage(cgImage: cgThumbImage) //7
                DispatchQueue.main.async { //8
                    completion(thumbImage) //9
                }
            } catch {
                print(error.localizedDescription) //10
                DispatchQueue.main.async {
                    completion(nil) //11
                }
            }
        }
    }
    
    func videoPreviewImage(url: URL) -> Data? {
        let asset = AVURLAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        if let cgImage = try? generator.copyCGImage(at: CMTime(seconds: 0, preferredTimescale: 1), actualTime: nil) {
            let data = UIImage(cgImage: cgImage).jpegData(compressionQuality: 1)
            return data
        } else {
            return nil
        }
    }
}
