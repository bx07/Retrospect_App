import UIKit
import Flutter
import Purchases

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    Purchases.debugLogsEnabled = true
      Purchases.configure(withAPIKey: "appl_pzRjjQWXGnjwWgIEvgOnXsYcvAF")
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

if #available(iOS 10.0, *) {
  UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
}
