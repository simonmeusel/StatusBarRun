//
//  StatusMenuController.swift
//  StatusBarRun
//
//  Created by Simon Meusel on 11.06.17.
//  Copyright © 2017 Simon Meusel. All rights reserved.
//

import Cocoa
import Foundation
import HotKey
import ServiceManagement

class StatusMenuController: NSObject, NSApplicationDelegate {
    
    let zeroWidthSpace = "​";
    
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
    var map: [String:JSON] = [:]
    
    var hotkeys: [HotKey] = []
    
    @IBAction func quit(_ sender: NSMenuItem) {
        NSApplication.shared().terminate(self)
    }
    
    @IBAction func enableLoginItem(_ sender: NSMenuItem) {
        setLoginItemEnabled(enabled: true)
    }
    
    @IBAction func disableLoginItem(_ sender: NSMenuItem) {
        setLoginItemEnabled(enabled: false)
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
    
    func setLoginItemEnabled(enabled: Bool) {
        if(!SMLoginItemSetEnabled(Bundle.main.bundleIdentifier! as CFString, enabled)) {
            let alert: NSAlert = NSAlert()
            alert.messageText = "Error while updating Login Item";
            alert.informativeText = "The 'start on login' status of this application could not be changed! Manage your Login Items: System Preferences -> Users & Groups -> Current User -> Login Items";
            alert.alertStyle = NSAlertStyle.warning;
            alert.addButton(withTitle: "Ok");
            alert.runModal();
        }
    }
    
    func updateMenu() {
        // Clear map and hotkeys
        map = [:]
        hotkeys = []
        
        // Load items from config
        reloadConfig()
        // Clear items in menu
        statusMenu.removeAllItems()
        // Add items to menu
        for (title, options) : (String, JSON) in json {
            statusMenu.addItem(generateMenu(title: title, options: options, nesting: 1))
        }
        // Add status bar run sub menu
        statusMenu.addItem(statusBarRunMenuItem)
        
        // Delete json
        json = JSON.null
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
                let hotkeyOptions = options["hotkey"]
                var hotkey: HotKey?;
                if (hotkeyOptions["key"] != JSON.null) {
                    let key = Key.init(string: hotkeyOptions["key"].stringValue)!
                    let modifiers = getHotkeyModifiers(modifierNames: hotkeyOptions["modifiers"].arrayValue);
                    hotkey = HotKey(key: key, modifiers: modifiers)
                } else if (hotkeyOptions["carbonKeyCode"] != JSON.null) {
                    hotkey = HotKey(carbonKeyCode: hotkeyOptions["carbonKeyCode"].uInt32!, carbonModifiers: hotkeyOptions["carbonModifiers"].uInt32!)
                }
                if (hotkey != nil) {
                    hotkey!.keyDownHandler = {
                        self.run(sender: item)
                    }
                    hotkeys.append(hotkey!)
                }
            }
            return item;
        }
    }
    
    func getHotkeyModifiers(modifierNames: [JSON]) -> NSEventModifierFlags {
        var modifiers = NSEventModifierFlags.command
        modifiers.remove(.command)
        loop: for modifierName in modifierNames {
            var modifier: NSEvent.ModifierFlags
            switch (modifierName.stringValue) {
            case "capsLock":
                modifier = NSEvent.ModifierFlags.capsLock
                break
            case "shift":
                modifier = NSEventModifierFlags.shift
                break
            case "control":
                modifier = NSEventModifierFlags.control
                break
            case "option":
                modifier = NSEventModifierFlags.option
                break
            case "command":
                modifier = NSEventModifierFlags.command
                break
            case "numericPad":
                modifier = NSEventModifierFlags.numericPad
                break
            case "help":
                modifier = NSEventModifierFlags.help
                break
            case "function":
                modifier = NSEventModifierFlags.function
                break
            default:
                continue loop
            }
            modifiers.insert(modifier);
        }
        return modifiers
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
                json = JSON.init([])
                print("Could not get json from file, make sure that config file contains valid json.")
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func run(sender: NSMenuItem) {
        let options = map[sender.title]!
        let process = Process();
        process.launchPath = options["launchPath"].stringValue
        process.arguments = options["arguments"].arrayObject as? [String]
        process.launch()
    }
}
