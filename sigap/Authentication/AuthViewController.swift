//
//  AuthViewController.swift
//  sigap
//
//  Created by Joanda Febrian on 02/04/21.
//

import UIKit
import CloudKit
import AuthenticationServices

class AuthViewController: UIViewController, UITextFieldDelegate  {
    
    private let publicDatabase = CKContainer.default().publicCloudDatabase
    
    @IBOutlet weak var areaCodeTextField: UITextField!
    @IBOutlet weak var areaImage: UIImageView!
    @IBOutlet weak var areaNameLabel: UILabel!
    
    @IBOutlet weak var signInView: UIView!
    private let signInButton = ASAuthorizationAppleIDButton(type: .default, style: .whiteOutline)
    
    let codeRecordType = "Codes"
    let areaRecordType = "Areas"
    
    var area: Area?
    var code: Code?
    
    struct AreaCode {
        var area: Area?
        var code: Code?
    }
    
    var areacode = AreaCode()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
            tapGesture.cancelsTouchesInView = false
            view.addGestureRecognizer(tapGesture)
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        switch restorationIdentifier {
        case "areaCodeSb":
            setupCodeView()
        case "welcomeSb":
            setupWelcomeView()
        default:
            break
        }
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Setup Views
    
    func setupCodeView() {
        self.areaCodeTextField.returnKeyType = .go
        self.areaCodeTextField.delegate = self
    }
    
    func setupWelcomeView() {
        self.areaNameLabel.text = area?.name ?? "Unknown Area"
        if let photo = area?.image {
            self.areaImage.image = photo
        } else {
            self.areaImage.image = UIImage(systemName: "photo")
            self.areaImage.contentMode = .scaleAspectFit
            self.areaImage.layer.borderWidth = 1
            self.areaImage.layer.borderColor = UIColor.white.cgColor
        }
        self.areaImage.layer.cornerRadius = 15
        signInButton.frame = signInView.bounds
        signInView.addSubview(signInButton)
        signInButton.addTarget(self, action: #selector(didTapSignIn), for: .touchUpInside)
    }
    
    // MARK: - Input Area Code
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == areaCodeTextField, textField.text != "" {
            areaCodeTextField.resignFirstResponder()
            let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)

            let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
            loadingIndicator.hidesWhenStopped = true
            loadingIndicator.style = UIActivityIndicatorView.Style.medium
            loadingIndicator.startAnimating();

            alert.view.addSubview(loadingIndicator)
            self.present(alert, animated: true, completion: nil)
            fetchCode(textField.text!)
            return false
        }
        let alert = UIAlertController(title: "Code must not be empty!", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alert, animated: true)
        return true
    }
    
    // MARK: - Fetch Code
    
    func fetchCode(_ text: String) {
        let predicate = NSPredicate(format: "code == %@", text)
        let query = CKQuery(recordType: codeRecordType, predicate: predicate)
        publicDatabase.perform(query, inZoneWith: nil) { [weak self] records, error in
            DispatchQueue.main.async {
                if records!.count != 0 {
                    self?.processCode(records![0], error: error)
                } else {
                    self?.dismiss(animated: false, completion: {
                        let alert = UIAlertController(title: "Code not found!", message: nil, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                        self?.present(alert, animated: true)
                    })
                }
            }
        }
    }
    
    func processCode(_ record: CKRecord, error: Error?) {
        if error != nil {
            print("error: \(error!.localizedDescription)")
        } else {
            DispatchQueue.main.async {
                self.areacode.code = Code(record)
                self.fetchArea(record)
            }
        }
    }
    
    // MARK: - Fetch Area
    
    func fetchArea(_ code: CKRecord) {
        let areaRecordName = (code.value(forKey: "area") as! CKRecord.Reference).recordID.recordName
        publicDatabase.fetch(withRecordID: CKRecord.ID(recordName: areaRecordName)) { record, error in
            DispatchQueue.main.async {
                self.processArea(record!, error: error)
            }
        }
    }
    
    func processArea(_ record: CKRecord, error: Error?) {
        if error != nil {
            print("error: \(error!.localizedDescription)")
        } else {
            DispatchQueue.main.async {
                self.areaCodeTextField.resignFirstResponder()
                self.areacode.area = Area(record)
                self.dismiss(animated: false, completion: nil)
                self.performSegue(withIdentifier: "validAreaCode", sender: self.areacode)
            }
        }
    }
    
    // MARK: - Sign In With Apple
    
    @objc func didTapSignIn() {
        let appleIdProvider = ASAuthorizationAppleIDProvider()
        let request = appleIdProvider.createRequest()
        request.requestedScopes = [.fullName]
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
    
    // MARK: - Prepare Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "validAreaCode" {
            let destination = segue.destination as! AuthViewController
            let origin = sender as! AreaCode
            destination.code = origin.code
            destination.area = origin.area
        }
    }
}

// MARK: - Authorization Extensions


extension AuthViewController:  ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("error: \(error.localizedDescription)")
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let code = self.code else { return }
        guard let area = self.area else { return }
        var existNumber = false
        switch authorization.credential {
        case let credentials as ASAuthorizationAppleIDCredential:
            let userID = credentials.user
            if let firstName = credentials.fullName?.givenName,
               let lastName = credentials.fullName?.familyName {
                let record = CKRecord(recordType: "UserInfo", recordID: CKRecord.ID(recordName: userID))
                record["firstName"] = firstName
                record["lastName"] = lastName
                let areaReference = CKRecord.Reference(recordID: area.record!.recordID, action: .deleteSelf)
                record["area"] = areaReference
                publicDatabase.save(record) { (_, error) in
                    if error != nil {
                        print("error: \(error!.localizedDescription)")
                    } else {
                        UserDefaults.standard.set(firstName, forKey: "userFirstName")
                        UserDefaults.standard.set(lastName, forKey: "userLastName")
                        UserDefaults.standard.set(record.recordID.recordName, forKey: "userInfoID")
                        UserDefaults.standard.set(areaReference.recordID.recordName, forKey: "areaInfoID")
                        UserDefaults.standard.set(true, forKey: "isLogin")
                        UserDefaults.standard.set(code.isSecurity, forKey: "isSecurity")
                    }
                }
            } else {
                let recordID = CKRecord.ID(recordName: userID)
                let userInfo = CKRecord(recordType: "UserInfo", recordID: recordID)
                let areaReference = CKRecord.Reference(recordID: area.record!.recordID, action: .deleteSelf)
                let areaName = areaReference.recordID.recordName
                print("areaName")
                
                userInfo.setValue(areaReference, forKey: "area")

                let modifyRecord = CKModifyRecordsOperation(recordsToSave: [userInfo], recordIDsToDelete: nil)
                modifyRecord.savePolicy = CKModifyRecordsOperation.RecordSavePolicy.changedKeys
                modifyRecord.qualityOfService = QualityOfService.userInitiated
                modifyRecord.modifyRecordsCompletionBlock = { savedRecords, deletedRecordIDs, error in
                    if error != nil {
                        print("error: \(error!.localizedDescription)")
                    } else {
                        UserDefaults.standard.set(areaName, forKey: "areaInfoID")
                        UserDefaults.standard.set(userID, forKey: "userInfoID")
                        UserDefaults.standard.set(true, forKey: "isRegistered")
                        UserDefaults.standard.setValue(true, forKey: "isLogin")
                        UserDefaults.standard.set(code.isSecurity, forKey: "isSecurity")
                    }
                }
                publicDatabase.add(modifyRecord)
                existNumber = true
            }
            break
        default:
            break
        }
        
        if existNumber {
            if code.isSecurity {
                let sb: UIStoryboard = UIStoryboard(name: "Security", bundle: nil)
                let securityVC = sb.instantiateInitialViewController()
                securityVC!.modalPresentationStyle = .fullScreen
                self.present(securityVC!, animated: true, completion: nil)
            } else {
                let storyboard : UIStoryboard = UIStoryboard(name: "User", bundle: nil)
                let userHomeVC: UserViewController = storyboard.instantiateViewController(withIdentifier: "userSb") as! UserViewController
                let navigationHomeVC = UINavigationController(rootViewController: userHomeVC)
                navigationHomeVC.modalPresentationStyle = .fullScreen
                self.present(navigationHomeVC, animated: true, completion: nil)
            }
        } else {
            let storyboard: UIStoryboard = UIStoryboard(name: "Authentication-Profile", bundle: nil)
            let profileVC = storyboard.instantiateViewController(withIdentifier: "profileSb") as! AuthProfileViewController
            let navigationProfileVC = UINavigationController(rootViewController: profileVC)
            navigationProfileVC.modalPresentationStyle = .fullScreen
            self.present(navigationProfileVC, animated: true, completion: nil)
        }
        
    }
}

extension AuthViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
}
