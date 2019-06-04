//
//  EventsManager.swift
//  EventMe
//
//  Created by Nitish Mishra on 18 May, 2018.
//  Copyright © 2017 Nitish Mishra. All rights reserved.
//

import Foundation
import EventKit

class EventManager {
    typealias RequestAccessCompletion = (_ granted: Bool) -> Void
    typealias EventsCompletion = (_ events: [EKEvent]?) -> Void

    static let shared = EventManager()
    
    private let store = EKEventStore()
    
    var isAccessGranted: Bool {
        return EKEventStore.authorizationStatus(for: .event) == .authorized
    }
    
    private lazy var calendar: EKCalendar? = {
        return self.store.calendars(for: .event).filter{ $0.title == "EventMe" }.first
    }()
    
    // MARK: - Lifecycle
    
    private init() {}
    
    // MARK: - Work With Reminders
    
    func requestAccess(_ completion: @escaping RequestAccessCompletion) {
        store.requestAccess(to: .event) { granted, error in
            completion(granted)
        }
    }
    
    func fetchEvents(_ completion: @escaping EventsCompletion) {
        guard isAccessGranted else {
                completion(nil)
                return
        }
        let calendars = store.calendars(for: .event)
        let filtecCal = calendars.filter{$0.title == "Calendar"}
        let date = Date()
        let currentCalendar = Calendar.current
        let start = currentCalendar.date(byAdding: .month, value: -1, to: date)!
        let end = currentCalendar.date(byAdding: .month, value: 1, to: date)!
        
        let predicate = store.predicateForEvents(withStart: start, end: end, calendars: filtecCal)
        completion(store.events(matching: predicate))
        
    }
    
    func createEvent() -> EKEvent? {
        guard isAccessGranted else {
            return nil
        }
        
        let event = EKEvent(eventStore: store)
        //event.title = "EventMe"
        event.calendar = store.defaultCalendarForNewEvents
        //event.calendar = calendar
        
        return event
    }
    
    func saveEvent(_ event: EKEvent) {
        guard isAccessGranted else {
            return
        }
        do {
            try store.save(event, span: EKSpan.thisEvent, commit: true)
        } catch {
            print(error)
        }
        
    }
    
    func removeEvent(_ event: EKEvent) {
        guard isAccessGranted else {
            return
        }
        do {
            try store.remove(event, span: EKSpan.thisEvent, commit: true)
        } catch {
            print(error)
        }
    }
}
