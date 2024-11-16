import Flutter
import UIKit
import UserNotifications // Import UserNotifications for local notifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    // Registering the plugin
    GeneratedPluginRegistrant.register(with: self)
    
    // Request permission for local notifications
    requestNotificationPermission(application: application)
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // Function to request permission for notifications
  func requestNotificationPermission(application: UIApplication) {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
      if granted {
        // Permission granted, you can proceed with notifications
        print("Notification permission granted.")
      } else {
        // Handle permission denial
        print("Notification permission denied.")
      }
      
      // Set up the notification settings (optional)
      application.registerForRemoteNotifications()
    }
  }
}
