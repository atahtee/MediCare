import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    if let path = Bundle.main.path(forResource: "local", ofType: "properties") {
        if let properties = NSDictionary(contentsOfFile: path) {
            if let apiKey = properties["GOOGLE_MAPS_API_KEY"] as? String {
                GMSServices.provideAPIKey(apiKey)
            } else {
                print("Error: API key not found in local.properties")
            }
        } else {
            print("Error: Unable to load local.properties")
        }
    } else {
        print("Error: local.properties file not found")
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
