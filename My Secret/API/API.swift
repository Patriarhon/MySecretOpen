//
//  API.swift
//  My Secret
//
//  Created by Petr on 17.05.2020.
//  Copyright © 2020 Petr. All rights reserved.
//

import Foundation
import CloudKit

class API {
    static let container = CKContainer.init(identifier: "")
    static let privateDB = container.privateCloudDatabase
    static let publicDB = container.publicCloudDatabase
}
