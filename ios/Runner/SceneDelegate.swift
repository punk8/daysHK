import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {
  override func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    super.scene(scene, willConnectTo: session, options: connectionOptions)
    guard let flutterViewController = window?.rootViewController as? FlutterViewController else {
      NSLog("DaysHK geofence channel registration skipped: missing FlutterViewController")
      return
    }
    DaysHKGeofenceChannel.shared.configure(messenger: flutterViewController.binaryMessenger)
  }
}
