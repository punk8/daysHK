enum AppLocationPermissionStatus {
  ready('定位记录已准备就绪'),
  serviceDisabled('定位服务未开启'),
  denied('定位权限未开启'),
  deniedForever('定位权限被永久拒绝'),
  whileInUseOnly('仅使用期间允许，后台自动记录可能受影响'),
  unknown('定位状态未知');

  const AppLocationPermissionStatus(this.message);

  final String message;
}
