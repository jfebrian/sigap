//
//  UserAnnouncementsCardViewController.swift
//  sigap
//
//  Created by Joanda Febrian on 03/04/21.
//

import UIKit
import CloudKit

class UserAnnouncementsCardViewController: UIViewController {
    
    let publicDatabase = CKContainer.default().publicCloudDatabase
    
    var announcements = [Announcement]()

    @IBOutlet weak var handleArea: UIView!
    
    @IBOutlet weak var handleBar: UIView!
    
    @IBOutlet weak var updatedLabel: UILabel!
    
    @IBOutlet weak var firstTitleLabel: UILabel!
    @IBOutlet weak var firstContentLabel: UILabel!
    @IBOutlet weak var firstSeparator: UIView!
    @IBOutlet weak var firstSeparator2: UIView!
    @IBOutlet weak var firstView: UIView!
    
    @IBOutlet weak var secondTitleLabel: UILabel!
    @IBOutlet weak var secondContentLabel: UILabel!
    @IBOutlet weak var secondSeparator: UIView!
    @IBOutlet weak var secondView: UIView!
    
    @IBOutlet weak var thirdTitleLabel: UILabel!
    @IBOutlet weak var thirdContentLabel: UILabel!
    @IBOutlet weak var thirdSeparator: UIView!
    @IBOutlet weak var thirdView: UIView!
    
    @IBOutlet weak var fourthTitleLabel: UILabel!
    @IBOutlet weak var fourthContentLabel: UILabel!
    @IBOutlet weak var fourthSeparator: UIView!
    @IBOutlet weak var fourthView: UIView!
    
    @IBOutlet weak var viewAllButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        fetchData()
        handleBar.layer.cornerRadius = 2.0
    }
    
    func initView() {
        firstView.isHidden = true
        firstSeparator.isHidden = true
        firstSeparator2.isHidden = true
        
        secondView.isHidden = true
        secondSeparator.isHidden = true
        
        thirdView.isHidden = true
        thirdSeparator.isHidden = true
        
        fourthView.isHidden = true
        fourthSeparator.isHidden = true
        
        viewAllButton.isHidden = true
    }
    
    func setupView() {
        switch announcements.count {
        case 4...4:
            fourthTitleLabel.text = announcements[3].title
            fourthContentLabel.text = announcements[3].content
            fourthView.isHidden = false
            fourthSeparator.isHidden = false
            viewAllButton.isHidden = false
            fallthrough
        case 3...4:
            thirdTitleLabel.text = announcements[2].title
            thirdContentLabel.text = announcements[2].content
            thirdView.isHidden = false
            thirdSeparator.isHidden = false
            fallthrough
        case 2...4:
            secondTitleLabel.text = announcements[1].title
            secondContentLabel.text = announcements[1].title
            secondView.isHidden = false
            secondSeparator.isHidden = false
            fallthrough
        case 1...4:
            updatedLabel.text = "Last updated:  \(announcements.last!.date)"
            firstTitleLabel.text = announcements[0].title
            firstContentLabel.text = announcements[0].content
            firstView.isHidden = false
            firstSeparator.isHidden = false
            firstSeparator2.isHidden = false
            fallthrough
        default:
            break
        }
    }
    
    func fetchData(){
        announcements = []
        let areaInfoID = UserDefaults.standard.value(forKey: "areaInfoID") as? String
        guard let area = areaInfoID else { return }
        let record = CKRecord(recordType: "Areas", recordID: CKRecord.ID(recordName: area))
        let reference = CKRecord.Reference(recordID: record.recordID, action: .deleteSelf)
        let predicate = NSPredicate(format: "area == %@", reference)
        let query = CKQuery(recordType: "Announcements", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let queryOperation = CKQueryOperation(query: query)
        queryOperation.recordFetchedBlock = loadAnnouncement
        queryOperation.resultsLimit = 4
        publicDatabase.add(queryOperation)
    }
    
    func loadAnnouncement(record: CKRecord!) {
        let announcement = Announcement(record)
        announcements.append(announcement)
        DispatchQueue.main.async {
            self.setupView()
        }
    }

    @IBAction func didTapViewAll(_ sender: Any) {
        let vc = UIStoryboard.init(name: "User-Announcements",bundle: nil).instantiateInitialViewController() as! UserAnnouncementsTableViewController
        self.parent?.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func didTapFirstButton(_ sender: Any) {
        let sb: UIStoryboard = UIStoryboard(name: "User-Announcements", bundle: nil)
        let detailVC = sb.instantiateViewController(identifier: "userAnnouncementDetailsSb") as! UserAnnouncementDetailsViewController
        let data = announcements[0]
        detailVC.titleString = data.title
        detailVC.dateString = data.date
        detailVC.contentString = data.content
        self.parent?.navigationController?.pushViewController(detailVC, animated: true)
    }
    
    @IBAction func didTapSecondButton(_ sender: Any) {
        let sb: UIStoryboard = UIStoryboard(name: "User-Announcements", bundle: nil)
        let detailVC = sb.instantiateViewController(identifier: "userAnnouncementDetailsSb") as! UserAnnouncementDetailsViewController
        let data = announcements[1]
        detailVC.titleString = data.title
        detailVC.dateString = data.date
        detailVC.contentString = data.content
        self.parent?.navigationController?.pushViewController(detailVC, animated: true)
        
    }
    
    @IBAction func didTapThirdButton(_ sender: Any) {
        let sb: UIStoryboard = UIStoryboard(name: "User-Announcements", bundle: nil)
        let detailVC = sb.instantiateViewController(identifier: "userAnnouncementDetailsSb") as! UserAnnouncementDetailsViewController
        let data = announcements[2]
        detailVC.titleString = data.title
        detailVC.dateString = data.date
        detailVC.contentString = data.content
        self.parent?.navigationController?.pushViewController(detailVC, animated: true)
    }
    
    @IBAction func didTapFourthButton(_ sender: Any) {
        let sb: UIStoryboard = UIStoryboard(name: "User-Announcements", bundle: nil)
        let detailVC = sb.instantiateViewController(identifier: "userAnnouncementDetailsSb") as! UserAnnouncementDetailsViewController
        let data = announcements[3]
        detailVC.titleString = data.title
        detailVC.dateString = data.date
        detailVC.contentString = data.content
        self.parent?.navigationController?.pushViewController(detailVC, animated: true)
        
    }
}
