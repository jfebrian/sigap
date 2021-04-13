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
    
    
    let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 5, y: 5, width: 50, height: 50))
    var thumbnailIndex: Int?
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
        addVignette()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func addVignette() {
        let g = CAGradientLayer()
        g.type = .radial
        g.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        let center = CGPoint(x: 0.5, y: 0.5)
        g.startPoint = center
        let radius = 2
        g.endPoint = CGPoint(x: radius, y: radius)
        g.frame = CGRect(
            x: 0, y: 0,
            width: cctvView.frame.size.width+14,
            height: cctvView.frame.size.height)
        cctvView.layer.insertSublayer(g, at: 10)
    }
    
    func setThumbnail() {
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = .large
        loadingIndicator.startAnimating()
        let thumbnail = UIImage(
            named:"cctv_thumbnail\(thumbnailIndex!)")?.cgImage
        myLayer.frame = CGRect(
            x: 0, y: 0,
            width: cctvView.frame.size.width,
            height: cctvView.frame.size.height)
        myLayer.contents = thumbnail
        myLayer.cornerRadius = 10
        myLayer.masksToBounds = true
    }
    
    func setupMoviePlayer(){
        cctvView.layer.addSublayer(myLayer)
        cctvView.addSubview(loadingIndicator)
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
