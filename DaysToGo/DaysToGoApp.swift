//
//  DaysToGoApp.swift
//  DaysToGo
//
//  Created by Jon Wright on 21/07/2025.
//

import SwiftUI
import UserNotifications
import CloudKit
import WidgetKit
import DaysToGoKit

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Handle successful registration if needed
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        AppLogger.general.error("Failed to register for remote notifications: \(error.localizedDescription)")
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        NotificationCenter.default.post(name: .cloudKitNotification, object: nil, userInfo: userInfo)
        completionHandler()
    }
}

@main
struct DaysToGoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var calendarPrefs = CalendarPreferences()
    @StateObject var reminderStore = ReminderStore()
    @StateObject var profileStore = UserProfileStore.shared
    @State private var showSplash = true
    @State private var showOnboarding = false

    var body: some Scene {
        WindowGroup {
            ZStack {
                if showSplash {
                    SplashScreenView()
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + AnimationTiming.splashDuration) {
                                withAnimation {
                                    showSplash = false
                                }
                                // Check if onboarding is needed after splash
                                showOnboarding = !profileStore.hasCompletedOnboarding
                            }
                        }
                } else {
                    ReminderListView(reminderStore: reminderStore)
                        .environmentObject(calendarPrefs)
                        .environmentObject(profileStore)
                        .onAppear(perform: requestNotificationPermission)
                        .onReceive(NotificationCenter.default.publisher(for: .remindersDidChange)) { _ in
                            WidgetCenter.shared.reloadTimelines(ofKind: AppConstants.widgetKind)
                        }
                        .fullScreenCover(isPresented: $showOnboarding) {
                            OnboardingView(profileStore: profileStore) {
                                showOnboarding = false
                            }
                        }
                }
            }
        }
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
}
