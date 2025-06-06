//
//  SettingsUIView.swift
//  GlucoseGenie
//
//  Created by Ford,Carson on 2/17/25.
//

import SwiftUI

struct SettingsUIView: View {
    @State private var viewModel = SettingsUIViewModel()
    @EnvironmentObject private var authenticationService: AuthenticationService
    
    var body: some View {
        
        NavigationView {
            ZStack {
                Color.eggWhite.ignoresSafeArea()
                Form {
                    // FIXME - Notifications are not implemented.
                    /*Section {
                        Toggle(isOn: $viewModel.isNotificationsEnabled) {
                            Label("Notifications", systemImage: "bell")
                        }
                    }*/
                    
                    Section {
                        Button(action: handleLogOut) {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .foregroundColor(.red)
                                Text("Log Out")
                                    .foregroundColor(.red)
                            }
                            
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .background(Color.eggWhite)
            }
            .navigationTitle("Settings")
        }
        
    }
    
    private func handleLogOut() {
        Task {
            await authenticationService.signOut()
        }
    }
    
}

struct SettingsUIView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsUIView().environmentObject(AuthenticationService())
    }
}
