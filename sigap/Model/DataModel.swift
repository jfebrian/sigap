//
//  DataModel.swift
//  sigap
//
//  Created by Joanda Febrian on 08/04/21.
//

import Foundation
import UIKit
import CloudKit

struct Area {
    let image: UIImage
    let name: String
    var record: CKRecord?
}

extension Area {
    init(_ record: CKRecord) {
        self.record = record
        if let asset = record.value(forKey: "image") as? CKAsset,
           let data = try? Data(contentsOf: (asset.fileURL!)),
           let image = UIImage(data: data)
        {
            self.image = image
        } else {
            self.image = UIImage()
        }
        name = record.value(forKey: "name") as! String
    }
}

struct Code {
    let code: String
    let isSecurity: Bool
    let isUsed: Int
    let record: CKRecord
}

extension Code {
    init(_ record: CKRecord) {
        self.record = record
        code = record.value(forKey: "code") as! String
        isSecurity = (record.value(forKey: "isSecurity") as! NSNumber).boolValue
        isUsed = record.value(forKey: "isUsed") as! Int
    }
}