//
//  UserAnnouncementsCardViewController.swift
//  sigap
//
//  Created by Joanda Febrian on 03/04/21.
//

import UIKit

class UserAnnouncementsCardViewController: UIViewController {

    @IBOutlet weak var handleArea: UIView!
    
    @IBOutlet weak var handleBar: UIView!
    
    @IBOutlet weak var updatedLabel: UILabel!
    
    @IBOutlet weak var firstTitleLabel: UILabel!
    @IBOutlet weak var firstContentLabel: UILabel!
    
    @IBOutlet weak var secondTitleLabel: UILabel!
    @IBOutlet weak var secondContentLabel: UILabel!
    
    @IBOutlet weak var thirdTitleLabel: UILabel!
    @IBOutlet weak var thirdContentLabel: UILabel!
    
    @IBOutlet weak var fourthTitleLabel: UILabel!
    @IBOutlet weak var fourthContentLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        handleBar.layer.cornerRadius = 2.0
    }

}
