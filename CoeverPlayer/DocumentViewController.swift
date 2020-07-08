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
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return UIStatusBarStyle.lightContent
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        closeButton.rx.tap.subscribe(onNext: {[weak self] (_) in
            self?.dismiss(animated: true, completion: nil)
            }).disposed(by: disposebag)
        
        let playerView = WZPlayerView(url: document!.fileURL)
        self.view.insertSubview(playerView, at: 0)
        playerView.snp.makeConstraints { (maker) in
            maker.edges.equalTo(UIEdgeInsets.zero)
        }
        
        playerView.play()
    }
}
