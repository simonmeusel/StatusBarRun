//
//  Hotkey.swift
//  StatusBarRun
//
//  Created by Simon Meusel on 20.11.17.
//  Copyright © 2017 Simon Meusel. All rights reserved.
//

import Cocoa
import Foundation
import HotKey
import SwiftyJSON

class HotkeyManager {
    
    var hotkeys: [HotKey] = []
    var statusMenuController: StatusMenuController
    
    public init(statusMenuController: StatusMenuController) {
        self.statusMenuController = statusMenuController
    }
    
    func registerHotkey(hotkeyOptions: JSON, item: NSMenuItem) {
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
                self.statusMenuController.run(sender: item)
            }
            hotkeys.append(hotkey!)
        }
    }
    
    func getHotkeyModifiers(modifierNames: [JSON]) -> NSEvent.ModifierFlags {
        var modifiers = NSEvent.ModifierFlags.command
        modifiers.remove(NSEvent.ModifierFlags.command)
        loop: for modifierName in modifierNames {
            var modifier: NSEvent.ModifierFlags
            switch (modifierName.stringValue) {
            case "capsLock":
                modifier = NSEvent.ModifierFlags.capsLock
                break
            case "shift":
                modifier = NSEvent.ModifierFlags.shift
                break
            case "control":
                modifier = NSEvent.ModifierFlags.control
                break
            case "option":
                modifier = NSEvent.ModifierFlags.option
                break
            case "command":
                modifier = NSEvent.ModifierFlags.command
                break
            case "numericPad":
                modifier = NSEvent.ModifierFlags.numericPad
                break
            case "help":
                modifier = NSEvent.ModifierFlags.help
                break
            case "function":
                modifier = NSEvent.ModifierFlags.function
                break
            default:
                continue loop
            }
            modifiers.insert(modifier);
        }
        return modifiers
    }
}
