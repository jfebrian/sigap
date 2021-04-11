//
//  SecurityResidentsTableViewController.swift
//  sigap
//
//  Created by Joanda Febrian on 02/04/21.
//

import UIKit
import CloudKit

class SecurityResidentsTableViewController: UITableViewController, UISearchBarDelegate {
    let publicDatabase = CKContainer.default().publicCloudDatabase
    
    var residents = [UserInfo]()
    
    var residentsDictionary = [Character: [UserInfo]]()
    var sections =  [Character]()
    
    let residentIdentifier = "residentId"
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData()
        
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        tableView.refreshControl = control
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
            tapGesture.cancelsTouchesInView = false
            tableView.addGestureRecognizer(tapGesture)
        
        searchBar.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    func fetchData(){
        residents = []
        residentsDictionary = [:]
        sections = []
        let areaInfoID = UserDefaults.standard.value(forKey: "areaInfoID") as? String
        guard let area = areaInfoID else { return }
        let record = CKRecord(recordType: "Areas", recordID: CKRecord.ID(recordName: area))
        let reference = CKRecord.Reference(recordID: record.recordID, action: .deleteSelf)
        let predicate = NSPredicate(format: "area == %@", reference)
        let query = CKQuery(recordType: "UserInfo", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "address", ascending: true)]
        let queryOperation = CKQueryOperation(query: query)
        queryOperation.recordFetchedBlock = fetchContacts
        publicDatabase.add(queryOperation)
    }
    
    func fetchContacts(record: CKRecord!) {
        let resident = UserInfo(record)
        self.loadResident(resident)
    }
    
    func loadResident(_ resident: UserInfo){residents.append(resident)
        let section = resident.address[resident.address.startIndex]
        if residentsDictionary[section] == nil {
            residentsDictionary[section] = []
            sections.append(section)
        }
        residentsDictionary[section]!.append(resident)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
    }
    
    func processData(){
        DispatchQueue.main.async {
            self.residentsDictionary = [:]
            self.sections = []
            for resident in self.residents {
                let section = resident.address[resident.address.startIndex]
                if self.residentsDictionary[section] == nil {
                    self.residentsDictionary[section] = []
                    self.sections.append(section)
                }
                self.residentsDictionary[section]!.append(resident)
            }
            self.tableView.reloadData()
        }
    }
    
    func filterData(_ newResidents: [Character: [UserInfo]]){
        let sortedFilter = newResidents.sorted(by: { $0.0 < $1.0 })
        residentsDictionary = [:]
        sections = []
        for (key, value) in sortedFilter {
            guard value.count != 0 else { continue }
            if self.residentsDictionary[key] == nil {
                self.residentsDictionary[key] = []
                self.sections.append(key)
            }
            self.residentsDictionary[key]!.append(contentsOf: value)
        }
    }

    @objc func hideKeyboard() {
        view.endEditing(true)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return String(sections[section])
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return residentsDictionary[sections[section]]!.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: residentIdentifier)!
        
        cell.textLabel?.text = residentsDictionary[sections[indexPath.section]]![indexPath.row].address
        
        return cell
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        let lettersStringArray = sections.map { String($0)}
        return lettersStringArray
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        var filteredData = [Character: [UserInfo]]()
        
        let spaceStrippedSearchText = searchText.trimmingCharacters(in: .whitespaces)
        guard !spaceStrippedSearchText.isEmpty else {
            processData()
            self.tableView.reloadData()
            return
        }
        
        let smartSearchMatcher = SmartSearchMatcher(searchString: spaceStrippedSearchText)
        
        filteredData = residentsDictionary.mapValues {
            $0.filter { data in
                return smartSearchMatcher.matches(data.address) || smartSearchMatcher.matches(data.firstName) || smartSearchMatcher.matches(data.lastName)
            }
        }
        
        filterData(filteredData)
        self.tableView.reloadData()
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
    
    @objc func pullToRefresh() {
        tableView.refreshControl?.beginRefreshing()
        fetchData()
        tableView.refreshControl?.endRefreshing()
    }
    
    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let resident = residentsDictionary[sections[indexPath.section]]![indexPath.row]
        let config = UIContextMenuConfiguration(identifier: nil, previewProvider: {
            return ContactViewController(name: resident.address)
        }) { _ in
            let message = UIAction(
                title: "Message",
                image: UIImage(systemName: "message")) {_ in
                if let url = URL(string: "sms://" + resident.number) {
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
            }
            
            let call = UIAction(
                title: "Call",
                image: UIImage(systemName: "phone")) {_ in
                if let url = URL(string: "tel://" + resident.number) {
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
            }
            
            let share = UIAction(
                title: "Copy",
                image: UIImage(systemName: "doc.on.doc")) {_ in
                UIPasteboard.general.string = resident.number
                let alert = UIAlertController(title: "Copied to Clipboard!", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(alert, animated: true)
            }
            
            let remove = UIAction(
                title: "Remove",
                image: UIImage(systemName: "trash"),
                attributes: .destructive) {_ in
                let confirmAlert = UIAlertController(title: "Are you sure?", message: "This will remove \(resident.address) from Residents.", preferredStyle: .alert)

                confirmAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
                
                confirmAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
                    self.removeFromArea(resident.record)
                    let alert = UIAlertController(title: "Removed from Area!", message: nil, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    DispatchQueue.main.asyncAfter(deadline: .now()+2) {
                        self.fetchData()
                        self.present(alert, animated: true)
                    }
                }))
                self.present(confirmAlert, animated: true)
            }
            
            let menu = UIMenu(title: "", image: nil, identifier: nil, options: [], children: [message, call, share, remove])
            
            return menu
        }
        return config
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let resident = residentsDictionary[sections[indexPath.section]]![indexPath.row]
        performSegue(withIdentifier: "residentDetailSb", sender: resident)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "residentDetailSb" {
            let destination = segue.destination as! SecurityResidentDetailsViewController
            let origin = sender as! UserInfo
            destination.resident = origin
            destination.sender = self
        }
    }
    
}
