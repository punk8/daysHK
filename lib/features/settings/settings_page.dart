import 'package:flutter/cupertino.dart';

import '../../core/time/hk_date.dart';
import '../../domain/models/stay_record.dart';
import '../../location/geofence/location_detection_service.dart';
import '../../location/geofence/native_geofence_bridge.dart';
import '../../location/permissions/location_permission_service.dart';
import '../../location/permissions/location_permission_status.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_notice.dart';
import '../../shared/widgets/cupertino_controls.dart';
import '../../shared/widgets/page_scaffold.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({
    super.key,
    required this.records,
    required this.locationDetection,
    required this.locationPermission,
    required this.nativeGeofence,
    required this.onSaveCandidate,
    required this.onClearAll,
    required this.onShowRecords,
  });

  final List<StayRecord> records;
  final LocationDetectionService locationDetection;
  final LocationPermissionService locationPermission;
  final NativeGeofenceBridge nativeGeofence;
  final Future<void> Function(StayRecord record) onSaveCandidate;
  final Future<void> Function() onClearAll;
  final VoidCallback onShowRecords;

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: '设置与隐私',
      children: [
        AppCard(
          child: _LocationDetectionCard(
            records: records,
            locationDetection: locationDetection,
            locationPermission: locationPermission,
            onSaveCandidate: onSaveCandidate,
            onShowRecords: onShowRecords,
          ),
        ),
        const SizedBox(height: 12),
        AppCard(
          child: _NativeGeofenceCard(
            records: records,
            nativeGeofence: nativeGeofence,
            onSaveCandidate: onSaveCandidate,
          ),
        ),
        const SizedBox(height: 12),
        AppCard(
          child: const _SettingsTile(
            icon: CupertinoIcons.archivebox,
            title: '数据存储',
            subtitle: '所有数据仅保存在本地设备中，不会上传或分享你的数据。',
          ),
        ),
        const SizedBox(height: 12),
        AppCard(
          child: Column(
            children: [
              _SettingsTile(
                icon: CupertinoIcons.delete,
                iconColor: AppColors.red,
                title: '清除所有数据',
                titleColor: AppColors.red,
                subtitle: '删除本地所有记录，无法恢复',
                onTap: () async {
                  final confirmed = await showAppConfirmationDialog(
                    context: context,
                    title: '清除所有数据',
                    message: '将删除本地所有入离港记录，无法恢复。是否继续？',
                    confirmLabel: '清除',
                    destructive: true,
                  );
                  if (confirmed) {
                    await onClearAll();
                    if (context.mounted) {
                      AppNotice.show(context, '本地数据已清除');
                    }
                  }
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        AppCard(
          child: Column(
            children: const [
              _SettingsTile(
                icon: CupertinoIcons.hand_raised,
                title: '隐私说明',
                subtitle: '本应用用于个人记录参考，不构成永居资格判断。',
              ),
              _SettingsDivider(),
              _SettingsTile(
                icon: CupertinoIcons.doc_text,
                title: '使用条款',
                subtitle: '统计结果基于你的记录估算，可能存在误差。',
              ),
              _SettingsDivider(),
              _SettingsTile(
                icon: CupertinoIcons.info_circle,
                title: '关于在港日记',
                subtitle: '版本 1.0.0',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NativeGeofenceCard extends StatefulWidget {
  const _NativeGeofenceCard({
    required this.records,
    required this.nativeGeofence,
    required this.onSaveCandidate,
  });

  final List<StayRecord> records;
  final NativeGeofenceBridge nativeGeofence;
  final Future<void> Function(StayRecord record) onSaveCandidate;

  @override
  State<_NativeGeofenceCard> createState() => _NativeGeofenceCardState();
}

class _NativeGeofenceCardState extends State<_NativeGeofenceCard> {
  NativeGeofenceState _state = const NativeGeofenceState(
    status: NativeGeofenceStatus.unavailable,
    message: '正在读取后台检测状态...',
  );
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final isRunning = _state.status == NativeGeofenceStatus.running;
    final statusLabel = switch (_state.status) {
      NativeGeofenceStatus.ready => '已准备',
      NativeGeofenceStatus.running => '运行中',
      NativeGeofenceStatus.stopped => '已停止',
      NativeGeofenceStatus.unsupported => '不支持',
      NativeGeofenceStatus.unavailable => '不可用',
    };
    final statusMessage = isRunning ? null : _state.message;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SettingsStatusRow(
          icon: CupertinoIcons.location_circle,
          title: '后台自动检测',
          subtitle: statusMessage,
          trailing: statusLabel,
          trailingColor: AppColors.teal,
        ),
        if (_state.lastEvent != null) ...[
          const SizedBox(height: 4),
          _NativeEventSummary(
            event: _state.lastEvent!,
            onCreateCandidate: _isBusy
                ? null
                : () => _createCandidateFromNativeEvent(_state.lastEvent!),
          ),
        ],
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            AppCupertinoButton(
              label: '刷新状态',
              icon: CupertinoIcons.refresh,
              filled: false,
              onPressed: _isBusy ? null : _refresh,
            ),
            if (!isRunning)
              AppCupertinoButton(
                label: '启动检测',
                icon: CupertinoIcons.play_arrow_solid,
                onPressed: _isBusy ? null : _start,
              ),
            if (isRunning)
              AppCupertinoButton(
                label: '停止',
                icon: CupertinoIcons.stop_fill,
                filled: false,
                onPressed: _isBusy ? null : _stop,
              ),
          ],
        ),
      ],
    );
  }

  Future<void> _refresh() async {
    await _run(widget.nativeGeofence.getStatus);
  }

  Future<void> _start() async {
    final confirmed = await showAppConfirmationDialog(
      context: context,
      title: '开启后台自动检测',
      message: '后台自动检测需要“始终允许”定位权限。系统可能会先询问定位授权；授权后请再次点击启动检测完成开启。',
      confirmLabel: '继续',
    );
    if (!confirmed) {
      return;
    }

    await _run(() async {
      final authorizationState =
          await widget.nativeGeofence.requestAlwaysAuthorization();
      if (authorizationState.status != NativeGeofenceStatus.ready) {
        return authorizationState;
      }
      return widget.nativeGeofence.startMonitoring();
    });
  }

  Future<void> _stop() async {
    await _run(widget.nativeGeofence.stopMonitoring);
  }

  Future<void> _run(Future<NativeGeofenceState> Function() action) async {
    setState(() => _isBusy = true);
    try {
      final state = await action().timeout(const Duration(seconds: 8));
      if (!mounted) {
        return;
      }
      setState(() {
        _state = state;
        _isBusy = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _state = const NativeGeofenceState(
          status: NativeGeofenceStatus.unavailable,
          message: '后台检测请求超时，请确认定位权限后重试。',
        );
        _isBusy = false;
      });
    }
  }

  Future<void> _createCandidateFromNativeEvent(
    NativeGeofenceEvent event,
  ) async {
    final now = event.detectedAt.millisecondsSinceEpoch == 0
        ? DateTime.now()
        : event.detectedAt.toLocal();
    final today = DateTime(now.year, now.month, now.day);
    final latest = [...widget.records]
      ..sort((a, b) => b.entryDate.compareTo(a.entryDate));
    final current = latest.isEmpty ? null : latest.first;

    StayRecord? candidate;
    if (event.transition == NativeGeofenceTransition.enter) {
      candidate = StayRecord(
        id: 'native-candidate-${now.microsecondsSinceEpoch}',
        entryDate: today,
        exitDate: null,
        sameDayRoundTrip: false,
        locationName: '原生后台检测',
        note: '原生后台检测：可能进入香港附近唤醒区，需要确认',
        source: RecordSource.autoDetected,
        confirmationStatus: ConfirmationStatus.needsConfirmation,
        createdAt: now,
        updatedAt: now,
      );
    } else if (event.transition == NativeGeofenceTransition.exit &&
        current != null &&
        current.exitDate == null &&
        current.confirmationStatus != ConfirmationStatus.rejected) {
      final note = [
        if (current.note != null && current.note!.trim().isNotEmpty)
          current.note!,
        '原生后台检测：可能离开香港附近唤醒区，需要确认',
      ].join('\n');
      candidate = current.copyWith(
        exitDate: today,
        sameDayRoundTrip: dateKey(current.entryDate) == dateKey(today),
        locationName: current.locationName ?? '原生后台检测',
        note: note,
        source: RecordSource.autoDetected,
        confirmationStatus: ConfirmationStatus.needsConfirmation,
        updatedAt: now,
      );
    } else {
      candidate = StayRecord(
        id: 'native-candidate-${now.microsecondsSinceEpoch}',
        entryDate: today,
        exitDate: today,
        sameDayRoundTrip: true,
        locationName: '原生后台检测',
        note: '原生后台检测事件无法直接判断入离港状态，需要手动修正',
        source: RecordSource.autoDetected,
        confirmationStatus: ConfirmationStatus.needsConfirmation,
        createdAt: now,
        updatedAt: now,
      );
    }

    await widget.onSaveCandidate(candidate);
    if (!mounted) {
      return;
    }
    AppNotice.show(context, '已根据最近原生事件生成需要确认的候选记录');
  }
}

class _NativeEventSummary extends StatelessWidget {
  const _NativeEventSummary({
    required this.event,
    required this.onCreateCandidate,
  });

  final NativeGeofenceEvent event;
  final VoidCallback? onCreateCandidate;

  @override
  Widget build(BuildContext context) {
    final detectedAt = event.detectedAt;
    final dateText = detectedAt.millisecondsSinceEpoch == 0
        ? '时间未知'
        : '${detectedAt.year.toString().padLeft(4, '0')}-'
              '${detectedAt.month.toString().padLeft(2, '0')}-'
              '${detectedAt.day.toString().padLeft(2, '0')} '
              '${detectedAt.hour.toString().padLeft(2, '0')}:'
              '${detectedAt.minute.toString().padLeft(2, '0')}';
    final coordinateText = event.latitude == null || event.longitude == null
        ? null
        : '${event.latitude!.toStringAsFixed(4)}, '
              '${event.longitude!.toStringAsFixed(4)}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.appColor(AppColors.teal).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: context.appColor(AppColors.teal).withValues(alpha: 0.22),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '最近原生事件：${event.transition.label}',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text('检测时间：$dateText'),
          if (coordinateText != null) Text('坐标：$coordinateText'),
          Text('来源：${event.source}'),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: AppCupertinoButton(
              label: '生成候选记录',
              icon: CupertinoIcons.location_solid,
              filled: false,
              onPressed: onCreateCandidate,
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationDetectionCard extends StatefulWidget {
  const _LocationDetectionCard({
    required this.records,
    required this.locationDetection,
    required this.locationPermission,
    required this.onSaveCandidate,
    required this.onShowRecords,
  });

  final List<StayRecord> records;
  final LocationDetectionService locationDetection;
  final LocationPermissionService locationPermission;
  final Future<void> Function(StayRecord record) onSaveCandidate;
  final VoidCallback onShowRecords;

  @override
  State<_LocationDetectionCard> createState() => _LocationDetectionCardState();
}

class _LocationDetectionCardState extends State<_LocationDetectionCard> {
  String _status = '建议开启“始终允许”，以获得更准确的出入境记录。';
  AppLocationPermissionStatus _permissionStatus =
      AppLocationPermissionStatus.unknown;
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SettingsStatusRow(
          icon: CupertinoIcons.location,
          title: '定位权限状态',
          subtitle: _status,
          trailing: _permissionLabel,
          trailingColor: _permissionColor,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            AppCupertinoButton(
              label: '检查权限',
              icon: CupertinoIcons.checkmark_shield,
              filled: false,
              onPressed: _isBusy ? null : _checkPermission,
            ),
            AppCupertinoButton(
              label: '检测当前位置',
              icon: CupertinoIcons.location_fill,
              onPressed: _isBusy ? null : _detectCurrentLocation,
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _checkPermission() async {
    setState(() => _isBusy = true);
    final status = await widget.locationPermission.checkStatus();
    if (!mounted) {
      return;
    }
    setState(() {
      _status = status.message;
      _permissionStatus = status;
      _isBusy = false;
    });
  }

  Future<void> _detectCurrentLocation() async {
    setState(() => _isBusy = true);
    try {
      final status = await widget.locationPermission.requestPermission();
      if (!mounted) {
        return;
      }
      if (status != AppLocationPermissionStatus.ready &&
          status != AppLocationPermissionStatus.whileInUseOnly) {
        setState(() {
          _status = status.message;
          _permissionStatus = status;
          _isBusy = false;
        });
        return;
      }
      final result = await widget.locationDetection.detectCurrentLocation(
        widget.records,
      );
      await _handleDetectionResult(result);
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _status = '无法读取当前位置，请稍后重试或先手动补录。';
        _permissionStatus = AppLocationPermissionStatus.unknown;
        _isBusy = false;
      });
    }
  }

  String get _permissionLabel {
    return switch (_permissionStatus) {
      AppLocationPermissionStatus.ready => '正常',
      AppLocationPermissionStatus.whileInUseOnly => '受限',
      AppLocationPermissionStatus.serviceDisabled => '关闭',
      AppLocationPermissionStatus.denied ||
      AppLocationPermissionStatus.deniedForever => '未授权',
      AppLocationPermissionStatus.unknown => '未知',
    };
  }

  Color get _permissionColor {
    return switch (_permissionStatus) {
      AppLocationPermissionStatus.ready => AppColors.teal,
      AppLocationPermissionStatus.whileInUseOnly ||
      AppLocationPermissionStatus.serviceDisabled ||
      AppLocationPermissionStatus.unknown => CupertinoColors.systemOrange,
      AppLocationPermissionStatus.denied ||
      AppLocationPermissionStatus.deniedForever => AppColors.red,
    };
  }

  Future<void> _handleDetectionResult(LocationDetectionResult result) async {
    final candidate = result.candidateRecord;
    if (candidate != null) {
      await widget.onSaveCandidate(candidate);
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _status = candidate == null
          ? '检测结果：${result.boundaryResult.classification.label}，当前无需新增候选记录。'
          : '检测结果：${result.boundaryResult.classification.label}，已生成需要确认的候选记录。';
      _isBusy = false;
    });
    AppNotice.show(
      context,
      _status,
      action: candidate == null
          ? null
          : AppNoticeAction(label: '查看记录', onPressed: widget.onShowRecords),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.iconColor,
    this.titleColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      minimumSize: Size.zero,
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Row(
        children: [
          Icon(icon, color: context.appColor(iconColor ?? AppColors.ink)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: context.appColor(titleColor ?? AppColors.ink),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: context.appColor(AppColors.muted),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          if (onTap != null)
            Icon(
              CupertinoIcons.chevron_forward,
              color: context.appColor(AppColors.muted),
              size: 18,
            ),
        ],
      ),
    );
  }
}

class _SettingsDivider extends StatelessWidget {
  const _SettingsDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(vertical: 12),
      color: context.appColor(AppColors.border),
    );
  }
}

class _SettingsStatusRow extends StatelessWidget {
  const _SettingsStatusRow({
    required this.icon,
    required this.title,
    required this.trailing,
    required this.trailingColor,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String trailing;
  final Color trailingColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: context.appColor(AppColors.ink)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: TextStyle(
                    color: context.appColor(AppColors.muted),
                    fontSize: 13,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 10),
        Text(
          trailing,
          style: TextStyle(
            color: context.appColor(trailingColor),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
