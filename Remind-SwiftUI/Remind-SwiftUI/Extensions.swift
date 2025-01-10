//
//  Extensions.swift
//  Remind-SwiftUI
//
//  Created by Adam Hepp on 12/13/19.
//  Copyright © 2019 Adam Hepp. All rights reserved.
//

import Foundation
import CoreData

// MARK: - Protocol implementation to Core Data entities

extension Reminder: Identifiable {}

extension ShoppingItem: Identifiable {}

extension Test: Identifiable {}

// MARK: - Shared Core Data stack for app group

class NSCustomPersistentContainer: NSPersistentContainer {
    
    override open class func defaultDirectoryURL() -> URL {
        var storeURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.RemindExt")
        storeURL = storeURL?.appendingPathComponent("Remind_SwiftUI.sqlite")
        return storeURL!
    }
    
}

// MARK: - Helper class for data flow between SwiftUI and UIKit parts

class upcomingTest {
    var date = Date()
    var subject = ""
    var type = ""
}

// MARK: - Shared helper functions

func formatDate(date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .none
    return dateFormatter.string(from: date)
}

func formatDateAndTime(date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .short
    return dateFormatter.string(from: date)
}

func formatTime(date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .none
    dateFormatter.timeStyle = .short
    return dateFormatter.string(from: date)
}

func formatPrice(price: Decimal) -> String {
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .currency
    numberFormatter.currencySymbol = ""
    numberFormatter.maximumFractionDigits = 0
    return numberFormatter.string(for: price)!
}
