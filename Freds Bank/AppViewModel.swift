//
//  AppViewModel.swift
//  Freds Bank
//
//  Created by Jason Jobe on 4/28/20.
//  Copyright © 2020 Jason Jobe. All rights reserved.
//

import Foundation
import SQiftViewModel

class AppViewModel: BaseViewModel {

    override func configureDatabase() throws {
        try super.configureDatabase()
        let bundle =  Bundle(for: Self.self)
        
        let path = bundle.path(forResource: "db_create", ofType: "sql")!
        try db.execute(contentsOfFile: path)
        try db.createApplicationDatabase(reset: true)
        try load(URL(fileURLWithPath: bundle.bundlePath.appending("/branches.json")),
                  into: "_branches")

         try load(URL(fileURLWithPath: bundle.bundlePath.appending("/atms.json")),
                  keypath: "data", into: "_atms")
    }

}
