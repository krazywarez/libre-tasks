//
//  ContentView.swift
//  LibreTasks
//
//

import SwiftUI
import Combine

struct ContentView: View {
    @ObservedObject var taskStore = TaskDataStore()
    @State private var newTask : String = ""
    @State private var taskPriority : String = ""
    @State private var query = ""
    @State private var newTaskDate: Date = Date()
    @State private var showingPopover = false
    @State private var recurringReminder = false
    @State private var recurrenceInteger : Int = 1
    @State private var showAlert: Bool = false
    
    enum Priority: String, CaseIterable, Identifiable {
        case A, B, C
        var id: Self { self }
    }
    @State private var selectedPriority: Priority = .A
    
    enum Recurrence: String, CaseIterable, Identifiable {
        case hours, days, weeks, months
        var id: Self { self }
    }
    @State private var selectedRecurrence: Recurrence = .hours
    
    var filteredTasks: [Task] {
        if query.isEmpty {
            return self.taskStore.tasks
        } else {
            return taskStore.tasks.filter {
                $0.taskItem.localizedCaseInsensitiveContains(query)
            }
        }
    }
    
    func addNewTask() {
        if newTask.isEmpty {
            showAlert = true
        } else {
            taskStore.tasks.append(Task(
                id: (taskStore.tasks.count + 1),
                taskItem: newTask,
                taskDate: newTaskDate,
                taskPriority: selectedPriority.rawValue,
                taskRecurrence: recurringReminder,
                taskRecurrenceInt: recurrenceInteger,
                taskRecurrencePeriod: selectedRecurrence.rawValue
            ))
            self.newTask = ""
            self.showingPopover = false
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(filteredTasks) { task in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(task.taskItem)
                                if (Date() > task.taskDate) {
                                    HStack {
                                        Text(task.taskDate, style: .date)
                                            .foregroundColor(.red)
                                            .font(.caption)
                                        Text(task.taskDate, style: .time)
                                            .foregroundColor(.red)
                                            .font(.caption)
                                        if (task.taskRecurrence == true) {
                                            (Text("[+") + Text(String(task.taskRecurrenceInt)) + Text(" ") + Text(task.taskRecurrencePeriod) + Text("]"))
                                                .foregroundColor(.red)
                                                .font(.caption)
                                        }
                                    }
                                } else {
                                    HStack {
                                        Text(task.taskDate, style: .date)
                                            .font(.caption)
                                        Text(task.taskDate, style: .time)
                                            .font(.caption)
                                        if (task.taskRecurrence == true) {
                                            (Text("[+") + Text(String(task.taskRecurrenceInt)) + Text(" ") + Text(task.taskRecurrencePeriod) + Text("]"))
                                                .font(.caption)
                                        }
                                    }
                                }
                            }
                            Spacer()
                            (Text("[#") + Text(task.taskPriority) + Text("]"))
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                print("\(task.taskItem) is being deleted.")
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            Button() {
                                print("\(task.taskItem) is being edited.")
                                // TODO: Add method to edit message in the DataStore
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                        }
                    }
                    .onDelete(perform: self.deleteTask)
                }
                .navigationBarTitle("Tasks")
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        EditButton()
                        Button {
                            showingPopover = true
                        } label: {
                            Image(systemName: "square.and.pencil")
                        }.popover(isPresented: $showingPopover) {
                            HStack {
                                Button {
                                    showingPopover = false
                                } label: {
                                    Text("Close")
                                }
                                Spacer()
                                Text("Add New Task")
                                Spacer()
                                Button(action: self.addNewTask, label: {
                                    Text("Save")
                                })
                            }
                            .padding()
                            Form {
                                Section(header: Text("Task Details")) {
                                    TextField("Task Title", text: self.$newTask)
                                        .onSubmit {
                                            if newTask.isEmpty {
                                                showAlert = true
                                            }
                                        }
                                        .alert(isPresented: $showAlert) {
                                            Alert(title: Text("Required Field"),
                                                  message: Text("You must enter a task title"),
                                                  dismissButton: .default(Text("OK")))
                                        }
                                    Picker("Priority:", selection: $selectedPriority) {
                                        Text("A").tag(Priority.A)
                                        Text("B").tag(Priority.B)
                                        Text("C").tag(Priority.C)
                                    }
                                    DatePicker("Scheduled:", selection: $newTaskDate)
                                        .datePickerStyle(CompactDatePickerStyle())
                                }
                                Section(header: Text("Repeating")) {
                                    Toggle("Repeating", isOn: $recurringReminder)
                                    if (recurringReminder == true) {
                                        HStack {
                                            TextField("", value: $recurrenceInteger, formatter: NumberFormatter())
                                            Stepper(value: $recurrenceInteger, in: 1...100) {
                                                EmptyView()
                                            }
                                            Picker("", selection: $selectedRecurrence) {
                                                Text("Hours").tag(Recurrence.hours)
                                                Text("Days").tag(Recurrence.days)
                                                Text("Weeks").tag(Recurrence.weeks)
                                                Text("Months").tag(Recurrence.months)
                                            }
                                        }
                                    }
                                }
                            }
                            .padding()
                            Spacer()
                        }
                    }
                }
            }
        }
        .searchable(text: $query, prompt: "Search tasks")
    }
    
    func deleteTask(at offsets: IndexSet) {
        taskStore.tasks.remove(atOffsets: offsets)
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
