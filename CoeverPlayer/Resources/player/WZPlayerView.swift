//
//  WZPlayerLayer.swift
//  CoeverPlayer
//
//  Created by 荆文征 on 2020/7/6.
//  Copyright © 2020 demo. All rights reserved.
//

import AVKit
import RxCocoa
import RxSwift
import RxOptional
import Foundation

class WZPlayerView: UIView {
    
    fileprivate let disposeBag = DisposeBag()
    
    fileprivate let sizePublishRelay = PublishRelay<CGSize>()
    /// 当前的播放速度
    fileprivate let rateBehaviorRelay = BehaviorRelay<Float>(value: 0)
    /// 当前是否正在播放视频
    fileprivate let isPlayingBehaviorRelay = BehaviorRelay<Bool>(value: false)
    /// 当前的播放秒数
    fileprivate let currentSecondsBehaviorRelay = BehaviorRelay<Float>(value: 0)
    
    private let url: URL
    
    /// 是否使用 avkit 播放视频
    private let avMode: Bool
    
    private var avPlayerLayer: AVPlayerLayer?
    private var vlcPlayerLayer: VLCMediaPlayer?
    
    init(url: URL) {
        self.url = url
        self.avMode = url.isSupportAVPlayable
        super.init(frame: CGRect.zero)
        
        if self.avMode {
            self.configAvPlayer()
        }else{
            self.configVLCPlayer()
        }
        
        self.backgroundColor = UIColor.black
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        if self.avMode {
            avPlayerLayer?.frame = self.bounds
        }
    }
    
    // play video source sec float value
    var duration: Float {
        if self.avMode {
            return Float(self.avPlayerLayer?.duration ?? 0)
        }
        return (vlcPlayerLayer?.media.length.value.floatValue ?? 0)/1000
    }
    
    var size: CGSize {
        if self.avMode {
            
            return self.avPlayerLayer?.player?.currentItem?.presentationSize ?? CGSize.zero
        }
        return self.vlcPlayerLayer?.media.presentationSize ?? CGSize.zero
    }
    
    /// 开始/恢复 播放
    func play(){
        if self.avMode {
            avPlayerLayer?.player?.play()
        }else{
            vlcPlayerLayer?.play()
        }
    }
    
    /// 暂停播放视频
    func pause(){
        if self.avMode {
            avPlayerLayer?.player?.pause()
        }else{
            vlcPlayerLayer?.pause()
        }
    }
    
    /// 触发方法，在暂停播放时，触发播放操作，反之 暂停播放
    func trigger(){
        if self.isPlayingBehaviorRelay.value {
            self.pause()
        }else{
            self.play()
        }
    }
    
    /// 是指视频的播放速度
    /// - Parameter rate: 播放速度
    func setRate(rate: Float) {
        if self.avMode {
            avPlayerLayer?.player?.rate = rate
        }else{
            vlcPlayerLayer?.rate = rate
            rateBehaviorRelay.accept(rate)
        }
    }
    
    /// 跳转到一个特定的时间点
    /// - Parameter seconds: 特定的时间秒 比如 第 60秒处
    func seek(to seconds: Float) {
        /// 如果 小于 0 或者 大于 最多
        if seconds < 0 || seconds > self.duration { return }

        if self.avMode {
            if let timeScale = avPlayerLayer?.player?.currentItem?.duration.timescale {
                avPlayerLayer?.player?.seek(to: CMTimeMakeWithSeconds(Float64(seconds), preferredTimescale: timeScale))
            }
        }else{
            let space = seconds - self.currentSecondsBehaviorRelay.value
            // 向前跳转
            if Int32(space) > 0 {
                vlcPlayerLayer?.jumpForward(Int32(space))
            }else{
                vlcPlayerLayer?.jumpBackward(abs(Int32(space)))
            }
        }
    }
    
    
    /// 跳转视频
    /// 跳转该视频播放 多少秒
    /// - Parameter step: 正数 表示向前跳转 ，负数 表明 向后跳转
    func jump(by step: Float) {
        self.seek(to: self.currentSecondsBehaviorRelay.value + step)
    }
}


extension WZPlayerView{
    
    private func configAvPlayer(){
        
        let avItem = AVPlayerItem(url: url)
        let avPlayer = AVPlayer(playerItem: avItem)
        let avPlayerLayer = AVPlayerLayer(player: avPlayer)
        self.layer.addSublayer(avPlayerLayer)
        
        /// 监听 播放器 播放速度
        let rateObserve = avPlayer.rx.observe(Float.self, "rate").filterNil()
        
        /// 播放速度绑定
        rateObserve
            .bind(to: rateBehaviorRelay)
            .disposed(by: disposeBag)
        
        /// 是否播放 绑定
        rateObserve
            .map{ $0 > 0 }
            .bind(to: self.isPlayingBehaviorRelay)
            .disposed(by: disposeBag)
        
        /// 时间定时 绑定
        avPlayer.rx
            .currentSeconds
            .map{ Float(CMTimeGetSeconds($0)) }
            .bind(to: self.currentSecondsBehaviorRelay)
            .disposed(by: disposeBag)
        
        avItem.rx.observe(AVPlayerItem.Status.self, "status")
            .filter{ $0 == AVPlayerItem.Status.readyToPlay }
            .map{ _ in avItem.presentationSize }
            .bind(to: sizePublishRelay)
            .disposed(by: disposeBag)
        
        self.avPlayerLayer = avPlayerLayer
    }
}


extension WZPlayerView: VLCMediaDelegate {
    
    private func configVLCPlayer() {
        
        let vlcMedia = VLCMedia(url: url)
        let vlcPlayerLayer = VLCMediaPlayer()
        vlcPlayerLayer.media = vlcMedia
        vlcPlayerLayer.drawable = self
        
        vlcMedia.delegate = self
        
        vlcPlayerLayer.rx.observe(VLCTime.self, "time")
            .map{ $0?.value }
            .filterNil()
            .map{ $0.floatValue/1000 }
            .distinctUntilChanged()
            .bind(to: currentSecondsBehaviorRelay)
            .disposed(by: disposeBag)
        
        vlcPlayerLayer.rx.observe(Bool.self, "isPlaying")
            .filterNil()
            .distinctUntilChanged()
            .bind(to: self.isPlayingBehaviorRelay)
            .disposed(by: disposeBag)
        
        
        self.vlcPlayerLayer = vlcPlayerLayer
    }
    
    func mediaDidFinishParsing(_ aMedia: VLCMedia) {
        
        sizePublishRelay.accept(aMedia.presentationSize)
    }
}


extension Reactive where Base: WZPlayerView{
    
    /// 播放或者暂停
    var trigger: Binder<Void> {
        return Binder<Void>(self.base) { (view, _) in
            view.trigger()
        }
    }
    
    /// 是否正在播放
    var isPlaying: ControlProperty<Bool>{
        let observe = Binder<Bool>(self.base) { (view, isPlaying) in
            if isPlaying {
                view.play()
            }else{
                view.pause()
            }
        }
        return ControlProperty<Bool>(values: self.base.isPlayingBehaviorRelay, valueSink: observe)
    }
    
    /// 播放速度
    var rate: ControlProperty<Float>{
        let observe = Binder<Float>(self.base) { (view, rate) in
            view.setRate(rate: rate)
        }
        return ControlProperty<Float>(values: self.base.rateBehaviorRelay, valueSink: observe)
    }
    
    /// 当前的播放秒数
    var currentSeconds: Observable<Float>{
        return self.base.currentSecondsBehaviorRelay.asObservable()
    }
    
    var size: Observable<CGSize>{
        return self.base.sizePublishRelay.asObservable()
    }
}


extension Reactive where Base: AVPlayer{
    
    /// 当前的时间的 observer
    fileprivate var currentSeconds: Observable<CMTime> {
        return Observable<CMTime>.create { (obser) -> Disposable in
            
            let oneInterval = CMTimeMakeWithSeconds(1, preferredTimescale: Int32(NSEC_PER_SEC))
            
            let timeObserver = self.base.addPeriodicTimeObserver(forInterval: oneInterval, queue: nil) { (time) in
                obser.onNext(time)
            }
    
            return Disposables.create {
                self.base.removeTimeObserver(timeObserver)
            }
        }
    }
}


extension VLCMedia{
    
    var presentationSize: CGSize{
        
        var width: Int = 0
        var height: Int = 0
        
        for track in self.tracksInformation {
            guard let track = track as? [String: Any],
                let type = track[VLCMediaTracksInformationType] as? String,
                type == VLCMediaTracksInformationTypeVideo
                else { continue }
            
            if let widthVal = track[VLCMediaTracksInformationVideoWidth] as? Int {
                width = widthVal
            }
            
            if let heightVal = track[VLCMediaTracksInformationVideoHeight] as? Int {
                height = heightVal
            }
        }
        
        return CGSize(width: width, height: height)
    }
}
