//
//  SecurityCctvTableViewController.swift
//  sigap
//
//  Created by Joanda Febrian on 03/04/21.
//

import UIKit

class SecurityCctvTableViewController: UITableViewController {
    
    let imageArray = ["cctv_cam1","cctv_cam2","cctv_cam3","cctv_cam4","cctv_cam5","cctv_cam7","cctv_cam8"]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none

    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imageArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> SecurityCctvTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cctvId") as! SecurityCctvTableViewCell
        cell.cctvImage.image = UIImage(named: imageArray[indexPath.row])
        cell.cctvLabel.text = "Cam \(indexPath.row+1)"
        return cell
    }
}
