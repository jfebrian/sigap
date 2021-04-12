//
//  UserSettingLangViewController.swift
//  sigap
//
//  Created by Muhammad Rifki Widadi on 12/04/21.
//

import UIKit

class UserSettingLangViewController: UITableViewController {
    var lastSelection: IndexPath!
    
    @IBOutlet weak var bahasaCell: UITableViewCell!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        navigationItem.title = "Languange"
        bahasaCell.accessoryType = .checkmark

    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let numberOfRow = tableView.numberOfRows(inSection: indexPath.section)
        for row in 0..<numberOfRow{
            if let cell = tableView.cellForRow(at: IndexPath(row: row, section: indexPath.section)){
                cell.accessoryType = row == indexPath.row ? .checkmark : .none
            }
        }

        }


}
