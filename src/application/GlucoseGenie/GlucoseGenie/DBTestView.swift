//
//  DBTestView.swift
//  GlucoseGenie
//
//  Created by Jared Jackson on 3/2/25.
//

import SwiftUI
import Amplify

struct DBTestView: View {
    @State private var message: String = "Tap the button to add dummy todo"
    @State private var todos: [Todo] = []

    var body: some View {
        VStack(spacing: 20) {
            Text(message)
                .padding()
                .multilineTextAlignment(.center)

            Button {
                Task {
                    await createTodo()
                    await fetchTodos() // Fetch todos after creating one
                }
            } label: {
                Text("Add Dummy Data")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }

            List(todos, id: \.id) { todo in
                VStack(alignment: .leading) {
                    Text(todo.title) // Display title of todo
                        .font(.headline)
                    Text(todo.description ?? "No description") // Display description
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .task {
            await fetchTodos() // Fetch todos on view load
        }
    }
        

    func createTodo() async {
        do{
            let attributes = try await Amplify.Auth.fetchUserAttributes()
            let email = attributes.first(where: { $0.key == .email })?.value ?? "Unknown Email"
            let data = Todo(title: "A Test Create", description: email)
            
            let result = try await Amplify.API.mutate(request: .create(data))
            switch result {
                case .success(let data):
                    print("✅ Successfully created blog: \(data)")
                case .failure(let error):
                    print("Got failed result with \(error.errorDescription)")
            }
        } catch let error as APIError {
            print("❌ Failed to create blog: ", error)
        } catch {
            print("❌ Unexpected error: \(error)")
        }
    }
    
    func fetchTodos() async {
        do {
            let result = try await Amplify.API.query(request: .list(Todo.self))
            switch result {
            case .success(let fetchedTodos):
                DispatchQueue.main.async {
                    self.todos = Array(fetchedTodos)
                    self.message = "Fetched \(fetchedTodos.count) todos"
                }
            case .failure(let error):
                print("❌ Failed to fetch todos: \(error.errorDescription)")
            }
        } catch {
            print("❌ Unexpected error: \(error)")
        }
    }
}
