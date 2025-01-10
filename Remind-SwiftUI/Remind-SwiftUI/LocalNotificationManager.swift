//
//  LocalNotificationManager.swift
//  Remind-SwiftUI
//
//  Created by Adam Hepp on 12/16/19.
//  Copyright © 2019 Adam Hepp. All rights reserved.
//

import Foundation
import SwiftUI

struct Notification {
    var id: String
    var title: String
    var date: Date
    var body: String
}

class LocalNotificationManager {
    var notifications = [Notification]()
    var removableNotifications = [String]()
    
    func requestPermission() -> Void {
        UNUserNotificationCenter
            .current()
            .requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                if granted == true && error == nil {
                    self.scheduleNotifications()
                }
        }
    }
    
    func addNotification(id: UUID, title: String, date: Date, body: String) -> Void {
        notifications.append(Notification(id: id.uuidString, title: title, date: date, body: body))
    }
    
    func removeNotification(id: UUID) -> Void {
        removableNotifications.append(id.uuidString)
    }
    
    func scheduleNotifications() -> Void {
        for notification in notifications {
            let content = UNMutableNotificationContent()
            content.title = notification.title
            content.body = notification.body
            content.sound = UNNotificationSound.default
            
            let dateInfo = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: Calendar.current.date(byAdding: .minute, value: -45, to: notification.date)!)
            
            UNUserNotificationCenter.current().add(UNNotificationRequest(identifier: notification.id, content: content, trigger: UNCalendarNotificationTrigger(dateMatching: dateInfo, repeats: false))) { error in
                guard error == nil else { return }
            }
        }
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: removableNotifications)
        
        notifications.removeAll()
        removableNotifications.removeAll()
    }
    
    
    
    func schedule() -> Void {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                self.requestPermission()
            case .authorized, .provisional:
                self.scheduleNotifications()
            default:
                break
            }
        }
    }
    
}
