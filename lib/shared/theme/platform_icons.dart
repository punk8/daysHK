import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'platform_style.dart';

class AppPlatformIcon {
  const AppPlatformIcon._();

  static IconData of(
    BuildContext context, {
    required IconData cupertino,
    required IconData material,
  }) {
    return AppPlatformStyle.isMaterial(context) ? material : cupertino;
  }

  static IconData home(BuildContext context, {bool filled = false}) => of(
    context,
    cupertino: filled ? CupertinoIcons.house_fill : CupertinoIcons.house,
    material: filled ? Icons.home : Icons.home_outlined,
  );

  static IconData statistics(BuildContext context, {bool filled = false}) => of(
    context,
    cupertino: filled
        ? CupertinoIcons.chart_bar_fill
        : CupertinoIcons.chart_bar,
    material: filled ? Icons.bar_chart : Icons.bar_chart_outlined,
  );

  static IconData records(BuildContext context, {bool filled = false}) => of(
    context,
    cupertino: CupertinoIcons.list_bullet,
    material: filled ? Icons.format_list_bulleted : Icons.list_alt_outlined,
  );

  static IconData addRecord(BuildContext context, {bool filled = false}) => of(
    context,
    cupertino: filled
        ? CupertinoIcons.plus_circle_fill
        : CupertinoIcons.plus_circle,
    material: filled ? Icons.add_circle : Icons.add_circle_outline,
  );

  static IconData settings(BuildContext context, {bool filled = false}) => of(
    context,
    cupertino: filled ? CupertinoIcons.gear_solid : CupertinoIcons.gear,
    material: filled ? Icons.settings : Icons.settings_outlined,
  );

  static IconData notifications(BuildContext context) => of(
    context,
    cupertino: CupertinoIcons.bell,
    material: Icons.notifications_none,
  );

  static IconData place(BuildContext context, {bool filled = false}) => of(
    context,
    cupertino: filled ? CupertinoIcons.location_solid : CupertinoIcons.location,
    material: filled ? Icons.location_on : Icons.location_on_outlined,
  );

  static IconData locationOff(BuildContext context) => of(
    context,
    cupertino: CupertinoIcons.location_slash,
    material: Icons.location_off_outlined,
  );

  static IconData building(BuildContext context) => of(
    context,
    cupertino: CupertinoIcons.building_2_fill,
    material: Icons.apartment,
  );

  static IconData info(BuildContext context) => of(
    context,
    cupertino: CupertinoIcons.info_circle,
    material: Icons.info_outline,
  );

  static IconData storage(BuildContext context) => of(
    context,
    cupertino: CupertinoIcons.archivebox,
    material: Icons.inventory_2_outlined,
  );

  static IconData delete(BuildContext context) => of(
    context,
    cupertino: CupertinoIcons.delete,
    material: Icons.delete_outline,
  );

  static IconData privacy(BuildContext context) => of(
    context,
    cupertino: CupertinoIcons.hand_raised,
    material: Icons.privacy_tip_outlined,
  );

  static IconData document(BuildContext context) => of(
    context,
    cupertino: CupertinoIcons.doc_text,
    material: Icons.description_outlined,
  );

  static IconData refresh(BuildContext context) =>
      of(context, cupertino: CupertinoIcons.refresh, material: Icons.refresh);

  static IconData play(BuildContext context) => of(
    context,
    cupertino: CupertinoIcons.play_arrow_solid,
    material: Icons.play_arrow,
  );

  static IconData stop(BuildContext context) =>
      of(context, cupertino: CupertinoIcons.stop_fill, material: Icons.stop);

  static IconData shield(BuildContext context) => of(
    context,
    cupertino: CupertinoIcons.checkmark_shield,
    material: Icons.verified_user_outlined,
  );

  static IconData calendar(BuildContext context) => of(
    context,
    cupertino: CupertinoIcons.calendar,
    material: Icons.calendar_today_outlined,
  );

  static IconData clear(BuildContext context) => of(
    context,
    cupertino: CupertinoIcons.clear_circled,
    material: Icons.cancel_outlined,
  );

  static IconData more(BuildContext context) => of(
    context,
    cupertino: CupertinoIcons.ellipsis_circle,
    material: Icons.more_vert,
  );

  static IconData entry(BuildContext context) => of(
    context,
    cupertino: CupertinoIcons.arrow_down_left,
    material: Icons.south_west,
  );

  static IconData exit(BuildContext context) => of(
    context,
    cupertino: CupertinoIcons.arrow_up_right,
    material: Icons.north_east,
  );

  static IconData roundTrip(BuildContext context) => of(
    context,
    cupertino: CupertinoIcons.arrow_right_arrow_left,
    material: Icons.compare_arrows,
  );

  static IconData chevronForward(BuildContext context) => of(
    context,
    cupertino: CupertinoIcons.chevron_forward,
    material: Icons.chevron_right,
  );

  static IconData success(BuildContext context) => of(
    context,
    cupertino: CupertinoIcons.check_mark_circled_solid,
    material: Icons.check_circle_outline,
  );
}
