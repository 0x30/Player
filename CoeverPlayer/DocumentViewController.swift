//
//  DocumentViewController.swift
//  CoeverPlayer
//
//  Created by 荆文征 on 2020/7/5.
//  Copyright © 2020 demo. All rights reserved.
//

import UIKit

import SnapKit

class DocumentViewController: UIViewController {
    
    var document: UIDocument?
    
    let playerLayer = VLCMediaPlayer()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if let url = self.document?.fileURL {
            playerLayer.drawable = self.view
            playerLayer.media = VLCMedia(url: url)
            playerLayer.play()
        }
    }
}
