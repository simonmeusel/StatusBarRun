//
//  StatusMenuController.swift
//  StatusBarRun
//
//  Created by Simon Meusel on 11.06.17.
//  Copyright © 2017 Simon Meusel. All rights reserved.
//

import Cocoa
import Foundation
import SwiftyJSON

class StatusMenuController: NSObject, NSApplicationDelegate {
    
    let zeroWidthSpace = "​";
    
    // Create status item in system status bar
    let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
    // Status menu
    let statusMenu = NSMenu()
    // StatusBarRun submenu
    @IBOutlet weak var statusBarRunMenuItem: NSMenuItem!
    
    var hotkeyManager: HotkeyManager?
    var map: [String:JSON] = [:]
    
    @IBAction func quit(_ sender: NSMenuItem) {
        NSApplication.shared().terminate(self)
    }
    
    @IBAction func enableLoginItem(_ sender: NSMenuItem) {
        LoginItemManager.setLoginItemEnabled(enabled: true)
    }
    
    @IBAction func disableLoginItem(_ sender: NSMenuItem) {
        LoginItemManager.setLoginItemEnabled(enabled: false)
    }
    
    @IBAction func editConfig(_ sender: NSMenuItem) {
        // Open config in default editor
        let process = Process();
        process.launchPath = "/usr/bin/open"
        process.arguments = [Config.URL.path]
        process.launch()
    }
    
    @IBAction func reloadConfig(_ sender: NSMenuItem) {
        updateMenu()
    }
    
    override func awakeFromNib() {
        statusItem.title = "R"
        statusItem.menu = statusMenu
        hotkeyManager = HotkeyManager(statusMenuController: self)
        updateMenu()
    }
    
    func updateMenu() {
        // Clear map and hotkeys
        map = [:]
        hotkeyManager!.hotkeys = []
        
        // Load items from config
        let data = Config.load()
        // Clear items in menu
        statusMenu.removeAllItems()
        // Add items to menu
        for (title, options) : (String, JSON) in data {
            statusMenu.addItem(generateMenu(title: title, options: options, nesting: 1))
        }
        // Add status bar run sub menu
        statusMenu.addItem(statusBarRunMenuItem)
    }
    
    func generateMenu(title: String, options: JSON, nesting: Int) -> NSMenuItem {
        if (options["launchPath"] == JSON.null) {
            // MenuItem with submenu
            let item = NSMenuItem(title: title, action: nil, keyEquivalent: "")
            item.submenu = NSMenu(title: title)
            for (nestedTitle, nestedOptions) : (String, JSON) in options {
                item.submenu?.addItem(generateMenu(title: nestedTitle, options: nestedOptions, nesting: nesting + 1))
            }
            return item;
        } else {
            // MenuItem without submenu
            let prefixedTitle = getPrefix(nesting: nesting) + title.replacingOccurrences(of: zeroWidthSpace, with: "");
            // Save action
            map[prefixedTitle] = options
            // Create item
            let item = NSMenuItem(title: prefixedTitle, action: #selector(StatusMenuController.run(sender:)), keyEquivalent: "")
            item.target = self
            // Create hotkey
            if (options["hotkey"] != JSON.null) {
                hotkeyManager!.registerHotkey(hotkeyOptions: options["hotkey"], item: item)
            }
            return item;
        }
    }
    
    func getPrefix(nesting: Int) -> String {
        if (nesting == 1) {
            return "";
        }
        var prefix = zeroWidthSpace;
        for _ in 2..<nesting {
            prefix += zeroWidthSpace;
        }
        return prefix;
    }
    
    func run(sender: NSMenuItem) {
        let options = map[sender.title]!
        let process = Process();
        process.launchPath = options["launchPath"].stringValue
        process.arguments = options["arguments"].arrayObject as? [String]
        process.launch()
    }
}
