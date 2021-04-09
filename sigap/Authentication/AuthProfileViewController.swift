//
//  AuthProfileViewController.swift
//  sigap
//
//  Created by Joanda Febrian on 08/04/21.
//

import UIKit
import CloudKit

class AuthProfileViewController: UIViewController {

    @IBOutlet weak var phoneNumberTextField: AuthCustomTextField!
    @IBOutlet weak var addressTextField: AuthCustomTextField!
    
    @IBOutlet weak var noLabel1: UITextField!
    @IBOutlet weak var noLabel2: UITextField!
    @IBOutlet weak var noLabel3: UITextField!
    @IBOutlet weak var noLabel4: UITextField!
    @IBOutlet weak var noLabel5: UITextField!
    
    private let privateDatabase = CKContainer.default().privateCloudDatabase
    
    struct profileInfo {
        var phoneNumber: String
        var address: String
    }
    
    var inputInfo: profileInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        
        switch restorationIdentifier {
        case "phoneVerificationSb":
            self.sendNotification()
            setupTextFields()
        default:
            break
        }
    }
    
    func setupTextFields() {
        noLabel1.delegate = self
        noLabel2.delegate = self
        noLabel3.delegate = self
        noLabel4.delegate = self
        noLabel5.delegate = self
    }
    
    func sendNotification() {
        let center = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = "SIGAP Phone Verification"
        content.body = "Your OTP Code is 12345"
        content.sound = UNNotificationSound.default
        
        
        let date = Date(timeIntervalSinceNow: 1)
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
        
        center.add(request) { (error) in
            if error != nil {
                print("error: \(error!.localizedDescription)")
            }
        }
    }
    
    @IBAction func didTapNext(_ sender: Any) {
        let phone = phoneNumberTextField.text ?? ""
        let address = addressTextField.text ?? ""
        
        if phone.isEmpty || address.isEmpty {
            let alert = UIAlertController(title: "All fields must be filled!", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(alert, animated: true)
        } else if !phone.isPhone {
            let alert = UIAlertController(title: "Phone Number is Not Valid!", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(alert, animated: true)
        } else {
            let confirmAlert = UIAlertController(title: "Are you sure?", message: "Make sure you put in the right information.", preferredStyle: .alert)

            confirmAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            
            confirmAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
                let info = profileInfo(phoneNumber: self.phoneNumberTextField.text!.filter {!$0.isWhitespace}, address: self.addressTextField.text!)
                print("info: \(info)")
                self.performSegue(withIdentifier: "phoneVerification", sender: info)
            }))
            present(confirmAlert, animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "phoneVerification" {
            let destination = segue.destination as! AuthProfileViewController
            destination.inputInfo = sender as? profileInfo
        }
    }
    
    
    @IBAction func didTapResend(_ sender: Any) {
        self.sendNotification()
    }
    
    @IBAction func didTapSubmit(_ sender: Any) {
        let label1 = noLabel1.text ?? ""
        let label2 = noLabel2.text ?? ""
        let label3 = noLabel3.text ?? ""
        let label4 = noLabel4.text ?? ""
        let label5 = noLabel5.text ?? ""

        if label1.isEmpty || label2.isEmpty || label3.isEmpty || label4.isEmpty || label5.isEmpty {
            let alert = UIAlertController(title: "Invalid OTP code!", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(alert, animated: true)
        } else {
            let label = label1 + label2 + label3 + label4 + label5
            if label != "12345" {
                let alert = UIAlertController(title: "Wrong OTP code!", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                present(alert, animated: true)
            } else {
                guard let info = inputInfo else {return}
                self.completeProfile(info)
                let sb: UIStoryboard = UIStoryboard(name: "User", bundle: nil)
                let userVC = sb.instantiateViewController(identifier: "userSb")
                let userProfileVC = UINavigationController(rootViewController: userVC)
                userProfileVC.modalPresentationStyle = .fullScreen
                self.present(userProfileVC, animated: true, completion: nil)
            }
        }
    }
    
    func completeProfile(_ info: profileInfo){
        UserDefaults.standard.set(info.phoneNumber, forKey: "userPhoneNumber")
        UserDefaults.standard.set(info.address, forKey: "userAddress")
        
        guard let number = UserDefaults.standard.value(forKey: "userPhoneNumber") as? String else {return}
        guard let address = UserDefaults.standard.value(forKey: "userAddress") as? String else {return}
        guard let userID = UserDefaults.standard.value(forKey: "userInfoID") as? String else { return }
        
        let recordID = CKRecord.ID.init(recordName: userID)
        let userInfo = CKRecord.init(recordType: "UserInfo", recordID: recordID)
        
        userInfo.setValue(number, forKey: "number")
        userInfo.setValue(address, forKey: "address")

        let modifyRecord = CKModifyRecordsOperation(recordsToSave: [userInfo], recordIDsToDelete: nil)
        modifyRecord.savePolicy = CKModifyRecordsOperation.RecordSavePolicy.changedKeys
        modifyRecord.qualityOfService = QualityOfService.userInitiated
        modifyRecord.modifyRecordsCompletionBlock = { savedRecords, deletedRecordIDs, error in
            if error != nil {
                print("error: \(error!.localizedDescription)")
            }
        }
        privateDatabase.add(modifyRecord)
    }
}

extension AuthProfileViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return false }
        if text.count < 1, string.count > 0 {
            switch(textField){
            case noLabel1:
                noLabel2.becomeFirstResponder()
            case noLabel2:
                noLabel3.becomeFirstResponder()
            case noLabel3:
                noLabel4.becomeFirstResponder()
            case noLabel4:
                noLabel5.becomeFirstResponder()
            case noLabel5:
                noLabel5.resignFirstResponder()
            default:
                break
            }
            textField.text = string
            return false
        } else if text.count > 0 {
            if string.count > 0 {
                switch(textField){
                case noLabel1:
                    noLabel2.becomeFirstResponder()
                case noLabel2:
                    noLabel3.becomeFirstResponder()
                case noLabel3:
                    noLabel4.becomeFirstResponder()
                case noLabel4:
                    noLabel5.becomeFirstResponder()
                default:
                    break
                }
            }
            textField.text = string
            return false
        }
        return true
    }
    
    @objc func keyboardInputShouldDelete(_ textField: UITextField) -> Bool {
        guard let text = textField.text else { return false }
        if text.count == 0 {
            switch(textField){
            case noLabel5:
                noLabel4.becomeFirstResponder()
                noLabel4.text = ""
            case noLabel4:
                noLabel3.becomeFirstResponder()
                noLabel3.text = ""
            case noLabel3:
                noLabel2.becomeFirstResponder()
                noLabel2.text = ""
            case noLabel2:
                noLabel1.becomeFirstResponder()
                noLabel1.text = ""
            default:
                break
            }
            return false
        }
        return true
    }
}

extension String {

    var isBlank: Bool {
        get {
            let trimmed = trimmingCharacters(in: CharacterSet.whitespaces)
            return trimmed.isEmpty
        }
    }

    var isPhone: Bool {
        do {
            let phoneRegex = "(?:\\+\\d{2}\\s*(?:\\(\\d{2}\\))|(?:\\(\\d{2}\\)))?\\s*(\\d{4,5}\\-?\\d{4})"
            let regex = try NSRegularExpression(pattern: phoneRegex)
            return regex.firstMatch(in: self, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.count)) != nil
        } catch {
            return false
        }
    }
    
}
