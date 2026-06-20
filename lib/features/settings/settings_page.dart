import 'package:flutter/material.dart';

import '../../core/time/hk_date.dart';
import '../../domain/models/stay_record.dart';
import '../../location/geofence/location_detection_service.dart';
import '../../location/geofence/native_geofence_bridge.dart';
import '../../location/permissions/location_permission_service.dart';
import '../../location/permissions/location_permission_status.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/app_card.dart';
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
            icon: Icons.storage_outlined,
            title: '数据存储',
            subtitle: '所有数据仅保存在本地设备中，不会上传或分享你的数据。',
          ),
        ),
        const SizedBox(height: 12),
        AppCard(
          child: Column(
            children: [
              _SettingsTile(
                icon: Icons.delete_outline,
                iconColor: AppColors.red,
                title: '清除所有数据',
                titleColor: AppColors.red,
                subtitle: '删除本地所有记录，无法恢复',
                onTap: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('清除所有数据'),
                      content: const Text('将删除本地所有入离港记录，无法恢复。是否继续？'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('取消'),
                        ),
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.red,
                          ),
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('清除'),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true) {
                    await onClearAll();
                    if (context.mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(const SnackBar(content: Text('本地数据已清除')));
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
                icon: Icons.privacy_tip_outlined,
                title: '隐私说明',
                subtitle: '本应用用于个人记录参考，不构成永居资格判断。',
              ),
              Divider(),
              _SettingsTile(
                icon: Icons.description_outlined,
                title: '使用条款',
                subtitle: '统计结果基于你的记录估算，可能存在误差。',
              ),
              Divider(),
              _SettingsTile(
                icon: Icons.info_outline,
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
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.radar_outlined),
          title: const Text(
            '后台自动检测',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          subtitle: statusMessage == null ? null : Text(statusMessage),
          trailing: Text(
            statusLabel,
            style: const TextStyle(
              color: AppColors.teal,
              fontWeight: FontWeight.w700,
            ),
          ),
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
            OutlinedButton.icon(
              onPressed: _isBusy ? null : _refresh,
              icon: const Icon(Icons.refresh),
              label: const Text('刷新状态'),
            ),
            if (!isRunning)
              FilledButton.icon(
                onPressed: _isBusy ? null : _start,
                icon: const Icon(Icons.play_arrow),
                label: const Text('启动检测'),
              ),
            if (isRunning)
              OutlinedButton.icon(
                onPressed: _isBusy ? null : _stop,
                icon: const Icon(Icons.stop),
                label: const Text('停止'),
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('开启后台自动检测'),
        content: const Text(
          '后台自动检测需要“始终允许”定位权限。系统可能会先询问定位授权；授权后请再次点击启动检测完成开启。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('继续'),
          ),
        ],
      ),
    );
    if (confirmed != true) {
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('已根据最近原生事件生成需要确认的候选记录')));
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
        color: AppColors.teal.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.teal.withValues(alpha: 0.22)),
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
            child: OutlinedButton.icon(
              onPressed: onCreateCandidate,
              icon: const Icon(Icons.add_location_alt_outlined),
              label: const Text('生成候选记录'),
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
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.location_on_outlined),
          title: const Text(
            '定位权限状态',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          subtitle: Text(_status),
          trailing: Text(
            _permissionLabel,
            style: TextStyle(
              color: _permissionColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: _isBusy ? null : _checkPermission,
              icon: const Icon(Icons.verified_user_outlined),
              label: const Text('检查权限'),
            ),
            FilledButton.icon(
              onPressed: _isBusy ? null : _detectCurrentLocation,
              icon: const Icon(Icons.my_location),
              label: const Text('检测当前位置'),
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
      AppLocationPermissionStatus.unknown => Colors.orange,
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_status),
        action: candidate == null
            ? null
            : SnackBarAction(label: '查看记录', onPressed: widget.onShowRecords),
      ),
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
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: iconColor ?? AppColors.ink),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w700, color: titleColor),
      ),
      subtitle: Text(subtitle),
      trailing: onTap == null ? null : const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
