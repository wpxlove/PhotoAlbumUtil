//
//  PhotoAlbumUtil.swift
//  WellFit
//
//  Created by Mike on 2016/7/11.
//  Copyright © 2016年 Giles. All rights reserved.
//

import Foundation
import Photos

public enum PhotoAlbumUtilResult {
    case Success
    case Error
    case Denied
}

class PhotoAlbumUtil: NSObject {
    
    //是否認證
    class func isAuthorized() -> Bool{
        
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.Authorized{
            return true
        }else{
            return false
        }
        
    }
    
    class  func saveImageAlbum(image:UIImage,albumName:String,completion:((result: PhotoAlbumUtilResult) -> ())?){
        if isAuthorized() == false{
            completion!(result:.Denied)
            return
        }
        
        var assetAlbum: PHAssetCollection?
        
        if albumName.isEmpty == true{
            let list = PHAssetCollection.fetchAssetCollectionsWithType(.SmartAlbum, subtype: .SmartAlbumUserLibrary, options: nil)
              assetAlbum = list[0] as? PHAssetCollection
        }else{
            
            let list = PHAssetCollection.fetchAssetCollectionsWithType(.Album, subtype: .Any, options: nil)
            list.enumerateObjectsUsingBlock({ (album, index, isStop) in
                let assetCollection = album as! PHAssetCollection
                if albumName == assetCollection.localizedTitle {
                    assetAlbum = assetCollection
                    isStop.memory = true
                }
            })
            
            if assetAlbum == nil{
                PHPhotoLibrary.sharedPhotoLibrary().performChanges({
                    PHAssetCollectionChangeRequest.creationRequestForAssetCollectionWithTitle(albumName)
                    }, completionHandler: { (isSuccess, error) in
                        self.saveImageAlbum(image, albumName: albumName, completion: completion)
                })
                return
            }
        
        }
        
        
        
        //保存圖片
        PHPhotoLibrary .sharedPhotoLibrary().performChanges({
            //添加的相機膠卷
            let result = PHAssetChangeRequest .creationRequestForAssetFromImage(image)
            //是否要添加到相簿
            if !albumName.isEmpty {
                let assetPlaceholder = result.placeholderForCreatedAsset
                let albumChangeRequset = PHAssetCollectionChangeRequest (forAssetCollection:
                    assetAlbum!)
                albumChangeRequset!.addAssets([assetPlaceholder!])
            }
            }, completionHandler: { (isSuccess: Bool , error: NSError?) in
                if isSuccess {
                    completion?(result: PhotoAlbumUtilResult.Success )
                } else {
                    print (error!.localizedDescription)
                    completion?(result: PhotoAlbumUtilResult.Error )
                }
        })
        
    }
    
    //刪除相薄
   class func  deletePhotoLibray(albumName:String,completion:((result: PhotoAlbumUtilResult) -> ())) {
   
    
        let albumName :String =  albumName
        let fetchOptions :PHFetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title == %@",albumName)
        let collection:PHFetchResult = PHAssetCollection.fetchAssetCollectionsWithType(.Album, subtype: .Any, options: fetchOptions)
        if collection.count > 0{
            PHPhotoLibrary.sharedPhotoLibrary().performChanges({
                PHAssetCollectionChangeRequest.deleteAssetCollections( collection)
                }, completionHandler: { (isSuccess: Bool , error: NSError?) in
                    if isSuccess {
                       completion(result: PhotoAlbumUtilResult.Success)
                    } else {
                        print (error!.localizedDescription)
                        completion(result: PhotoAlbumUtilResult.Error)

                        
                    }
            })
        }

           completion(result: PhotoAlbumUtilResult.Success)
        
    }



}