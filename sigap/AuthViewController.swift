//
//  AuthViewController.swift
//  sigap
//
//  Created by Joanda Febrian on 02/04/21.
//

import UIKit

class AuthViewController: UIViewController, UITextFieldDelegate  {

    
    @IBOutlet weak var areaCodeTextField: UITextField!
    @IBOutlet weak var areaImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        switch restorationIdentifier {
        case "areaCodeSb":
            self.areaCodeTextField.delegate = self
        case "welcomeSb":
            self.areaImage.layer.cornerRadius = 15
        default:
            break
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == areaCodeTextField {
            textField.resignFirstResponder()
            areaCodeReturned()
            return false
        }
        return true
    }

    func areaCodeReturned() {
        performSegue(withIdentifier: "validAreaCode", sender: self)
    }
    

}
