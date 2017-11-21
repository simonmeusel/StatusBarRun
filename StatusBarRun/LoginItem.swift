//
//  LoginItemManager.swift
//  StatusBarRun
//
//  Created by Simon Meusel on 20.11.17.
//  Copyright © 2017 Simon Meusel. All rights reserved.
//

import Cocoa
import Foundation
import ServiceManagement

class LoginItem {
    
    static func setEnabled(enabled: Bool) {
        if(!SMLoginItemSetEnabled(Bundle.main.bundleIdentifier! as CFString, enabled)) {
            let alert: NSAlert = NSAlert()
            alert.messageText = "Error while updating Login Item";
            alert.informativeText = "The 'start on login' status of this application could not be changed! Manage your Login Items: System Preferences -> Users & Groups -> Current User -> Login Items";
            alert.alertStyle = NSAlertStyle.warning;
            alert.addButton(withTitle: "Ok");
            alert.runModal();
        }
    }
    
}
