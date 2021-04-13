//
//  UserAnnouncementsTableViewController.swift
//  sigap
//
//  Created by Joanda Febrian on 12/04/21.
//

import UIKit
import CloudKit

class UserAnnouncementsTableViewController: UITableViewController {

    let publicDatabase = CKContainer.default().publicCloudDatabase
    
    var announcements = [Announcement]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Announcements"
        
        let xib = UINib(nibName: "AnnouncementCell", bundle: nil)
        tableView.register(xib, forCellReuseIdentifier: "announcementCell")
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        tableView.refreshControl = control
        
        fetchData()
        
    }
    
    func fetchData(){
        announcements = []
        let areaInfoID = UserDefaults.standard.value(forKey: "areaInfoID") as? String
        guard let area = areaInfoID else { return }
        let record = CKRecord(recordType: "Areas", recordID: CKRecord.ID(recordName: area))
        let reference = CKRecord.Reference(recordID: record.recordID, action: .deleteSelf)
        let predicate = NSPredicate(format: "area == %@", reference)
        let query = CKQuery(recordType: "Announcements", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "modificationDate", ascending: true)]
        let queryOperation = CKQueryOperation(query: query)
        queryOperation.recordFetchedBlock = loadAnnouncement
        publicDatabase.add(queryOperation)
    }
    
    func loadAnnouncement(record: CKRecord!) {
        let announcement = Announcement(record)
        announcements.append(announcement)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    @objc func pullToRefresh() {
        tableView.refreshControl?.beginRefreshing()
        fetchData()
        tableView.refreshControl?.endRefreshing()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return announcements.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "announcementCell", for: indexPath) as! AnnouncementCell
        
        cell.titleLabel.text = announcements[indexPath.row].title
        cell.contentLabel.text = announcements[indexPath.row].content
        cell.dateLabel.text = announcements[indexPath.row].shortDate

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let senderData = announcements[indexPath.row]
        performSegue(withIdentifier: "userDetailSegue", sender: senderData)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "userDetailSegue" {
            let destination = segue.destination as! UserAnnouncementDetailsViewController
            let data = sender as! Announcement
            destination.titleString = data.title
            destination.dateString = data.date
            destination.contentString = data.content
        }
    }
}
