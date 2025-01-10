//
//  ContentView.swift
//  Remind-SwiftUI
//
//  Created by Adam Hepp on 12/13/19.
//  Copyright © 2019 Adam Hepp. All rights reserved.
//

import SwiftUI
import CoreData

struct ContentView: View {
    
    // MARK: - Core Data property wrappers
    
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @FetchRequest(entity: Reminder.entity(), sortDescriptors: [NSSortDescriptor(key: "date", ascending: true)]) var reminders: FetchedResults<Reminder>
    @FetchRequest(entity: Test.entity(), sortDescriptors: [NSSortDescriptor(key: "date", ascending: true)]) var tests: FetchedResults<Test>
    @FetchRequest(entity: ShoppingItem.entity(), sortDescriptors: [NSSortDescriptor(key: "title", ascending: true)]) var shoppingItems: FetchedResults<ShoppingItem>
    
    // MARK: - State variables
    
    @State private var newTitle = ""
    @State private var newContent = ""
    @State private var newDate = Date()
    @State private var newPrice = ""
    @State private var showCreator = false
    @State private var showDatePicker = true
    
    // MARK: - View body
    
    var body: some View {
        
        TabView {
            
            // MARK: - Reminders tab
            
            NavigationView {
                
                List {
                    ForEach(self.reminders) { reminder in
                        HStack(alignment: .center) {
                            Button(action: {
                                reminder.done.toggle()
                            }) {
                                Image(systemName: reminder.done ? "checkmark.circle.fill" : "circle")
                                    .imageScale(.large)
                                    .foregroundColor(reminder.done ? .green : .primary)
                            }.padding()
                            VStack(alignment: .leading) {
                                Text("\(reminder.content!)")
                                    .font(.title)
                                Text(formatDate(date: reminder.date!))
                                    .font(.footnote)
                            }
                        }
                    }.onDelete { (indexSet) in
                        let reminderToDelete = self.reminders[indexSet.first!]
                        self.manager.removeNotification(id: reminderToDelete.identifier!)
                        self.managedObjectContext.delete(reminderToDelete)
                        
                        do {
                            try self.managedObjectContext.save()
                            self.manager.schedule()
                        } catch {
                            print(error)
                        }
                    }
                    
                }.navigationBarTitle("Reminders")
                    .navigationBarItems(trailing:
                        Button(action: {
                            self.showCreator.toggle()
                            self.newDate = Date()
                        }) {
                            Image(systemName: "plus")
                                .imageScale(.large)
                                .font(Font.title.weight(.thin))
                                .foregroundColor(.green)
                        }.sheet(isPresented: $showCreator) {
                            VStack(alignment: .center) {
                                Text("Add new reminder")
                                    .font(.largeTitle)
                                TextField("Reminder content", text: self.$newContent)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .padding()
                                DatePicker("Felesleges label", selection: self.$newDate, in: Date()..., displayedComponents: .date)
                                    .labelsHidden()
                                
                                HStack(alignment: .center) {
                                    Button(action: {
                                        self.newContent = ""
                                        self.showCreator.toggle()
                                    }) {
                                        Capsule()
                                            .stroke(Color.red, lineWidth: 2)
                                            .overlay(
                                                Text("Cancel")
                                                    .fontWeight(.light)
                                                    .font(.title)
                                                    .foregroundColor(.red)
                                        )
                                            .frame(width: 120, height: 60)
                                            .opacity(0.5)
                                    }.padding()
                                    
                                    Button(action: {
                                        let rem = Reminder(context: self.managedObjectContext)
                                        rem.content = self.newContent
                                        var comps = Calendar.current.dateComponents([.year, .month, .day], from: self.newDate)
                                        comps.hour = 9
                                        comps.minute = 45
                                        rem.date = Calendar.current.date(from: comps)
                                        rem.done = false
                                        rem.identifier = UUID()
                                        
                                        self.manager.addNotification(id: rem.identifier!, title: "You have a reminder due today:", date: rem.date!, body: rem.content!)
                                        
                                        do {
                                            try self.managedObjectContext.save()
                                            self.manager.schedule()
                                        } catch {
                                            print(error)
                                        }
                                        
                                        self.newContent = ""
                                        self.showCreator.toggle()
                                    }) {
                                        Capsule()
                                            .stroke(Color.green, lineWidth: 2)
                                            .overlay(
                                                Text("Add")
                                                    .fontWeight(.light)
                                                    .font(.title)
                                                    .foregroundColor(.green)
                                        )
                                            .frame(width: 120, height: 60)
                                    }.padding()
                                }
                            }
                        }
                )
            }.navigationViewStyle(StackNavigationViewStyle())
            .tabItem {
                Image(systemName: "scribble")
                    .font(Font.title.weight(.thin))
                Text("Reminders")
            }
            
            // MARK: - Shopping list tab
            
            NavigationView {
                
                ZStack(alignment: .bottom) {
                    
                    List {
                        ForEach(self.shoppingItems) { shoppingItem in
//                            NavigationLink(destination: DetailView(selectedItem: shoppingItem)) {
                            HStack(alignment: .center) {
                                Button(action: {
                                    shoppingItem.done.toggle()
                                }) {
                                    Image(systemName: shoppingItem.done ? "checkmark.circle.fill" : "circle")
                                        .imageScale(.large)
                                        .foregroundColor(shoppingItem.done ? .green : .primary)
                                }.padding()
                                VStack(alignment: .leading) {
                                    Text("\(shoppingItem.title!)")
                                        .font(.title)
                                    Text(formatPrice(price: shoppingItem.price! as Decimal) + " Ft")
                                        .font(.footnote)
                                }
                            }
                        }.onDelete { (indexSet) in
                            let shoppingItemToDelete = self.shoppingItems[indexSet.first!]
                            self.managedObjectContext.delete(shoppingItemToDelete)
                            
                            do {
                                try self.managedObjectContext.save()
                            } catch {
                                print(error)
                            }
                        }
                    }
                    
                    Capsule()
                        .foregroundColor(Color(.systemBackground))
                        .opacity(0.95)
                        .overlay(
                            Text(sumPrice() + " Ft")
                                .font(.largeTitle)
                                .fontWeight(.thin)
                                .padding()
                    )
                        .overlay(
                            Capsule()
                                .stroke(Color.primary, lineWidth: 1)
                    )
                        .frame(width: 200, height: 60)
                        .padding()
                    
                }.navigationBarTitle("Shopping List")
                    .navigationBarItems(trailing:
                        Button(action: {
                            self.showCreator.toggle()
                        }) {
                            Image(systemName: "plus")
                                .imageScale(.large)
                                .font(Font.title.weight(.thin))
                                .foregroundColor(.green)
                        }.sheet(isPresented: $showCreator) {
                            VStack(alignment: .center) {
                                Text("Add new item")
                                    .font(.largeTitle)
                                TextField("Item name", text: self.$newTitle)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .padding()
                                TextField("Item price", text: self.$newPrice)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .keyboardType(.decimalPad)
                                    .padding()
                                    .offset(x: 0, y: -15)
                                Button(action: {
                                    let item = ShoppingItem(context: self.managedObjectContext)
                                    item.title = self.newTitle
                                    if self.newPrice == "" { item.price = 0 } else { item.price = NSDecimalNumber(string: self.newPrice) }
                                    item.done = false
                                    item.identifier = UUID()
                                    
                                    do {
                                        try self.managedObjectContext.save()
                                    } catch {
                                        print(error)
                                    }
                                    
                                    self.newTitle = ""
                                    self.newPrice = ""
                                    self.showCreator.toggle()
                                }) {
                                    Capsule()
                                        .stroke(Color.green, lineWidth: 2)
                                        .overlay(
                                            Text("Add")
                                                .fontWeight(.light)
                                                .font(.title)
                                                .foregroundColor(.green)
                                    )
                                        .frame(width: 120, height: 60)
                                }.padding()
                                
                                Button(action: {
                                    self.newTitle = ""
                                    self.newPrice = ""
                                    
                                    self.showCreator.toggle()
                                }) {
                                    Capsule()
                                        .stroke(Color.red, lineWidth: 2)
                                        .overlay(
                                            Text("Cancel")
                                                .fontWeight(.light)
                                                .font(.title)
                                                .foregroundColor(.red)
                                    )
                                        .frame(width: 120, height: 60)
                                        .opacity(0.5)
                                }
                            }
                        }
                )
            }.navigationViewStyle(StackNavigationViewStyle())
            .tabItem {
                Image(systemName: "cart")
                    .font(Font.title.weight(.thin))
                Text("Shopping List")
            }
            
            // MARK: - TTT tab
            
            NavigationView {
                
                List {
                    
                    ForEach(self.tests) { test in
                        HStack(alignment: .center) {
                            Button(action: {
                                test.done.toggle()
                            }) {
                                Image(systemName: test.done ? "checkmark.circle.fill" : "circle")
                                    .imageScale(.large)
                                    .foregroundColor(test.done ? .green : .primary)
                            }.padding()
                            VStack(alignment: .leading) {
                                HStack(alignment: .bottom) {
                                    Text("\(test.type!)")
                                        .font(.title)
                                    Text("\(test.subject!)")
                                        .font(.headline)
                                        .offset(x: 0, y: -2)
                                }
                                Text(formatDateAndTime(date: test.date!))
                                    .font(.caption)
                            }
                        }
                    }
                    .onDelete { (indexSet) in
                        let testToDelete = self.tests[indexSet.first!]
                        self.manager.removeNotification(id: testToDelete.identifier!)
                        self.managedObjectContext.delete(testToDelete)
                        
                        do {
                            try self.managedObjectContext.save()
                            self.manager.schedule()
                        } catch {
                            print(error)
                        }
                    }
                    
                }.navigationBarTitle("TTT")
                    .navigationBarItems(trailing:
                        Button(action: {
                            self.showCreator.toggle()
                            self.newDate = Date()
                        }) {
                            Image(systemName: "plus")
                                .imageScale(.large)
                                .font(Font.title.weight(.thin))
                                .foregroundColor(.green)
                        }.sheet(isPresented: $showCreator) {
                            VStack(alignment: .center) {
                                Text("Add new test")
                                    .font(.largeTitle)
                                TextField("Subject", text: self.$newTitle)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .padding()
                                TextField("Test details", text: self.$newContent)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .padding()
                                    .offset(x: 0, y: -15)
                                HStack(alignment: .center) {
                                    Button(action: {
                                        self.showDatePicker = true
                                    }) {
                                        Text(formatDate(date: self.newDate))
                                            .fontWeight(self.showDatePicker ? .semibold : .regular)
                                    }
                                    
                                    Button(action: {
                                        self.showDatePicker = false
                                    }) {
                                        Text(formatTime(date: self.newDate))
                                            .fontWeight(self.showDatePicker ? .regular : .semibold)
                                    }
                                }
                                
                                if self.showDatePicker {
                                    DatePicker("", selection: self.$newDate, in: Date()..., displayedComponents: .date)
                                        .labelsHidden()
                                } else {
                                    DatePicker("", selection: self.$newDate, in: Date()..., displayedComponents: .hourAndMinute)
                                        .labelsHidden()
                                }
                                
                                HStack(alignment: .center) {
                                    Button(action: {
                                        self.newTitle = ""
                                        self.newContent = ""
                                        
                                        self.showDatePicker = true
                                        self.showCreator.toggle()
                                    }) {
                                        Capsule()
                                            .stroke(Color.red, lineWidth: 2)
                                            .overlay(
                                                Text("Cancel")
                                                    .fontWeight(.light)
                                                    .font(.title)
                                                    .foregroundColor(.red)
                                        )
                                            .frame(width: 120, height: 60)
                                            .opacity(0.5)
                                    }.padding()
                                    
                                    Button(action: {
                                        let test = Test(context: self.managedObjectContext)
                                        test.subject = self.newTitle
                                        test.type = self.newContent
                                        test.date = self.newDate
                                        test.done = false
                                        test.identifier = UUID()
                                        
                                        self.manager.addNotification(id: test.identifier!, title: "You have a test today:", date: test.date!, body: "\(test.subject!) – \(test.type!) at " + formatTime(date: test.date!))
                                        
                                        do {
                                            try self.managedObjectContext.save()
                                            self.manager.schedule()
                                        } catch {
                                            print(error)
                                        }
                                        
                                        self.newTitle = ""
                                        self.newContent = ""
                                        self.showCreator.toggle()
                                    }) {
                                        Capsule()
                                            .stroke(Color.green, lineWidth: 2)
                                            .overlay(
                                                Text("Add")
                                                    .fontWeight(.light)
                                                    .font(.title)
                                                    .foregroundColor(.green)
                                        )
                                            .frame(width: 120, height: 60)
                                    }.padding()
                                }
                            }
                        }
                )
            }.navigationViewStyle(StackNavigationViewStyle())
            .tabItem {
                Image(systemName: "book")
                    .font(Font.title.weight(.thin))
                Text("TTT")
            }
        }
    }
    
    // MARK: - Notifications management
    
    let manager = LocalNotificationManager()
    
    // MARK: - Helper functions
    
    func sumPrice() -> String {
        var sum: Decimal = 0
        shoppingItems.filter { $0.done }.forEach { item in
            sum += item.price! as Decimal
        }
        return formatPrice(price: sum)
    }
    
    // MARK: - Detail View
    
//    struct DetailView: View {
//        let selectedItem: ShoppingItem
//
//        var body: some View {
//            VStack(alignment: .center) {
//                Text("\(selectedItem.title!)")
//                    .font(.largeTitle)
//                Text(formatPrice(price: selectedItem.price! as Decimal) + " Ft")
//                    .font(.title)
//            }.padding()
//        }
//    }
    
}

// MARK: - Preview provision

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
