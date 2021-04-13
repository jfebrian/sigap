//
//  SecurityCctvTableViewCell.swift
//  sigap
//
//  Created by Joanda Febrian on 03/04/21.
//

import UIKit
import AVKit

class SecurityCctvTableViewCell: UITableViewCell {

    @IBOutlet weak var cctvImage: UIImageView!
    @IBOutlet weak var cctvLabel: UILabel!
    @IBOutlet weak var cctvView: UIView!
    
    
    var avPlayer: AVPlayer?
    var avPlayerLayer: AVPlayerLayer?
    var paused: Bool = false
    var videoPlayerItem: AVPlayerItem? = nil {
        didSet {
            /*
             If needed, configure player item here before associating it with a player.
             (example: adding outputs, setting text style rules, selecting media options)
             */
            avPlayer?.replaceCurrentItem(with: self.videoPlayerItem)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.setupMoviePlayer()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupMoviePlayer(){
        self.avPlayer = AVPlayer.init(playerItem: self.videoPlayerItem)
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer?.frame = CGRect(x: 0, y: 0, width: cctvImage.frame.size.width + 16, height: cctvImage.frame.size.height)
        cctvImage?.layer.masksToBounds = true
        avPlayerLayer?.masksToBounds = true
        avPlayerLayer?.videoGravity = .resizeAspectFill
        
        avPlayer?.volume = 0
        avPlayer?.actionAtItemEnd = .none
        
        cctvImage.layer.addSublayer(avPlayerLayer!)
        self.backgroundColor = .clear
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerItemDidReachEnd(notification:)),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: avPlayer?.currentItem)
    }
    
    func stopPlayback(){
        self.avPlayer?.pause()
    }
    
    func startPlayback(){
        self.avPlayer?.play()
    }
    
    // A notification is fired and seeker is sent to the beginning to loop the video again
    @objc
    func playerItemDidReachEnd(notification: Notification) {
        let p: AVPlayerItem = notification.object as! AVPlayerItem
        p.seek(to: CMTime.zero, completionHandler: nil)
        print("ITEM ENDS")
    }
    
}
