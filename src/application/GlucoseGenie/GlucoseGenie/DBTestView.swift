//
//  DBTestView.swift
//  GlucoseGenie
//
//  Created by Jared Jackson on 3/2/25.
//

import SwiftUI
import Amplify

struct DBTestView: View {
    @State private var message: String = "Tap the button to add dummy data"

    var body: some View {
            VStack(spacing: 20) {
                Text(message)
                    .padding()
                    .multilineTextAlignment(.center)

                Button {
                    Task {
                        await addDummyData()
                    }
                } label: {
                    Text("Add Dummy Data")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
        }

    func addDummyData() async {
        let blog = Blog(name: "My Test Blog")
        
        do{
            let result = try await Amplify.API.mutate(request: .create(blog))
            switch result {
                case .success(let blog):
                    print("Successfully created blog: \(blog)")
                case .failure(let error):
                    print("Got failed result with \(error.errorDescription)")
            }
        } catch let error as APIError {
            print("Failed to create blog: ", error)
        } catch {
            print("Unexpected error: \(error)")
        }
    }
}
