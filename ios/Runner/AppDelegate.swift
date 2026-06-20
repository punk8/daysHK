import Flutter
import CoreLocation
import UIKit
import WidgetKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    DaysHKGeofenceChannel.shared.configure(messenger: engineBridge.applicationRegistrar.messenger())
    DaysHKWidgetChannel.shared.configure(messenger: engineBridge.applicationRegistrar.messenger())
  }
}

final class DaysHKWidgetChannel {
  static let shared = DaysHKWidgetChannel()

  private let channelName = "days_in_hk/widget"
  private let appGroupIdentifier = "group.com.punk8.daysHK"
  private let totalDaysKey = "days_hk_total_days"
  private let currentYearDaysKey = "days_hk_current_year_days"
  private let currentYearKey = "days_hk_current_year"
  private let lastUpdatedAtKey = "days_hk_last_updated_at"

  private init() {}

  func configure(messenger: FlutterBinaryMessenger) {
    NSLog("DaysHK widget channel registered")
    let channel = FlutterMethodChannel(name: channelName, binaryMessenger: messenger)
    channel.setMethodCallHandler { [weak self] call, result in
      guard let self else { return }
      switch call.method {
      case "updateWidgetSummary":
        self.updateWidgetSummary(arguments: call.arguments, result: result)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private func updateWidgetSummary(arguments: Any?, result: FlutterResult) {
    guard let defaults = UserDefaults(suiteName: appGroupIdentifier) else {
      result(FlutterError(
        code: "app_group_unavailable",
        message: "App Group UserDefaults 不可用。",
        details: appGroupIdentifier
      ))
      return
    }

    guard let payload = arguments as? [String: Any] else {
      result(FlutterError(
        code: "invalid_payload",
        message: "Widget 摘要参数格式不正确。",
        details: nil
      ))
      return
    }

    defaults.set(intValue(payload["totalDays"]), forKey: totalDaysKey)
    defaults.set(intValue(payload["currentYearDays"]), forKey: currentYearDaysKey)
    defaults.set(intValue(payload["currentYear"]), forKey: currentYearKey)
    if let lastUpdatedAt = payload["lastUpdatedAt"] as? String {
      defaults.set(lastUpdatedAt, forKey: lastUpdatedAtKey)
    }
    defaults.synchronize()

    if #available(iOS 14.0, *) {
      WidgetCenter.shared.reloadAllTimelines()
    }
    result(nil)
  }

  private func intValue(_ value: Any?) -> Int {
    if let value = value as? Int {
      return value
    }
    if let value = value as? NSNumber {
      return value.intValue
    }
    return 0
  }
}

final class DaysHKGeofenceChannel: NSObject, CLLocationManagerDelegate {
  static let shared = DaysHKGeofenceChannel()

  private let geofenceChannelName = "days_in_hk/geofence"
  private let geofenceIdentifier = "hk_boundary_wakeup"
  private let locationManager = CLLocationManager()
  private let defaults = UserDefaults.standard
  private let monitoringStartedKey = "days_in_hk.geofence.monitoringStarted"
  private let lastTransitionKey = "days_in_hk.geofence.lastTransition"
  private let lastDetectedAtKey = "days_in_hk.geofence.lastDetectedAt"
  private let lastLatitudeKey = "days_in_hk.geofence.lastLatitude"
  private let lastLongitudeKey = "days_in_hk.geofence.lastLongitude"

  private override init() {
    super.init()
    locationManager.delegate = self
  }

  func configure(messenger: FlutterBinaryMessenger) {
    NSLog("DaysHK geofence channel registered")
    let channel = FlutterMethodChannel(name: geofenceChannelName, binaryMessenger: messenger)
    channel.setMethodCallHandler { [weak self] call, result in
      guard let self else { return }
      switch call.method {
      case "getStatus":
        result(self.statusPayload())
      case "requestAlwaysAuthorization":
        self.requestAlwaysAuthorization(result)
      case "startMonitoring":
        self.startMonitoring(result)
      case "stopMonitoring":
        self.stopMonitoring(result)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private func requestAlwaysAuthorization(_ result: FlutterResult) {
    if !CLLocationManager.locationServicesEnabled() {
      result(statusPayload(status: "unavailable", message: "iOS 定位服务未开启。"))
      return
    }

    let authorization = currentAuthorizationStatus()
    NSLog("DaysHK geofence requestAlwaysAuthorization authorization=%d", authorization.rawValue)
    if authorization == .authorizedAlways {
      result(statusPayload(status: "ready", message: "已获得“始终允许”定位权限，可启动后台检测。"))
      return
    }

    if authorization == .denied || authorization == .restricted {
      result(statusPayload(status: "unavailable", message: "定位权限已被拒绝，请到系统设置中为在港日记开启“始终允许”。"))
      return
    }

    locationManager.requestAlwaysAuthorization()
    result(statusPayload(status: "unavailable", message: "已请求“始终允许”定位权限，请在系统弹窗中允许后再次启动后台检测。"))
  }

  private func startMonitoring(_ result: FlutterResult) {
    if !CLLocationManager.locationServicesEnabled() {
      result(statusPayload(status: "unavailable", message: "iOS 定位服务未开启。"))
      return
    }

    guard CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) else {
      result(statusPayload(status: "unavailable", message: "当前设备不支持 iOS region monitoring。"))
      return
    }

    let authorization = currentAuthorizationStatus()
    NSLog(
      "DaysHK geofence startMonitoring authorization=%d maxDistance=%f",
      authorization.rawValue,
      locationManager.maximumRegionMonitoringDistance
    )
    if authorization == .notDetermined {
      locationManager.requestAlwaysAuthorization()
      result(statusPayload(status: "unavailable", message: "请先在系统弹窗中允许“始终”定位权限，然后再次启动后台检测。"))
      return
    } else if authorization != .authorizedAlways {
      result(statusPayload(status: "unavailable", message: "需要“始终允许”定位权限后才能启动 iOS 后台检测。"))
      return
    }

    removeExistingRegion()

    let region = CLCircularRegion(
      center: CLLocationCoordinate2D(latitude: 22.3193, longitude: 114.1694),
      radius: min(50000, locationManager.maximumRegionMonitoringDistance),
      identifier: geofenceIdentifier
    )
    region.notifyOnEntry = true
    region.notifyOnExit = true

    locationManager.allowsBackgroundLocationUpdates = true
    locationManager.pausesLocationUpdatesAutomatically = false
    locationManager.startMonitoring(for: region)
    defaults.set(true, forKey: monitoringStartedKey)
    NSLog("DaysHK geofence startMonitoring requested radius=%f", region.radius)

    result(statusPayload(status: "running", message: "iOS region monitoring 已启动，等待系统 enter / exit 事件。"))
  }

  private func stopMonitoring(_ result: FlutterResult) {
    removeExistingRegion()
    defaults.set(false, forKey: monitoringStartedKey)
    result(statusPayload(status: "stopped", message: ""))
  }

  private func statusPayload(status forcedStatus: String? = nil, message forcedMessage: String? = nil) -> [String: Any?] {
    if !CLLocationManager.locationServicesEnabled() {
      return withLastEvent([
        "status": "unavailable",
        "message": "iOS 定位服务未开启。"
      ])
    }

    let authorization = currentAuthorizationStatus()
    if authorization == .denied || authorization == .restricted {
      return withLastEvent([
        "status": "unavailable",
        "message": "iOS 定位权限未开启。"
      ])
    }

    if let forcedStatus, let forcedMessage {
      return withLastEvent([
        "status": forcedStatus,
        "message": forcedMessage
      ])
    }

    if defaults.bool(forKey: monitoringStartedKey) {
      return withLastEvent([
        "status": "running",
        "message": "iOS region monitoring 运行中，最近事件会在系统触发后显示。"
      ])
    }

    return withLastEvent([
      "status": "ready",
      "message": "iOS 后台检测通道已注册，可启动 region monitoring。"
    ])
  }

  private func removeExistingRegion() {
    for region in locationManager.monitoredRegions where region.identifier == geofenceIdentifier {
      locationManager.stopMonitoring(for: region)
    }
  }

  private func withLastEvent(_ payload: [String: Any?]) -> [String: Any?] {
    var next = payload
    next["lastEvent"] = lastEventPayload()
    return next
  }

  private func lastEventPayload() -> [String: Any?]? {
    guard
      let transition = defaults.string(forKey: lastTransitionKey),
      let detectedAt = defaults.string(forKey: lastDetectedAtKey)
    else {
      return nil
    }

    var event: [String: Any?] = [
      "transition": transition,
      "detectedAt": detectedAt,
      "source": "ios_region_monitoring"
    ]
    if defaults.object(forKey: lastLatitudeKey) != nil {
      event["latitude"] = defaults.double(forKey: lastLatitudeKey)
    }
    if defaults.object(forKey: lastLongitudeKey) != nil {
      event["longitude"] = defaults.double(forKey: lastLongitudeKey)
    }
    return event
  }

  private func saveLastEvent(transition: String, location: CLLocation?) {
    defaults.set(transition, forKey: lastTransitionKey)
    defaults.set(isoNow(), forKey: lastDetectedAtKey)
    if let location {
      defaults.set(location.coordinate.latitude, forKey: lastLatitudeKey)
      defaults.set(location.coordinate.longitude, forKey: lastLongitudeKey)
    }
  }

  private func isoNow() -> String {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    return formatter.string(from: Date())
  }

  func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
    guard region.identifier == geofenceIdentifier else { return }
    NSLog("DaysHK geofence didEnterRegion %@", region.identifier)
    saveLastEvent(transition: "enter", location: manager.location)
  }

  func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
    guard region.identifier == geofenceIdentifier else { return }
    NSLog("DaysHK geofence didExitRegion %@", region.identifier)
    saveLastEvent(transition: "exit", location: manager.location)
  }

  func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
    guard region?.identifier == geofenceIdentifier else { return }
    NSLog(
      "DaysHK geofence monitoringDidFailFor %@: %@",
      region?.identifier ?? "unknown",
      error.localizedDescription
    )
    defaults.set(false, forKey: monitoringStartedKey)
  }

  private func currentAuthorizationStatus() -> CLAuthorizationStatus {
    if #available(iOS 14.0, *) {
      return locationManager.authorizationStatus
    }
    return CLLocationManager.authorizationStatus()
  }

  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    if defaults.bool(forKey: monitoringStartedKey), currentAuthorizationStatus() == .authorizedAlways {
      removeExistingRegion()
      let region = CLCircularRegion(
        center: CLLocationCoordinate2D(latitude: 22.3193, longitude: 114.1694),
        radius: min(50000, manager.maximumRegionMonitoringDistance),
        identifier: geofenceIdentifier
      )
      region.notifyOnEntry = true
      region.notifyOnExit = true
      manager.startMonitoring(for: region)
    }
  }
}
