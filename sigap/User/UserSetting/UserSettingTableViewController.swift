//
//  UserSettingTableViewController.swift
//  sigap
//
//  Created by Muhammad Rifki Widadi on 08/04/21.
//

import UIKit

class UserSettingTableViewController: UITableViewController {

    @IBOutlet weak var logoutCell: UITableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Settings"
       
        

    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 3 && indexPath.row==0 {
            let storyboard = UIStoryboard(name: "Authentication", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "areaCodeSb") as! AuthViewController
//            self.navigationController?.pushViewController(viewController, animated: true)
            self.navigationController?.setNavigationBarHidden(true, animated: true)
            self.navigationController?.setViewControllers([viewController], animated: false)
        }
    }
    


    
}




