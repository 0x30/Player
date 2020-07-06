//
//  ThumbnailProvider.swift
//  VideoThumbnail
//
//  Created by 荆文征 on 2020/7/5.
//  Copyright © 2020 demo. All rights reserved.
//

import UIKit
import QuickLookThumbnailing

class ThumbnailProvider: QLThumbnailProvider {
    
    typealias Block = (QLThumbnailReply?, Error?) -> Void
    
    private var handler: Block?
    
    private var request: QLFileThumbnailRequest?
    
    override func provideThumbnail(for request: QLFileThumbnailRequest, _ handler: @escaping (QLThumbnailReply?, Error?) -> Void) {
        
        self.handler = handler
        
        self.request = request
        
        print(request.fileURL,"?????")
        
        VLCMediaThumbnailer(media: VLCMedia(url: request.fileURL), andDelegate: self).fetchThumbnail()
    }
    
    func calculater(request: QLFileThumbnailRequest,image: UIImage) -> (contextSize: CGSize,drawRect:CGRect) {

        let maximumSize = request.maximumSize
        let imageSize = image.size

        // calculate `newImageSize` and `contextSize` such that the image fits perfectly and respects the constraints
        var newImageSize = maximumSize
        var contextSize = maximumSize
        let aspectRatio = imageSize.height / imageSize.width
        let proposedHeight = aspectRatio * maximumSize.width

        if proposedHeight <= maximumSize.height {
            newImageSize.height = proposedHeight
            contextSize.height = max(proposedHeight.rounded(.down), request.minimumSize.height)
        } else {
            newImageSize.width = maximumSize.height / aspectRatio
            contextSize.width = max(newImageSize.width.rounded(.down), request.minimumSize.width)
        }
        
        return (contextSize,
                CGRect(x: contextSize.width/2 - newImageSize.width/2,
                       y: contextSize.height/2 - newImageSize.height/2,
                       width: newImageSize.width,
                       height: newImageSize.height))
    }
}

extension ThumbnailProvider: VLCMediaThumbnailerDelegate{
    
    func mediaThumbnailerDidTimeOut(_ mediaThumbnailer: VLCMediaThumbnailer!) {
        
        self.handler?(nil, NSError(domain: "time out", code: 0, userInfo: nil))
    }
    
    func mediaThumbnailer(_ mediaThumbnailer: VLCMediaThumbnailer!, didFinishThumbnail thumbnail: CGImage!) {
        
        print("生成缩略图?????")
        
        DispatchQueue.main.async { [weak self] in
            
            let thumbnailImage = UIImage(cgImage: thumbnail)

            if let request = self?.request, let result = self?.calculater(request: request, image: thumbnailImage) {
                
                let reply = QLThumbnailReply(contextSize: result.contextSize, currentContextDrawing: {
                    thumbnailImage.draw(in: result.drawRect)
                    return true
                })
                self?.handler?(reply, nil)
                
            }else{

                self?.handler?(nil, NSError(domain: "request not exist", code: 0, userInfo: nil))
            }
        }
    }
}
