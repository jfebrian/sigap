//
//  SecurityNewAnnouncementViewController.swift
//  sigap
//
//  Created by Joanda Febrian on 12/04/21.
//

import UIKit
import CloudKit

class SecurityNewAnnouncementViewController: UIViewController {
    let publicDatabase = CKContainer.default().publicCloudDatabase

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        doneButton.style = .done
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let tabBar = self.presentingViewController as! UITabBarController
        let navCon = tabBar.selectedViewController as! UINavigationController
        let tableViewCon = navCon.viewControllers.first as! SecurityAnnouncementsTableViewController
        tableViewCon.fetchData()
    }
    
    
    @IBAction func didTapCancel(_ sender: Any) {
        if titleTextField.text != "" || contentTextView.text != "" {
            let confirmAlert = UIAlertController(title: "Are you sure?", message: "All your progress will be lost.", preferredStyle: .alert)

            confirmAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            
            confirmAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
            }))
            self.present(confirmAlert, animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
        
    }
    
    @IBAction func didTapDone(_ sender: Any) {
        if titleTextField.text == "" || contentTextView.text == "" {
            let alert = UIAlertController(title: "All fields must be filled!", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true)
        } else {
            let confirmAlert = UIAlertController(title: "Are you sure?", message: "This announcement will be saved immediately and all residents will receive a notification.", preferredStyle: .alert)

            confirmAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            
            confirmAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
                let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
                let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
                loadingIndicator.hidesWhenStopped = true
                loadingIndicator.style = UIActivityIndicatorView.Style.medium
                loadingIndicator.startAnimating();
                alert.view.addSubview(loadingIndicator)
                self.present(alert, animated: true, completion: nil)
                self.saveAnnouncement(title: self.titleTextField.text!, content: self.contentTextView.text!)
            }))
            self.present(confirmAlert, animated: true)
        }
    }
    
    @objc func saveAnnouncement(title: String, content: String) {
        let record = CKRecord(recordType: "Announcements")
        record.setValue(title, forKey: "title")
        record.setValue(content, forKey: "content")
        let areaInfoID = UserDefaults.standard.value(forKey: "areaInfoID") as? String
        guard let area = areaInfoID else { return }
        let areaRecord = CKRecord(recordType: "Areas", recordID: CKRecord.ID(recordName: area))
        let reference = CKRecord.Reference(recordID: areaRecord.recordID, action: .deleteSelf)
        record.setValue(reference, forKey: "area")
        
        publicDatabase.save(record) { [weak self] record, error in
            if error != nil {
                print("error: \(error!.localizedDescription)")
            } else if record != nil {
                DispatchQueue.main.asyncAfter(deadline: .now()+2) {
                    self?.dismiss(animated: true, completion: {
                        self?.dismiss(animated: true, completion: nil)
                    })
                }
            }
        }
    }
}
