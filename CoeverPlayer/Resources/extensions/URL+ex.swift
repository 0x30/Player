//
//  URL+ex.swift
//  CoeverPlayer
//
//  Created by 荆文征 on 2020/7/6.
//  Copyright © 2020 demo. All rights reserved.
//

import AVKit
import Foundation

extension URL{
    
    /// 是否支持 AvPlayer 播放 优先使用该版本
    var isSupportAVPlayable: Bool{
        return AVAsset(url: self).isPlayable
    }
}
