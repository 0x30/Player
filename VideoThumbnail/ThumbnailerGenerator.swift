//
//  ThumbnailerGenerator.swift
//  CoeverPlayer
//
//  Created by 荆文征 on 2020/7/8.
//  Copyright © 2020 demo. All rights reserved.
//

import Foundation

class ThumbnailerGenerator {
    
    class func provideThumbnail(documentURL: URL, complete:@escaping (CGImage?) -> Void){
        VLCMediaThumbnailer(media: VLCMedia(url: documentURL), andDelegate: VLCMediaThumbnailerDelegateProxy(block: { (image) in
            complete(image)
        })).fetchThumbnail()
    }
}


private class VLCMediaThumbnailerDelegateProxy: NSObject, VLCMediaThumbnailerDelegate {
    
    typealias VLCMediaThumbnailerDelegateProxyBlock = (_ image: CGImage?) -> Void
    
    private let block: VLCMediaThumbnailerDelegateProxyBlock
    
    /// 自管理 内存
    private var _self: VLCMediaThumbnailerDelegateProxy?
    
    init(block: @escaping VLCMediaThumbnailerDelegateProxyBlock) {
        
        self.block = block
        
        super.init()
        
        _self = self
    }
    
    func mediaThumbnailerDidTimeOut(_ mediaThumbnailer: VLCMediaThumbnailer!) {
        
        self.block(nil)
        
        _self = nil
    }
    
    func mediaThumbnailer(_ mediaThumbnailer: VLCMediaThumbnailer!, didFinishThumbnail thumbnail: CGImage!) {
        
        self.block(thumbnail)
        
        _self = nil
    }
}

