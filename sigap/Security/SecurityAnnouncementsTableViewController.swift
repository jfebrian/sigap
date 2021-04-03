//
//  SecurityAnnouncementsTableViewController.swift
//  sigap
//
//  Created by Joanda Febrian on 03/04/21.
//

import UIKit

class SecurityAnnouncementsTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "announcementId") as! SecurityAnnouncementsTableViewCell
        
        cell.titleLabel.text = "Penutupan Gerbang Utara Pasca Lockdown Pandemi"
        cell.contentLabel.text = "Kami pihak security dari perumahan Taman Setia Budi Indah sepakat untuk menutup gerbang utara untuk meningkatkan prosedur keamanan dari komplek ini. Dimohon untuk seluruh warga agar dapat menggunakan pintu gerbang selatan selama lockdown pandemi ini."
        cell.dateLabel.text = generateDate(daysBack: indexPath.row)

        return cell
    }

    func generateDate(daysBack: Int)-> String{
        let day = daysBack
        let today = Date(timeIntervalSinceNow: 0)
        let gregorian  = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)
        
        var offsetComponents = DateComponents()
        offsetComponents.day = -1 * Int(day - 1)
        
        let randomDate = gregorian?.date(byAdding: offsetComponents, to: today, options: .init(rawValue: 0) )
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, y"
        return dateFormatter.string(from: randomDate!)
    }
}