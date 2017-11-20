//
//  Config.swift
//  StatusBarRun
//
//  Created by Simon Meusel on 20.11.17.
//  Copyright © 2017 Simon Meusel. All rights reserved.
//

import Foundation
import SwiftyJSON

class Config {
    
    // URL of config file
    static let URL = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".status-bar-run.json", isDirectory: false)
    
    static func load() -> JSON {
        do {
            // Create config file if not already existing
            if (!FileManager.default.fileExists(atPath: Config.URL.path)) {
                // Write empty JSON object to it
                try "{}".write(to: Config.URL, atomically: false, encoding: String.Encoding.utf8)
            }
            
            // Load config data
            let rawData = try Data(contentsOf: Config.URL, options: .alwaysMapped)
            // Convert to JSON
            return try JSON(data: rawData)
        } catch let error {
            print(error.localizedDescription)
        }
        print("Could not get json from file, make sure that config file contains valid json.")
        return JSON.init([])
    }
    
}

