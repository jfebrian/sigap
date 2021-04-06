//
//  ContactViewController.swift
//  sigap
//
//  Created by Joanda Febrian on 06/04/21.
//

import UIKit

class ContactViewController: UIViewController {

    let label = UILabel()
    var contactName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        label.font = UIFont.systemFont(ofSize: 20)
        view.addSubview(label)
        view.backgroundColor = .secondarySystemBackground
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        label.text = contactName
    }
    
    init(name: String) {
        super.init(nibName: nil, bundle: nil)
        contactName = name
        preferredContentSize = CGSize(width: 360, height: 60)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}
