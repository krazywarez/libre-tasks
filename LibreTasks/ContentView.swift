//
//  ContentView.swift
//  LibreTasks
//
//

import SwiftUI
import Combine

struct ContentView: View {
    @ObservedObject var taskStore = TaskDataStore()
    @State var newTask : String = ""
    @State private var query = ""
    @State var newTaskDate: Date = Date()
    
    var filteredTasks: [Task] {
        if query.isEmpty {
            return self.taskStore.tasks
        } else {
            return taskStore.tasks.filter {
                $0.taskItem.localizedCaseInsensitiveContains(query)
            }
        }
    }
    
    var addTaskBar: some View {
        HStack {
            VStack {
                TextField("Add Task: ", text: self.$newTask)
                DatePicker("Date: ", selection: $newTaskDate)
                    .datePickerStyle(CompactDatePickerStyle())
            }
            Button(action: self.addNewTask, label: {
                Text("Add New")
            })
        }
        .padding()
    }
    
    func addNewTask() {
        taskStore.tasks.append(Task(
            id: String(taskStore.tasks.count + 1),
            taskItem: newTask,
            taskDate: newTaskDate
        ))
        self.newTask = ""
    }

    var body: some View {
        NavigationView {
            VStack {
                addTaskBar.padding()
                List {
                    ForEach(filteredTasks) { task in
                        VStack(alignment: .leading) {
                            Text(task.taskItem)
                            Spacer()
                            if (Date() > task.taskDate) {
                                HStack {
                                    Text(task.taskDate, style: .date)
                                        .foregroundColor(.red)
                                        .font(.caption)
                                    Text(task.taskDate, style: .time)
                                        .foregroundColor(.red)
                                        .font(.caption)
                                }
                            } else {
                                HStack {
                                    Text(task.taskDate, style: .date)
                                        .font(.caption)
                                    Text(task.taskDate, style: .time)
                                        .font(.caption)
                                }
                            }
                        }
                    }
                    .onDelete(perform: self.deleteTask)
                }
                .navigationBarTitle("Tasks")
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        EditButton()
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
