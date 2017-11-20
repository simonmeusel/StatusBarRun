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
}
