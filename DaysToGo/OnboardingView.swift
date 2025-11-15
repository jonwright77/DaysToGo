//
//  OnboardingView.swift
//  DaysToGo
//
//  Created by Claude on 09/11/2025.
//

import SwiftUI
import DaysToGoKit

struct OnboardingView: View {
    @ObservedObject var profileStore: UserProfileStore
    @State private var name: String = ""
    @State private var location: String = ""
    @State private var currentPage = 0

    var onComplete: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Page indicator
            HStack(spacing: 8) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(index == currentPage ? Color.accentColor : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.top, 40)

            TabView(selection: $currentPage) {
                // Welcome Page
                welcomePage
                    .tag(0)

                // Name Page
                namePage
                    .tag(1)

                // Location Page
                locationPage
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: currentPage)
        }
        .background(Color(.systemGroupedBackground))
    }

    // MARK: - Welcome Page

    private var welcomePage: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 80))
                .foregroundColor(.accentColor)

            Text("Welcome to DaysToGo")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            Text("Count down to your important dates and reflect on moments from the past")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Spacer()

            Button(action: {
                withAnimation {
                    currentPage = 1
                }
            }) {
                Text("Get Started")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
    }

    // MARK: - Name Page

    private var namePage: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "person.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.accentColor)

            Text("What's your name?")
                .font(.title)
                .fontWeight(.bold)

            Text("We'll use this to personalize your experience")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            TextField("Enter your name", text: $name)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal, 40)
                .autocapitalization(.words)
                .textContentType(.name)

            Spacer()

            HStack(spacing: 16) {
                Button(action: {
                    withAnimation {
                        currentPage = 0
                    }
                }) {
                    Text("Back")
                        .font(.headline)
                        .foregroundColor(.accentColor)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray5))
                        .cornerRadius(12)
                }

                Button(action: {
                    withAnimation {
                        currentPage = 2
                    }
                }) {
                    Text("Next")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(name.isEmpty ? Color.gray : Color.accentColor)
                        .cornerRadius(12)
                }
                .disabled(name.isEmpty)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
    }

    // MARK: - Location Page

    private var locationPage: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "mappin.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.accentColor)

            Text("Where are you from?")
                .font(.title)
                .fontWeight(.bold)

            Text("Optional: Add your location to personalize reminders")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            TextField("Enter your location", text: $location)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal, 40)
                .autocapitalization(.words)
                .textContentType(.addressCity)

            Spacer()

            HStack(spacing: 16) {
                Button(action: {
                    withAnimation {
                        currentPage = 1
                    }
                }) {
                    Text("Back")
                        .font(.headline)
                        .foregroundColor(.accentColor)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray5))
                        .cornerRadius(12)
                }

                Button(action: {
                    completeOnboarding()
                }) {
                    Text("Complete")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
    }

    // MARK: - Actions

    private func completeOnboarding() {
        profileStore.updateProfile(name: name, location: location)
        profileStore.completeOnboarding()
        onComplete()
    }
}
