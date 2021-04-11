//
//  UserContactsTableViewController.swift
//  sigap
//
//  Created by Joanda Febrian on 03/04/21.
//

import UIKit
import CloudKit

class UserContactsTableViewController: UITableViewController, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    let publicDatabase = CKContainer.default().publicCloudDatabase
    
    var contacts = [Contact]()
    
    var contactDictionary = [String: [Contact]]()
    var sections = [String]()
    
    let contactIdentifier = "emergencyContactId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Emergency Contacts"
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = UIColor(named: "color_labelSecondary")
        fetchData()
        searchBar.delegate = self
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
    
    func fetchData(){
        let query = CKQuery(recordType: "Contacts", predicate: NSPredicate(value: true))
        let queryOperation = CKQueryOperation(query: query)
        queryOperation.recordFetchedBlock = fetchContacts
        publicDatabase.add(queryOperation)
    }
    
    func fetchContacts(record: CKRecord!) {
        let name = record.value(forKey: "name") as! String
        let number = record.value(forKey: "number") as! String
        let receivedMessages = record.value(forKey: "receivesMessages") as! NSNumber
        let categoryRecordID = (record.value(forKey: "category") as! CKRecord.Reference).recordID
        publicDatabase.fetch(withRecordID: categoryRecordID) { (category, error) in
            if error != nil {
                print("error: \(error!.localizedDescription)")
            } else {
                guard let categoryName = category?.value(forKey: "name") as? String else { return }
                let contact = Contact(name: name, category: categoryName, number: number, receivesMessages: receivedMessages.boolValue)
                self.loadContact(contact)
            }
        }
    }
    
    func loadContact(_ contact: Contact){
        DispatchQueue.main.async {
            self.contacts.append(contact)
            if self.contactDictionary[contact.category] == nil {
                self.contactDictionary[contact.category] = []
                self.sections.append(contact.category)
            }
            self.contactDictionary[contact.category]?.append(contact)
            self.tableView.reloadData()
        }
    }
    
    func processData(){
        contactDictionary = [:]
        sections = []
        for contact in contacts {
            if contactDictionary[contact.category] == nil {
                contactDictionary[contact.category] = []
                sections.append(contact.category)
            }
            contactDictionary[contact.category]?.append(contact)
        }
    }
    
    
    func filterData(_ newContacts: [String: [Contact]]){
        contactDictionary = newContacts
        sections = []
        sections = [String](contactDictionary.keys.filter { contactDictionary[$0]?.isEmpty == false })
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return String(sections[section])
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        (view as! UITableViewHeaderFooterView).contentView.backgroundColor = UIColor(named: "color_backgroundSecondary")
        (view as! UITableViewHeaderFooterView).textLabel?.textColor = UIColor.white
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactDictionary[sections[section]]!.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: contactIdentifier)!
        
        cell.textLabel?.text = contactDictionary[sections[indexPath.section]]![indexPath.row].name
        cell.textLabel?.textColor = UIColor(named: "color_label")
        
        return cell
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        var filteredData = [String: [Contact]]()
        let spaceStrippedSearchText = searchText.trimmingCharacters(in: .whitespaces)
        
        processData()
        
        guard !spaceStrippedSearchText.isEmpty else {
            self.tableView.reloadData()
            return
        }
        
        let smartSearchMatcher = SmartSearchMatcher(searchString: spaceStrippedSearchText)
        
        filteredData = contactDictionary.mapValues {
            $0.filter { data in
                return smartSearchMatcher.matches(data.name)
            }
        }
        
        filterData(filteredData)
        self.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let contact = contactDictionary[sections[indexPath.section]]![indexPath.row]
        performSegue(withIdentifier: "contactDetailSb", sender: contact)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "contactDetailSb" {
            let destination = segue.destination as! UserContactDetailsViewController
            let origin = sender as! Contact
            destination.contact = origin
        }
    }
    
    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let contact = contactDictionary[sections[indexPath.section]]![indexPath.row]
        let config = UIContextMenuConfiguration(identifier: nil, previewProvider: {
            return ContactViewController(name: contact.name)
        }) { _ in
            var actions = [UIAction]()
            if contact.receivesMessages {
                let message = UIAction(
                    title: "Message",
                    image: UIImage(systemName: "message")) {_ in
                    if let url = URL(string: "sms://" + contact.number) {
                        if UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                    }
                }
                actions.append(message)
            }
            
            let call = UIAction(
                title: "Call",
                image: UIImage(systemName: "phone")) {_ in
                if let url = URL(string: "tel://" + contact.number) {
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
            }
            actions.append(call)
            
            let share = UIAction(
                title: "Copy",
                image: UIImage(systemName: "doc.on.doc")) {_ in
                UIPasteboard.general.string = contact.number
                let alert = UIAlertController(title: "Copied to Clipboard!", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(alert, animated: true)
            }
            actions.append(share)
            
            let menu = UIMenu(title: "", image: nil, identifier: nil, options: [], children: actions)
            return menu
        }
        return config
    }
}
