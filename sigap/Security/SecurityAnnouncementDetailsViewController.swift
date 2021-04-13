//
//  SecurityAnnouncementDetailsViewController.swift
//  sigap
//
//  Created by Joanda Febrian on 12/04/21.
//

import UIKit

class SecurityAnnouncementDetailsViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    
    var titleString: String?
    var dateString: String?
    var contentString: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    func setupView() {
        titleLabel.text = titleString!
        dateLabel.text = dateString!
        contentLabel.text = contentString!
    }

}
