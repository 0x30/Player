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
    
    let disposebag = DisposeBag()
    
    /// 播放器
    let playerView: WZPlayerView
    
    let finishPublishRelay = PublishRelay<Void>()
    
    let button = UIButton(type: UIButton.ButtonType.system)
    
    init(with document: UIDocument) {
        
        self.playerView = WZPlayerView(url: document.fileURL)
        
        super.init(nibName: nil, bundle: nil)
        
        self.modalPresentationStyle = .fullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.systemBackground
        
        self.view.addSubview(self.playerView)
        playerView.snp.remakeConstraints { (maker) in
            
            maker.edges.equalTo(UIEdgeInsets.zero)
        }
        
        button.setImage(UIImage(systemName: "xmark"), for: UIControl.State.normal)
        self.view.addSubview(button)
        button.snp.remakeConstraints { (maker) in
            
            maker.top.equalTo(self.view.snp.topMargin)
            maker.left.equalTo(self.view.snp.leftMargin)
        }
        
        button.rx.tap.map{ _ in true }.bind(to: rx.dismiss).disposed(by: disposebag)
        
        self.playerView.play()
    }
}
