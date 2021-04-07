//
//  AuthViewController.swift
//  sigap
//
//  Created by Joanda Febrian on 02/04/21.
//

import UIKit
import CloudKit

class AuthViewController: UIViewController, UITextFieldDelegate  {

    
    @IBOutlet weak var areaCodeTextField: UITextField!
    @IBOutlet weak var areaImage: UIImageView!
    @IBOutlet weak var areaNameLabel: UILabel!
    
    let publicDatabase = CKContainer.default().publicCloudDatabase
    let areaRecordType = "Areas"
    
    var area: CKRecord?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        switch restorationIdentifier {
        case "areaCodeSb":
            self.areaCodeTextField.returnKeyType = .go
            self.areaCodeTextField.delegate = self
        case "welcomeSb":
            self.areaNameLabel.text = area?.value(forKey: "name") as? String
            self.areaImage.layer.cornerRadius = 15
            if let asset = area?.value(forKey: "image") as? CKAsset,
               let data = try? Data(contentsOf: (asset.fileURL!)),
               let image = UIImage(data: data)
            {
                self.areaImage.image = image
            }
            
        default:
            break
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == areaCodeTextField, textField.text != "" {
            let predicate = NSPredicate(format: "code = %@", textField.text!)
            let query = CKQuery(recordType: areaRecordType, predicate: predicate)
            publicDatabase.perform(query, inZoneWith: nil) { (results, error) in
                if error != nil {
                    print("error: \(error!.localizedDescription)")
                } else {
                    if results!.count == 0 {
                        print("code not found")
                    } else {
                        DispatchQueue.main.async {
                            textField.resignFirstResponder()
                            self.performSegue(withIdentifier: "validAreaCode", sender: results)
                        }
                    }
                }
            }
            return false
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "validAreaCode" {
            let destination = segue.destination as! AuthViewController
            let sentArea = sender as! [CKRecord]
            destination.area = sentArea[0]
        }
    }
}
