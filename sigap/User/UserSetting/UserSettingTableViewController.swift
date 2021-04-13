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
        tableView.isScrollEnabled = false
        

    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        40
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerTitle = ["LANGUAGE", "CONTACT", "HELP",""]
        
        
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: 40))
        let label = UILabel(frame: CGRect(x: 18, y: 16, width: headerView.frame.size.width-16, height: headerView.frame.size.height-20))
        label.text = headerTitle[section]
            label.textColor = UIColor(named: "color_labelSecondary")
        label.font = label.font.withSize(14)
            headerView.addSubview(label)

            return headerView;
    }
    
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor(named: "color_Background")
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 3 && indexPath.row==0 {
            let storyboard = UIStoryboard(name: "Authentication", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "areaCodeSb") as! AuthViewController
//            self.navigationController?.pushViewController(viewController, animated: true)
//            self.navigationController?.setNavigationBarHidden(true, animated: true)
//            self.navigationController?.setViewControllers([viewController], animated: false)
           
    let navigationLoginVC = UINavigationController(rootViewController: viewController)
            navigationLoginVC.modalPresentationStyle = .fullScreen
        present(navigationLoginVC, animated: true)
        }
    }
    


    
}




