//
//  SecurityResidentsTableViewController.swift
//  sigap
//
//  Created by Joanda Febrian on 02/04/21.
//

import UIKit

class SecurityResidentsTableViewController: UITableViewController, UISearchBarDelegate {

    var dataArray = [String]()
    
    var residents = [Character: [String]]()
    var letters =  [Character]()
    
    let residentIdentifier = "residentId"
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initDummyData()
        
        processData(dataArray)
        
        searchBar.delegate = self
    }
    
    func initDummyData(){
        for char in "ABCDEFGHIJKLMNOPQRSTUVWXYZ" {
            for i in 1...5 {
                dataArray.append("\(char) - \(i)")
            }
        }
    }
    
    func processData(_ dataArray: [String]){
        letters = []

        letters = dataArray.map { data -> Character in
            return data[data.startIndex]
        }

        letters = letters.sorted()

        letters = letters.reduce([], { (list, name) -> [Character] in
            if !list.contains(name) {
                return list + [name]
            }
            return list
        })

        residents = [:]

        for entry in dataArray {
            if residents[entry[entry.startIndex]] == nil {
                residents[entry[entry.startIndex]] = [String]()
            }
            residents[entry[entry.startIndex]]!.append(entry)
        }

        for (letter, list) in residents {
            residents[letter] = list.sorted()
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return letters.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return String(letters[section])
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return residents[letters[section]]!.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: residentIdentifier)!
        
        cell.textLabel?.text = residents[letters[indexPath.section]]![indexPath.row]
        
        return cell
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        let lettersStringArray = letters.map { String($0)}
        return lettersStringArray
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        var filteredDataArray = [String]()
        
        let spaceStrippedSearchText = searchText.trimmingCharacters(in: .whitespaces)
        guard !spaceStrippedSearchText.isEmpty else {
            processData(dataArray)
            self.tableView.reloadData()
            return
        }
        
        let smartSearchMatcher = SmartSearchMatcher(searchString: spaceStrippedSearchText)
        filteredDataArray = dataArray.filter { data in return smartSearchMatcher.matches(data)}
        processData(filteredDataArray)
        
        self.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let contact = residents[letters[indexPath.section]]![indexPath.row]
        let config = UIContextMenuConfiguration(identifier: nil, previewProvider: {
            return ContactViewController(name: contact)
        }) { _ in
            let message = UIAction(
                title: "Message",
                image: UIImage(systemName: "message")) {_ in
                
            }
            
            let call = UIAction(
                title: "Call",
                image: UIImage(systemName: "phone")) {_ in
                
            }
            
            let share = UIAction(
                title: "Share",
                image: UIImage(systemName: "square.and.arrow.up")) {_ in
                
            }
            
            let remove = UIAction(
                title: "Remove",
                image: UIImage(systemName: "trash"),
                attributes: .destructive) {_ in
                
            }
            
            let menu = UIMenu(title: "", image: nil, identifier: nil, options: [], children: [message, call, share, remove])
            
            return menu
        }
        return config
    }
    
    
    
}
