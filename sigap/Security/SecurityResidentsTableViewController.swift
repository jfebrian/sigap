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
        let cell = tableView.dequeueReusableCell(withIdentifier: residentIdentifier)! as UITableViewCell
        
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

}
