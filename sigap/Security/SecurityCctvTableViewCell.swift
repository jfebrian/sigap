//
//  SecurityCctvTableViewCell.swift
//  sigap
//
//  Created by Joanda Febrian on 03/04/21.
//

import UIKit
import AVKit

class SecurityCctvTableViewCell: UITableViewCell {

    @IBOutlet weak var cctvView: UIView!
    @IBOutlet weak var cctvLabel: UILabel!
    
    let thumbnail = UIImage(named:"cctv_thumbnail")?.cgImage
    let myLayer = CALayer()
    var avPlayer: AVPlayer?
    var avPlayerLayer: AVPlayerLayer?
    var paused: Bool = false
    var videoPlayerItem: AVPlayerItem? = nil {
        didSet {
            avPlayer?.replaceCurrentItem(with: self.videoPlayerItem)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupMoviePlayer()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setupMoviePlayer(){
        myLayer.frame = CGRect(
            x: 0, y: 0,
            width: cctvView.frame.size.width+14,
            height: cctvView.frame.size.height)
        myLayer.contents = thumbnail
        myLayer.cornerRadius = 10
        myLayer.masksToBounds = true
        cctvView.layer.addSublayer(myLayer)
        self.avPlayer = AVPlayer.init(playerItem: self.videoPlayerItem)
        if #available(iOS 10.0, *) {
            avPlayer!.addObserver(self, forKeyPath: "timeControlStatus", options: [.old, .new], context: nil)
        } else {
            avPlayer!.addObserver(self, forKeyPath: "rate", options: [.old, .new], context: nil)
        }
        avPlayer?.automaticallyWaitsToMinimizeStalling = false
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer?.frame = CGRect(
            x: 0, y: 0,
            width: cctvView.frame.size.width+14,
            height: cctvView.frame.size.height)
        avPlayerLayer?.masksToBounds = true
        avPlayerLayer?.videoGravity = .resizeAspectFill
        
        
        avPlayer?.volume = 0
        avPlayer?.actionAtItemEnd = .none
        
        cctvView.layer.addSublayer(avPlayerLayer!)
        self.backgroundColor = .clear
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerItemDidReachEnd(notification:)),
            name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
            object: avPlayer?.currentItem)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let avPlayer = self.avPlayer else { return }
        if object as AnyObject? === avPlayer {
            if keyPath == "status" {
                if avPlayer.status == .readyToPlay {
                    self.myLayer.isHidden = true
                    avPlayer.play()
                }
            }
        }
    }
    
    func stopPlayback(){
        self.avPlayer?.pause()
    }
    
    func startPlayback(){
        self.avPlayer?.play()
    }
    
    @objc
    func playerItemDidReachEnd(notification: Notification) {
        let p: AVPlayerItem = notification.object as! AVPlayerItem
        p.seek(to: CMTime.zero, completionHandler: nil)
    }
    
}
