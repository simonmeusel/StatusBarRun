//
//  StatusMenuController.swift
//  StatusBarRun
//
//  Created by Simon Meusel on 11.06.17.
//  Copyright © 2017 Simon Meusel. All rights reserved.
//

import Cocoa
import Foundation

class StatusMenuController: NSObject, NSApplicationDelegate {
    @IBOutlet weak var statusMenu: NSMenu!
    
    let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
    // URL of config file
    let URL = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("status-bar-run.json", isDirectory: false)
    var json = JSON.null
    
    @IBAction func quit(_ sender: NSMenuItem) {
        NSApplication.shared().terminate(self)
    }
    
    @IBAction func editItems(_ sender: NSMenuItem) {
        // Open config in default editor
        let process = Process();
        process.launchPath = "/usr/bin/open"
        process.arguments = [URL.path]
        process.launch()
    }
    
    override func awakeFromNib() {
        statusItem.title = "R"
        statusItem.menu = statusMenu
        do {
            if (!FileManager.default.fileExists(atPath: URL.path)) {
                try "{}".write(to: URL, atomically: false, encoding: String.Encoding.utf8)
            }
            
            let data = try Data(contentsOf: URL, options: .alwaysMapped)
            json = try JSON(data: data)
            if json != JSON.null {
                for (title, _) : (String, JSON) in json {
                    let item = NSMenuItem(title: title, action: #selector(StatusMenuController.run(sender:)), keyEquivalent: "")
                    item.target = self
                    statusMenu.addItem(item)
                }
            } else {
                print("Could not get json from file, make sure that file contains valid json.")
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func run(sender: NSMenuItem) {
        let options = json[sender.title]
        let process = Process();
        process.launchPath = options["launchPath"].stringValue
        process.arguments = options["arguments"].arrayObject as? [String]
        process.launch()
    }
}
