//
//  Home.swift
//  SimpleTodo
//
//  Created by Isini Bandara on 2023-06-05.
//

import SwiftUI

struct Home: View {
    ///View Properties
    @Environment(\.self) private var env
    @State private var filterDate: Date = .init()
    @State private var showPendingTasks: Bool = true
    @State private var showCompletedTasks: Bool = true
    var body: some View {
        List {
            DatePicker(selection: $filterDate, displayedComponents: [.date]){
                
            }
            .labelsHidden()
            .datePickerStyle(.graphical)
            
            DisclosureGroup(isExpanded: $showPendingTasks){
                /// Custom  core data filter view, which will display only pending tasks on this day
                CustomFilteringDataView(displayPendingTask: true, filterDate: filterDate){
                    TaskRow(task: $0, isPendingTask: true)
                }
                
            } label: {
                Text("Pending Task's")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            DisclosureGroup(isExpanded: $showCompletedTasks){
                /// Custom  core data filter view, which will display only completed tasks on this day
                CustomFilteringDataView(displayPendingTask: false, filterDate: filterDate){
                    TaskRow(task: $0, isPendingTask: false)
                }
            } label: {
                Text("Completed Task's")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .toolbar{
            ToolbarItem(placement: .bottomBar){
                Button {
                    //simply open pending task view
                    //then adding empty task
                    do{
                        let task = Task(context: env.managedObjectContext)
                        task.id = .init()
                        task.date = filterDate
                        task.title = ""
                        task.isCompleted = false
                        
                        try env.managedObjectContext.save()
                        showPendingTasks = true
                    } catch{
                        print(error.localizedDescription)
                    }
                    
                } label: {
                    HStack{
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                        
                        Text("New Task")
                    }
                    .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
struct TaskRow: View {
    @ObservedObject var task: Task
    var isPendingTask: Bool
    //View Properties
    @Environment(\.self) private var env
    @FocusState private var showKeyboard: Bool
    var body: some View {
        HStack(spacing: 12){
            Button{
                task.isCompleted.toggle()
                save()
            } label: {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title)
                    .foregroundColor(.blue)
            }
            .buttonStyle(.plain)
            
            VStack(alignment: .leading, spacing: 4) {
                TextField("Task Title", text: .init(get: {
                    return task.title ?? ""
                }, set: { value in
                    task.title = value
                }))
                .focused($showKeyboard)
                .onSubmit {
                    removeEmptyTask()
                    save()
                }
                .foregroundColor(isPendingTask ? .primary : .gray)
                .strikethrough(!isPendingTask,pattern: .dash,color: .primary)
                
                ///custom date picker
                Text((task.date ?? .init()).formatted(date: .omitted, time: .shortened))
                    .font(.callout)
                    .foregroundColor(.gray)
                    .overlay{
                        DatePicker(selection: .init(get: {
                            return task.date ?? .init()
                        }, set: { value in
                            task.date = value
                            //saving Date when ever it's updated
                            save()
                            
                        }), displayedComponents: [.hourAndMinute]){
                            
                        } .labelsHidden()
                            //hiding view by utilizing blendmode modifier
                            .blendMode(.destinationOver)
                    }

            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .onAppear{
            if (task.title ?? "").isEmpty {
                showKeyboard = true
            }
        }
        //verifying content when user leaves the App
        .onChange(of: env.scenePhase){ newValue in
            if newValue != .active{
                ///checking if it's empty
                removeEmptyTask()
                save()
                save()
            }
        }
        //adding swipe to delete
        .swipeActions(edge: .trailing, allowsFullSwipe: true){
            Button(role: .destructive){
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
                    env.managedObjectContext.delete(task)
                    save()
                }

            }label: {
                Image(systemName: "trash.fill")
            }
        }
    }
    //context saving method
    func save(){
        do{
            try env.managedObjectContext.save()
        }catch{
            print(error.localizedDescription)
        }
    }
    
    //removing empty task
    func removeEmptyTask(){
        if( task.title ?? "").isEmpty{
            //Removing empty task
            env.managedObjectContext.delete(task)
        }
        save()
    }
}
