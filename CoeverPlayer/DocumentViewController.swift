//
//  DocumentViewController.swift
//  CoeverPlayer
//
//  Created by 荆文征 on 2020/7/5.
//  Copyright © 2020 demo. All rights reserved.
//

import UIKit
import AVKit
import SnapKit
import RxSwift
import RxCocoa

class DocumentViewController: UIViewController {
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var pipButton: UIButton!
    
    var document: UIDocument?
    
    let disposebag = DisposeBag()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        pipButton.setImage(AVPictureInPictureController.pictureInPictureButtonStartImage, for: UIControl.State.normal)
        pipButton.setImage(AVPictureInPictureController.pictureInPictureButtonStopImage, for: UIControl.State.normal)
        
        closeButton.rx.tap.subscribe(onNext: {[weak self] (_) in
            self?.dismiss(animated: true, completion: nil)
            }).disposed(by: disposebag)
        
        if let url = document?.fileURL {

            let playerView = WZPlayerView(url: url)
            self.view.insertSubview(playerView, at: 0)
            playerView.snp.makeConstraints { (maker) in
                maker.edges.equalTo(UIEdgeInsets.zero)
            }
            
            playerView.play()
            
            pipButton.rx.tap.subscribe(onNext: {[weak self] (_) in
                
//                playerView.trigger()
                
                
                playerView.seek(to: 3)
                
                }).disposed(by: disposebag)
            
            
        }
        
        
    }
}
