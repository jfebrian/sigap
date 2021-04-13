//
//  SecurityCctvTableViewController.swift
//  sigap
//
//  Created by Joanda Febrian on 03/04/21.
//

import UIKit
import AVKit

class SecurityCctvTableViewController: UITableViewController {
    
    let imageArray = ["cctv_cam1","cctv_cam2","cctv_cam3","cctv_cam4","cctv_cam5","cctv_cam7","cctv_cam8"]
//    let imageArray = ["cctv_cam1"]
    var avPlayer: AVPlayer!
    var visibleIP : IndexPath?
    var aboutToBecomeInvisibleCell = -1
    var avPlayerLayer: AVPlayerLayer!
    var paused: Bool = false
    var firstLoad = true

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        visibleIP = IndexPath.init(row: 0, section: 0)
        
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        tableView.refreshControl = control
    }
    
//    func playVideo(cell: UITableViewCell) {
//        let cctvCell = cell as! SecurityCctvTableViewCell
//
//        let videoURL = URL(string: "https://www.rmp-streaming.com/media/big-buck-bunny-360p.mp4")
//        let player = AVPlayer(url: videoURL!)
//        let playerLayer = AVPlayerLayer(player: player)
//        playerLayer.frame = cctvCell.cctvImage.frame
//        playerLayer.videoGravity = .resizeAspectFill
//        cell.layer.addSublayer(playerLayer)
//        player.play()
//    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imageArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cctvId") as! SecurityCctvTableViewCell
        print("INDEXPATH \(indexPath.row % 3)")
        
        cell.cctvLabel.text = imageArray[indexPath.row]
        
        if indexPath.row % 3 == 1 {
            let videoURL = URL(string: "https://www.rmp-streaming.com/media/big-buck-bunny-360p.mp4")
            cell.videoPlayerItem = AVPlayerItem.init(url: videoURL!)
            cell.imageView?.image = nil
            cell.imageView?.backgroundColor = .gray
            return cell
        } else {
            cell.imageView?.backgroundColor = .red
            cell.imageView?.image = UIImage(named: imageArray[indexPath.row])
            cell.imageView?.contentMode = .scaleToFill
            cell.imageView?.sizeToFit()
            return cell
        }
    }
    
    func playerItemDidReachEnd(notification: Notification) {
        let p: AVPlayerItem = notification.object as! AVPlayerItem
        p.seek(to: CMTime.zero, completionHandler: nil)
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let indexPaths = self.tableView.indexPathsForVisibleRows
        var cells = [Any]()
        for ip in indexPaths!{
            if let videoCell = self.tableView.cellForRow(at: ip) as? SecurityCctvTableViewCell{
                cells.append(videoCell)
            }
        }
        let cellCount = cells.count
        if cellCount == 0 {return}
        if cellCount == 1{
            if visibleIP != indexPaths?[0]{
                visibleIP = indexPaths?[0]
            }
            if let videoCell = cells.last! as? SecurityCctvTableViewCell{
                self.playVideoOnTheCell(cell: videoCell, indexPath: (indexPaths?.last)!)
            }
        }
        if cellCount >= 2 {
            for i in 0..<cellCount{
                let cellRect = self.tableView.rectForRow(at: (indexPaths?[i])!)
                let intersect = cellRect.intersection(self.tableView.bounds)
//                curerntHeight is the height of the cell that
//                is visible
                let currentHeight = intersect.height
                print("\n \(currentHeight)")
                let cellHeight = (cells[i] as AnyObject).frame.size.height
//                0.95 here denotes how much you want the cell to display
//                for it to mark itself as visible,
//                .95 denotes 95 percent,
//                you can change the values accordingly
                if currentHeight > (cellHeight * 0.95){
                    if visibleIP != indexPaths?[i]{
                        visibleIP = indexPaths?[i]
                        print ("visible = \(indexPaths?[i])")
                        if let videoCell = cells[i] as? SecurityCctvTableViewCell {
                            self.playVideoOnTheCell(cell: videoCell, indexPath: (indexPaths?[i])!)
                        }
                    }
                }
                else{
                    if aboutToBecomeInvisibleCell != indexPaths?[i].row{
                        aboutToBecomeInvisibleCell = (indexPaths?[i].row)!
                        if let videoCell = cells[i] as? SecurityCctvTableViewCell{
                            self.stopPlayBack(cell: videoCell, indexPath: (indexPaths?[i])!)
                        }

                    }
                }
            }
        }
    }
    
    func checkVisibilityOfCell(cell : SecurityCctvTableViewCell, indexPath : IndexPath){
        let cellRect = self.tableView.rectForRow(at: indexPath)
        let completelyVisible = self.tableView.bounds.contains(cellRect)
        if completelyVisible {
            self.playVideoOnTheCell(cell: cell, indexPath: indexPath)
        }
        else{
            if aboutToBecomeInvisibleCell != indexPath.row{
                aboutToBecomeInvisibleCell = indexPath.row
                self.stopPlayBack(cell: cell, indexPath: indexPath)
            }
        }
    }
    
    func playVideoOnTheCell(cell : SecurityCctvTableViewCell, indexPath : IndexPath){
        cell.startPlayback()
    }
    
    func stopPlayBack(cell : SecurityCctvTableViewCell, indexPath : IndexPath){
        cell.stopPlayback()
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        print("end = \(indexPath)")
        if let videoCell = cell as? SecurityCctvTableViewCell{
            videoCell.stopPlayback()
        }

        paused = true
    }
    
    @objc func pullToRefresh() {
        tableView.refreshControl?.beginRefreshing()
        tableView.refreshControl?.endRefreshing()
    }
}
