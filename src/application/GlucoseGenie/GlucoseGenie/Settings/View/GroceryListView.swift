//
//  GroceryListView.swift
//  GlucoseGenie
//
//  Created by Hristova,Krisi on 3/3/25.
//

import SwiftUI

class GroceryList: ObservableObject {
    @Published var items: [GroceryItem] = [] {
        didSet {
            saveItems()
        }
    }

    private let storageKey = "groceryListData"

    init() {
        loadItems()
    }

    private func saveItems() {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(items) {
            UserDefaults.standard.set(data, forKey: storageKey)
            // print("Grocery list saved")
        }
    }

    private func loadItems() {
        let decoder = JSONDecoder()
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? decoder.decode([GroceryItem].self, from: data) {
            self.items = decoded
            // print("Grocery list loaded")
        }
    }
    
    func addItem(_ item: GroceryItem) {
        items.append(item)
        objectWillChange.send()
    }
    
    func removeItem(_ item: GroceryItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items.remove(at: index)
            objectWillChange.send()
        }
    }
    
    func syncList(with mealPlan: MealPlan) {
        DispatchQueue.main.async {
            self.items = parseMealPlan(from: mealPlan.mealsByDay)
        }
    }
    
    func replaceAll(with newItems: [GroceryItem]) {
        items = newItems
    }
}

struct GroceryItem: Identifiable, Codable {
    let id = UUID()
    let item: String
    var isChecked: Bool = false
}

func parseMealPlan(from mealsByDay: [Date: [String: Recipe]]) -> [GroceryItem] {
    mealsByDay.values
        .flatMap { $0.values } // Flatten to [String: Recipe]
        .flatMap { $0.ingredients } // Flatten to Ingredient
        .map { GroceryItem(item: $0.text) } // Extract ingredient text
}

struct GroceryListView: View {
    @EnvironmentObject var mealPlan: MealPlan
    @StateObject private var groceryList = GroceryList()
    @State private var syncConfirmation = false
    @State private var shouldSyncList = false
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Based on your weekly meal plan, you will need:")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)

                ScrollView {
                    VStack(spacing: 12) {
                        ForEach($groceryList.items) { $item in
                            HStack {
                                Button(action: {
                                    item.isChecked.toggle()
                                }) {
                                    Image(systemName: item.isChecked ? "checkmark.square.fill" : "square")
                                        .foregroundColor(item.isChecked ? .green : .gray)
                                        .font(.title3)
                                }
                                
                                Text(item.item)
                                    .font(.body)
                                    .fontWeight(.medium)
                                    .strikethrough(item.isChecked, color: .gray)
                                    .foregroundColor(item.isChecked ? .gray : .primary)

                                Spacer()
                                
                                Button(action: {
                                    groceryList.removeItem(item)
                                }) {
                                    Image(systemName: "xmark.circle")
                                        .foregroundColor(.red)
                                        .font(.title3)
                                }
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(10)
                            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Grocery List")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        syncConfirmation = true
                    }) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                    }
                    .accessibilityLabel("Sync with Meal Plan")
                }
            }
            .alert("Sync Grocery List?", isPresented: $syncConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Sync") {
                    shouldSyncList = true
                }
            } message: {
                Text("This will sync your grocery list with your current meal plan. Any changes will be lost.")
            }
            .onChange(of: shouldSyncList) {
                if shouldSyncList {
                    groceryList.syncList(with: mealPlan)
                    shouldSyncList = false
                }
            }
        }
//        .onAppear {
//            DispatchQueue.main.async {
//                let ingredients = parseMealPlan(from: mealPlan.mealsByDay)
//            }
//        }
    }
}

#Preview {
    GroceryListView()
}
