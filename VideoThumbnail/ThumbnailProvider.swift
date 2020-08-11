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
    
    override func provideThumbnail(for request: QLFileThumbnailRequest, _ handler: @escaping (QLThumbnailReply?, Error?) -> Void) {
        
        ThumbnailerGenerator.provideThumbnail(documentURL: request.fileURL) { (image) in
            
            guard let image = image else {
                handler(nil, NSError(domain: "image error", code: 0, userInfo: nil))
                return
            }
            
            let thumbnailImage = UIImage(cgImage: image)
            
            let result = self.calculater(request: request, image: thumbnailImage)
                            
            let reply = QLThumbnailReply(contextSize: result.contextSize, currentContextDrawing: {
                thumbnailImage.draw(in: result.drawRect)
                return true
            })
                            
            handler(reply, nil)
        }
    }
    
    private func calculater(request: QLFileThumbnailRequest,image: UIImage) -> (contextSize: CGSize,drawRect:CGRect) {

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
