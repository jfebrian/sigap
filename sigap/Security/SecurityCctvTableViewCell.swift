//
//  SecurityCctvTableViewCell.swift
//  sigap
//
//  Created by Joanda Febrian on 03/04/21.
//

import UIKit

class SecurityCctvTableViewCell: UITableViewCell {

    @IBOutlet weak var cctvImage: UIImageView!
    @IBOutlet weak var cctvLabel: UILabel!
    @IBOutlet weak var cctvView: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
