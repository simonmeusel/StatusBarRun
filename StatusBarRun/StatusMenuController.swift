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
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    // Status menu
    let statusMenu = NSMenu()
    // StatusBarRun submenu
    @IBOutlet weak var statusBarRunMenuItem: NSMenuItem!
    
    var hotkeyManager: HotkeyManager?
    var map: [String:JSON] = [:]
    
    @IBAction func quit(_ sender: NSMenuItem) {
        NSApplication.shared.terminate(self)
    }
    
    @IBAction func enableLoginItem(_ sender: NSMenuItem) {
        LoginItem.setEnabled(enabled: true)
    }
    
    @IBAction func disableLoginItem(_ sender: NSMenuItem) {
        LoginItem.setEnabled(enabled: false)
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
            if (options["label"] != JSON.null) {
                let labelOptions = options["label"];
                runProcess(options: labelOptions, terminationHandler: {(label) -> Void in
                    var text = label
                    let trimOutput = labelOptions["trimOutput"]
                    if (trimOutput.exists() && (trimOutput.type == .string || (trimOutput.type == .bool && trimOutput.boolValue))) {
                        var characters = " \n"
                        
                        if (trimOutput.type == .string) {
                            characters = trimOutput.stringValue
                        }
                        
                        text = text.trimmingCharacters(in: CharacterSet(charactersIn: characters))
                    }
                    item.title = labelOptions["prefix"].stringValue + text + labelOptions["suffix"].stringValue;
                })
            }
            return item;
        }
    }
    
    func getPrefix(nesting: Int) -> String {
        // Generate prefix for a given amount of nestings
        if (nesting == 1) {
            // No zero width space
            return "";
        }
        // One or more zero width spaces
        var prefix = zeroWidthSpace;
        for _ in 2..<nesting {
            prefix += zeroWidthSpace;
        }
        return prefix;
    }
    
    @objc func run(sender: NSMenuItem) {
        let options = map[sender.title]
        if (options != nil) {
            runProcess(options: options!, terminationHandler: nil)
        }
    }
    
    func runProcess(options: JSON, terminationHandler: ((String) -> Void)?) {
        let process = Process();
        process.launchPath = options["launchPath"].stringValue
        process.arguments = options["arguments"].arrayObject as? [String]
        var pipe: Pipe?;
        if (terminationHandler != nil) {
            pipe = Pipe()
            process.standardOutput = pipe
            process.terminationHandler = {(process) -> Void in
                let data = pipe!.fileHandleForReading.availableData
                terminationHandler!(String(data: data, encoding: String.Encoding.utf8)!)
            }
        }
        process.launch()
    }
}
