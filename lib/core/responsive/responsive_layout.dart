import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Shared responsive primitives for future desktop/laptop polish.
///
/// Use these helpers to constrain wide web layouts without changing the
/// existing mobile presentation. Prefer wrapping page content on desktop first,
/// then move individual cards/forms only when an actual overflow or stretched
/// layout is confirmed.
///
/// Loading-state improvements should remain in separate targeted phases so
/// responsive changes do not also alter Firebase reads, streams, or route state.
class ResponsiveBreakpoints {
  const ResponsiveBreakpoints._();

  static const double mobile = 600;
  static const double desktop = 1024;
  static const double largeDesktop = 1440;

  static bool isMobileWidth(double width) => width < mobile;

  static bool isTabletWidth(double width) => width >= mobile && width < desktop;

  static bool isDesktopWidth(double width) =>
      width >= desktop && width < largeDesktop;

  static bool isLargeDesktopWidth(double width) => width >= largeDesktop;
}

extension ResponsiveContext on BuildContext {
  double get responsiveWidth => MediaQuery.sizeOf(this).width;

  bool get isMobile => ResponsiveBreakpoints.isMobileWidth(responsiveWidth);

  bool get isTablet => ResponsiveBreakpoints.isTabletWidth(responsiveWidth);

  bool get isDesktop => ResponsiveBreakpoints.isDesktopWidth(responsiveWidth);

  bool get isLargeDesktop =>
      ResponsiveBreakpoints.isLargeDesktopWidth(responsiveWidth);
}

class ResponsiveMaxWidths {
  const ResponsiveMaxWidths._();

  static const double form = 480;
  static const double dialog = 640;
  static const double content = 1180;
  static const double dashboard = 1320;
  static const double wideDashboard = 1440;
}

/// Centers and constrains content on tablet/desktop while leaving mobile close
/// to the current full-width behavior.
class ResponsiveMaxWidth extends StatelessWidget {
  const ResponsiveMaxWidth({
    super.key,
    required this.child,
    this.maxWidth = ResponsiveMaxWidths.content,
    this.mobilePadding = EdgeInsets.zero,
    this.desktopPadding = const EdgeInsets.symmetric(horizontal: 24),
    this.alignment = Alignment.topCenter,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry mobilePadding;
  final EdgeInsetsGeometry desktopPadding;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;

    return Align(
      alignment: alignment,
      child: Padding(
        padding: isMobile ? mobilePadding : desktopPadding,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isMobile ? double.infinity : maxWidth,
          ),
          child: child,
        ),
      ),
    );
  }
}

class ResponsiveCenter extends ResponsiveMaxWidth {
  const ResponsiveCenter({
    super.key,
    required super.child,
    super.maxWidth = ResponsiveMaxWidths.content,
    super.mobilePadding,
    super.desktopPadding,
    super.alignment,
  });
}

int responsiveGridColumnCount(
  double width, {
  int mobileColumns = 1,
  int tabletColumns = 2,
  int desktopColumns = 3,
  int largeDesktopColumns = 4,
}) {
  if (ResponsiveBreakpoints.isLargeDesktopWidth(width)) {
    return largeDesktopColumns;
  }
  if (ResponsiveBreakpoints.isDesktopWidth(width)) {
    return desktopColumns;
  }
  if (ResponsiveBreakpoints.isTabletWidth(width)) {
    return tabletColumns;
  }
  return mobileColumns;
}

class KeyboardSafeScrollView extends StatelessWidget {
  const KeyboardSafeScrollView({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.physics,
    this.keyboardPadding = 24,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final ScrollPhysics? physics;
  final double keyboardPadding;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return SingleChildScrollView(
      physics: physics ?? const AlwaysScrollableScrollPhysics(),
      padding: padding.add(EdgeInsets.only(
        bottom: bottomInset > 0 ? bottomInset + keyboardPadding : 0,
      )),
      child: child,
    );
  }
}

/// Use for future form/dialog work to avoid oversized dialogs on desktop and
/// vertical overflow at high browser zoom levels.
class ResponsiveDialogConstraints extends StatelessWidget {
  const ResponsiveDialogConstraints({
    super.key,
    required this.child,
    this.maxWidth = ResponsiveMaxWidths.dialog,
    this.maxHeightFactor = 0.9,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final double maxWidth;
  final double maxHeightFactor;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final maxHeight = math.max(0.0, size.height * maxHeightFactor);

    return Center(
      child: Padding(
        padding: padding,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: math.min(maxWidth, size.width),
            maxHeight: maxHeight,
          ),
          child: child,
        ),
      ),
    );
  }
}

double floatingNavSafeBottomPadding(
  BuildContext context, {
  double navHeight = 88,
  double margin = 20,
}) {
  return MediaQuery.paddingOf(context).bottom + navHeight + margin;
}
