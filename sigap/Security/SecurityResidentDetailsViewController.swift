//
//  SecurityResidentDetailsViewController.swift
//  sigap
//
//  Created by Joanda Febrian on 11/04/21.
//

import UIKit
import CloudKit
import ContactsUI

class SecurityResidentDetailsViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    
    @IBOutlet weak var numberView: UIView!
    @IBOutlet weak var actionsView: UIView!
    
    
    let publicDatabase = CKContainer.default().publicCloudDatabase
    
    var resident: UserInfo?
    var sender: SecurityResidentsTableViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sender?.fetchData()
    }
    
    func setupView() {
        guard let resident = self.resident else { return }
        imageView.image = resident.image ?? UIImage(systemName: "person.circle.fill")
        imageView.layer.cornerRadius = imageView.frame.size.width/2
        nameLabel.text = "\(resident.firstName) \(resident.lastName)"
        addressLabel.text = resident.address
        numberLabel.text = resident.number
        
        numberView.layer.cornerRadius = 5.0
        actionsView.layer.cornerRadius = 5.0
    }
    
    func createContact(_ contact: UserInfo) -> CNMutableContact {
        let mutableContact = CNMutableContact()

        mutableContact.givenName = contact.firstName
        mutableContact.familyName = contact.lastName
        
        mutableContact.phoneNumbers.append(CNLabeledValue(
                                                label: "mobile",
                                                value: CNPhoneNumber(stringValue: contact.number)))
        return mutableContact
    }
    
    func removeFromArea(_ record: CKRecord) {
        record.setNilValueForKey("area")
        
        let modifyRecord = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
        modifyRecord.savePolicy = CKModifyRecordsOperation.RecordSavePolicy.changedKeys
        modifyRecord.qualityOfService = QualityOfService.userInitiated
        modifyRecord.modifyRecordsCompletionBlock = { savedRecords, deletedRecordIDs, error in
            if error != nil {
                print("error: \(error!.localizedDescription)")
            }
        }
        
        publicDatabase.add(modifyRecord)
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
    
    @IBAction func didTapMessage(_ sender: Any) {
        guard let contact = self.resident else { return }
        if let url = URL(string: "sms://" + contact.number) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    @IBAction func didTapCall(_ sender: Any) {
        guard let contact = self.resident else { return }
        if let url = URL(string: "tel://" + contact.number) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    @IBAction func didTapCopy(_ sender: Any) {
        guard let contact = self.resident else { return }
        UIPasteboard.general.string = contact.number
        let alert = UIAlertController(title: "Copied to Clipboard!", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    @IBAction func didTapShare(_ sender: Any) {
        guard let contact = self.resident else { return }
        let sharedContact: CNContact = createContact(contact)

        let fileManager = FileManager.default
        let cacheDirectory = try! fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)

        let fileLocation = cacheDirectory.appendingPathComponent("\(CNContactFormatter().string(from: sharedContact)!).vcf")

        let contactData = try! CNContactVCardSerialization.data(with: [sharedContact])
        do {
            try contactData.write(to: fileLocation, options: .atomicWrite)
        } catch {
            print("error")
        }

        let activityVC = UIActivityViewController(activityItems: [fileLocation], applicationActivities: nil)
        present(activityVC, animated: true, completion: nil)
    }

    @IBAction func didTapAdd(_ sender: Any) {
        let store = CNContactStore()
        
        guard let contact = self.resident else { return }
        let mutableContact = createContact(contact)
        
        let saveRequest = CNSaveRequest()
        saveRequest.add(mutableContact, toContainerWithIdentifier: nil)
        try? store.execute(saveRequest)
        
        let alert = UIAlertController(title: "Added to Contacts!", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    @IBAction func didTapRemove(_ sender: Any) {
        guard let resident = self.resident else { return }
        let confirmAlert = UIAlertController(title: "Are you sure?", message: "This will remove \(resident.address) from Residents.", preferredStyle: .alert)

        confirmAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        confirmAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
            self.removeFromArea(resident.record)
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Removed from Area!", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { _ in
                    self.navigationController?.popViewController(animated: true)
                }))
                self.setupLoading()
                DispatchQueue.main.asyncAfter(deadline: .now()+2) {
                    self.dismiss(animated: true) {
                        self.present(alert, animated: true)
                    }
                }
            }
        }))
        self.present(confirmAlert, animated: true)
    }
    
}
