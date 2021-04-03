//
//  UserContactsTableViewController.swift
//  sigap
//
//  Created by Joanda Febrian on 03/04/21.
//

import UIKit

class UserContactsTableViewController: UITableViewController, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var contacts = [String: [String]]()
    var sections = [String]()
    
    let contactIdentifier = "emergencyContactId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Emergency Contacts"
        initDummyData()
        
        searchBar.delegate = self
        
    }
    
    func initDummyData(){
        contacts = [:]
        sections = []
        
        var categoryTitle = "Taman Setia Budi Indah"
        var categoryContacts = ["Front Gate", "East Gate", "Cluster A Manager", "Cluster B Manager"]
        sections.append(categoryTitle)
        contacts[categoryTitle] = categoryContacts
        
        categoryTitle = "Security Guards"
        categoryContacts = ["Juki Deden", "Joko Dodo", "Jaka Duda", "Jake Dude"]
        sections.append(categoryTitle)
        contacts[categoryTitle] = categoryContacts
        
        categoryTitle = "Police Department"
        categoryContacts = ["Nearest Polres", "Nearest Polda", "Emergency Hotline"]
        sections.append(categoryTitle)
        contacts[categoryTitle] = categoryContacts
        
        categoryTitle = "Medical Help"
        categoryContacts = ["Nearest Hospital", "Nearest Puskesmas", "Ambulance Hotline", "COVID-19 Hotline"]
        sections.append(categoryTitle)
        contacts[categoryTitle] = categoryContacts
        
        categoryTitle = "Fire Department"
        categoryContacts = ["Nearest Fire Department", "Fire Emergency Hotline"]
        sections.append(categoryTitle)
        contacts[categoryTitle] = categoryContacts
    }
    
    func processData(_ newContacts: [String: [String]]){
        contacts = newContacts
        sections = []
        sections = [String](contacts.keys.filter { contacts[$0]?.isEmpty == false })
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
        return contacts[sections[section]]!.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: contactIdentifier)!
        
        cell.textLabel?.text = contacts[sections[indexPath.section]]![indexPath.row]
        
        return cell
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        var filteredData = [String: [String]]()
        
        let spaceStrippedSearchText = searchText.trimmingCharacters(in: .whitespaces)
        
        initDummyData()
        
        guard !spaceStrippedSearchText.isEmpty else {
            self.tableView.reloadData()
            return
        }
        
        let smartSearchMatcher = SmartSearchMatcher(searchString: spaceStrippedSearchText)
        
        filteredData = contacts.mapValues {
            $0.filter { data in return smartSearchMatcher.matches(data)
            }
        }
        
        processData(filteredData)
        
        self.tableView.reloadData()
    }
}
