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
    
    // Create status item in system status bar
    let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
    // Status menu
    let statusMenu = NSMenu()
    // StatusBarRun submenu
    @IBOutlet weak var statusBarRunMenuItem: NSMenuItem!
    
    // URL of config file
    let URL = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".status-bar-run.json", isDirectory: false)
    // Config data
    var json = JSON.null
    
    @IBAction func quit(_ sender: NSMenuItem) {
        NSApplication.shared().terminate(self)
    }
    
    @IBAction func editConfig(_ sender: NSMenuItem) {
        // Open config in default editor
        let process = Process();
        process.launchPath = "/usr/bin/open"
        process.arguments = [URL.path]
        process.launch()
    }
    
    @IBAction func reloadConfig(_ sender: NSMenuItem) {
        updateMenu()
    }
    
    override func awakeFromNib() {
        statusItem.title = "R"
        statusItem.menu = statusMenu
        updateMenu()
    }
    
    func updateMenu() {
        // Load items from config
        reloadConfig()
        // Clear items in menu
        statusMenu.removeAllItems()
        // Add items to menu
        for (title, _) : (String, JSON) in json {
            let item = NSMenuItem(title: title, action: #selector(StatusMenuController.run(sender:)), keyEquivalent: "")
            item.target = self
            statusMenu.addItem(item)
        }
        // Add status bar run sub menu
        statusMenu.addItem(statusBarRunMenuItem)
    }
    
    func reloadConfig() {
        do {
            // Create config file if not already existing
            if (!FileManager.default.fileExists(atPath: URL.path)) {
                // Write empty JSON object to it
                try "{}".write(to: URL, atomically: false, encoding: String.Encoding.utf8)
            }
            
            // Load config data
            let data = try Data(contentsOf: URL, options: .alwaysMapped)
            // Convert to JSON
            json = try JSON(data: data)
            // If JSON could not be parsed
            if json == JSON.null {
                // TODO: Create empty json object
                print("Could not get json from file, make sure that config file contains valid json.")
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
