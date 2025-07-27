// StartView.swift
import SwiftUI

struct StartView: View {
    @State private var showContentView: Bool = false

    var body: some View {
        // NOTE: Using NavigationView instead of NavigationStack for broader compatibility (e.g., iOS 15 and earlier)
        NavigationView {
            VStack(spacing: 30) {
                Spacer()

                Text("Welcome to the Treadmill Monitor")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding()

                Text("Ready to start your workout?")
                    .font(.title2)
                    .foregroundColor(.gray)

                Spacer()

                Button(action: {
                    showContentView = true
                }) {
                    Text("Start Workout")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                }
                .padding(.horizontal, 40)
                
                // NOTE: Using an invisible NavigationLink or sheets with NavigationView
                // For push navigation, we can use a NavigationLink
                NavigationLink(destination: ContentView(), isActive: $showContentView) {
                    EmptyView() // Hides the visible link, as the button already triggers it
                }
                .hidden() // Ensures the NavigationLink is not visible
                
                Spacer()
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct StartView_Previews: PreviewProvider {
    static var previews: some View {
        StartView()
    }
}