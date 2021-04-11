//
//  UserContactDetailsViewController.swift
//  sigap
//
//  Created by Joanda Febrian on 10/04/21.
//

import UIKit
import ContactsUI

class UserContactDetailsViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    
    @IBOutlet weak var messageButton: UIButton!
    @IBOutlet weak var numberView: UIView!
    @IBOutlet weak var actionsView: UIView!
    
    var contact: Contact?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
        numberView.layer.cornerRadius = 5.0
        actionsView.layer.cornerRadius = 5.0
        
    }
    
    func setupView() {
        nameLabel.text = contact?.name
        numberLabel.text = contact?.number
        categoryLabel.text = contact?.category
        guard let buttonEnable = contact?.receivesMessages else { return }
        messageButton.isEnabled = buttonEnable
        typeLabel.text =  buttonEnable ? "mobile" : "main"
    }
    
    func createContact(_ contact: Contact) -> CNMutableContact {
        let mutableContact = CNMutableContact()

        mutableContact.givenName = contact.name

        if contact.receivesMessages {
            mutableContact.phoneNumbers.append(CNLabeledValue(
                                                label: "mobile",
                                                value: CNPhoneNumber(stringValue: contact.number)))
        } else {
            mutableContact.phoneNumbers.append(CNLabeledValue(
                                                label: "main",
                                                value: CNPhoneNumber(stringValue: contact.number)))
        }
    
        return mutableContact
    }
    
    @IBAction func didTapMessage(_ sender: Any) {
        guard let contact = self.contact else { return }
        if let url = URL(string: "sms://" + contact.number) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        
    }
    
    @IBAction func didTapPhone(_ sender: Any) {
        guard let contact = self.contact else { return }
        if let url = URL(string: "tel://" + contact.number) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    @IBAction func didTapCopy(_ sender: Any) {
        guard let contact = self.contact else { return }
        UIPasteboard.general.string = contact.number
        let alert = UIAlertController(title: "Copied to Clipboard!", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    @IBAction func didTapShare(_ sender: Any) {
        guard let contact = self.contact else { return }
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
        
        guard let contact = self.contact else { return }
        let mutableContact = createContact(contact)
        
        let saveRequest = CNSaveRequest()
        saveRequest.add(mutableContact, toContainerWithIdentifier: nil)
        try? store.execute(saveRequest)
        
        let alert = UIAlertController(title: "Added to Contacts!", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
}
