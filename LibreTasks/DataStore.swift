//
//  DataStore.swift
//  LibreTasks
//
//

import Foundation
import SwiftUI
import Combine

// TODO: Persist data storage across sessions

struct Task: Identifiable {
    var id = Int()
    var taskItem = String()
    var taskDate = Date()
    var taskPriority = String()
    var taskRecurrence = Bool()
    var taskRecurrenceInt = Int()
    var taskRecurrencePeriod = String()
}

class TaskDataStore: ObservableObject {
    @Published var tasks = [Task]()
}
