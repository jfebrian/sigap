//
//  SecurityAnnouncementsTableViewController.swift
//  sigap
//
//  Created by Joanda Febrian on 03/04/21.
//

import UIKit
import CloudKit

class SecurityAnnouncementsTableViewController: UITableViewController {
    
    let publicDatabase = CKContainer.default().publicCloudDatabase
    
    var announcements = [Announcement]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    func deleteAnnouncement(_ indexPath: Int) {
        let confirmAlert = UIAlertController(title: "Are you sure?", message: "This announcement will be deleted permanently.", preferredStyle: .alert)

        confirmAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        confirmAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
            self.setupLoading()
            guard let record = self.announcements[indexPath].record else { return }
            self.publicDatabase.delete(withRecordID: record.recordID) { (string, error) in
                if error != nil {
                    print("error: \(error!.localizedDescription)")
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now()+2 ) {
                        self.announcements.remove(at: indexPath)
                        self.tableView.reloadData()
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }))
        self.present(confirmAlert, animated: true)
    }
    
    func setupLoading() {
        let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.medium
        loadingIndicator.startAnimating();
        alert.view.addSubview(loadingIndicator)
        self.present(alert, animated: true, completion: nil)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "announcementId") as! AnnouncementTableViewCell
        
        cell.titleLabel.text = announcements[indexPath.row].title
        cell.contentLabel.text = announcements[indexPath.row].content
        cell.dateLabel.text = announcements[indexPath.row].shortDate

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let senderData = announcements[indexPath.row]
        performSegue(withIdentifier: "detailSegue", sender: senderData)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailSegue" {
            let destination = segue.destination as! SecurityAnnouncementDetailsViewController
            let data = sender as! Announcement
            destination.titleString = data.title
            destination.dateString = data.date
            destination.contentString = data.content
        }
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Delete") { [weak self] record, view, completionHandler  in
            self?.deleteAnnouncement(indexPath.row)
            completionHandler(true)
        }
        
        let configuration = UISwipeActionsConfiguration(actions: [delete])
        return configuration
    }
    
}
