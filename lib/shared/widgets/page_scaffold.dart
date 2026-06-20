import 'package:flutter/cupertino.dart';

import '../theme/app_theme.dart';

class AppPage extends StatelessWidget {
  const AppPage({
    super.key,
    required this.title,
    this.subtitle,
    required this.children,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final List<Widget> children;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: context.appColor(AppColors.background),
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: Text(title),
            trailing: trailing,
            backgroundColor: context
                .appColor(AppColors.background)
                .withValues(alpha: 0.86),
            border: null,
          ),
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (subtitle != null) ...[
                        Text(
                          subtitle!,
                          style: TextStyle(
                            color: context.appColor(AppColors.muted),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      ...children,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AppSliverPage extends StatelessWidget {
  const AppSliverPage({
    super.key,
    required this.title,
    required this.slivers,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final List<Widget> slivers;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: context.appColor(AppColors.background),
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: Text(title),
            trailing: trailing,
            backgroundColor: context
                .appColor(AppColors.background)
                .withValues(alpha: 0.86),
            border: null,
          ),
          if (subtitle != null)
            SliverToBoxAdapter(
              child: _PageWidth(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: Text(
                    subtitle!,
                    style: TextStyle(color: context.appColor(AppColors.muted)),
                  ),
                ),
              ),
            ),
          ...slivers,
          const SliverToBoxAdapter(child: SizedBox(height: 96)),
        ],
      ),
    );
  }
}

class AppSliverSection extends StatelessWidget {
  const AppSliverSection({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(20, 8, 20, 0),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: _PageWidth(
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

class AppSliverListSection extends StatelessWidget {
  const AppSliverListSection({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.padding = const EdgeInsets.fromLTRB(20, 8, 20, 0),
  });

  final int itemCount;
  final NullableIndexedWidgetBuilder itemBuilder;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final child = itemBuilder(context, index);
        if (child == null) {
          return null;
        }
        return _PageWidth(
          child: Padding(padding: padding, child: child),
        );
      }, childCount: itemCount),
    );
  }
}

class _PageWidth extends StatelessWidget {
  const _PageWidth({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: child,
      ),
    );
  }
}
