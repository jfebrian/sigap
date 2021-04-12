//
//  SecurityAnnouncementDetailsViewController.swift
//  sigap
//
//  Created by Fandika Ikhsan on 12/04/21.
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
        // Do any additional setup after loading the view.
    }
    
    func setupView() {
        titleLabel.text = titleString!
        dateLabel.text = dateString!
        contentLabel.text = contentString!
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
