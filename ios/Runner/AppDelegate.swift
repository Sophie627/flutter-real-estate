import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
    }
      GMSServices.provideAPIKey("AIzaSyAseYt_NDZtWHrdPsz6UZqJZAFbAi_rHic")
  GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
