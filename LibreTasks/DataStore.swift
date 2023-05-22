//
//  DataStore.swift
//  LibreTasks
//
//

import Foundation
import SwiftUI
import Combine

struct Task: Identifiable {
    var id = String()
    var taskItem = String()
    var taskDate = Date()
}

class TaskDataStore: ObservableObject {
    @Published var tasks = [Task]()
}
