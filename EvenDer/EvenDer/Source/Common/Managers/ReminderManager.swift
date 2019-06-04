//
//  ReminderManager.swift
//  EventMe
//
//  Created by Nitish Mishra on 18 May, 2018.
//  Copyright © 2017 Nitish Mishra. All rights reserved.
//

import Foundation
import EventKit

class ReminderManager {
    typealias RequestAccessCompletion = (_ granted: Bool) -> Void
    typealias RemindersCompletion = (_ reminders: [EKReminder]?) -> Void

    static let shared = ReminderManager()
    
    private let store = EKEventStore()
    
    var isAccessGranted: Bool {
        return EKEventStore.authorizationStatus(for: .reminder) == .authorized
    }
    
    private lazy var calendar: EKCalendar? = {
        return self.store.calendars(for: .reminder).filter{ $0.title == "EventMe" }.first
    }()
    
    // MARK: - Lifecycle
    
    private init() {}
    
    // MARK: - Work With Reminders
    
    func requestAccess(_ completion: @escaping RequestAccessCompletion) {
        store.requestAccess(to: .reminder) { granted, error in
            completion(granted)
        }
    }
    
    func fetchReminders(_ completion: @escaping RemindersCompletion) {
        guard isAccessGranted else {
                
                completion(nil)
                return
        }
        let calendars = store.calendars(for: .reminder)
        for re in calendars {
            print(re.title)
        }
        let filtecCal = calendars.filter{$0.title == "Calendar"}
        let predicate = store.predicateForReminders(in: filtecCal)
        store.fetchReminders(matching: predicate) { reminders in
            completion(reminders)
        }
    }
    
    func createReminder() -> EKReminder? {
        guard isAccessGranted else {
            return nil
        }
        
        let reminder = EKReminder(eventStore: store)
        //reminder.title = "EventMe"
        reminder.calendar = store.defaultCalendarForNewReminders()
        //reminder.calendar = calendar
        
        return reminder
    }
    
    func saveReminder(_ reminder: EKReminder) {
        guard isAccessGranted else {
            return
        }
        do {
            try store.save(reminder, commit: true)
        } catch {
            print(error)
        }
        
    }
    
    func removeReminder(_ reminder: EKReminder) {
        guard isAccessGranted else {
            return
        }
        do {
             try store.remove(reminder, commit: true)
        } catch {
            print(error)
        }
       
    }
}
