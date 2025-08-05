// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'dart:io';

class ResponsiveHelper {
  // Breakpoints
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 900.0;
  static const double desktopBreakpoint = 1200.0;

  // === GETTERS BÁSICOS ===
  static double getScreenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double getScreenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  static Size getScreenSize(BuildContext context) =>
      MediaQuery.of(context).size;

  static double getStatusBarHeight(BuildContext context) =>
      MediaQuery.of(context).padding.top;

  static EdgeInsets getSafeArea(BuildContext context) =>
      MediaQuery.of(context).padding;

  static double getTextScaleFactor(BuildContext context) =>
      MediaQuery.of(context).textScaleFactor;

  // === CATEGORÍAS DE DISPOSITIVOS ===
  static bool isMobile(BuildContext context) =>
      getScreenWidth(context) < mobileBreakpoint;

  static bool isTablet(BuildContext context) {
    final width = getScreenWidth(context);
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) =>
      getScreenWidth(context) >= tabletBreakpoint;

  static bool isSmallMobile(BuildContext context) =>
      getScreenWidth(context) < 360;

  static bool isLargeDesktop(BuildContext context) =>
      getScreenWidth(context) >= desktopBreakpoint;

  // === ORIENTACIÓN ===
  static bool isPortrait(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.portrait;

  static bool isLandscape(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.landscape;

  // === PLATAFORMA ===
  static bool isAndroid() => Platform.isAndroid;
  static bool isIOS() => Platform.isIOS;
  static bool isWeb() => !Platform.isAndroid && !Platform.isIOS;

  // === TAMAÑOS DE FUENTE ===
  static double getFontSize(BuildContext context, double baseSize) {
    final textScale = getTextScaleFactor(context).clamp(0.8, 1.3);
    double adjustedSize = baseSize;

    if (isSmallMobile(context)) {
      adjustedSize = baseSize * 0.9;
    } else if (isTablet(context)) {
      adjustedSize = baseSize * 1.1;
    } else if (isDesktop(context)) {
      adjustedSize = baseSize * 1.2;
    } else if (isLargeDesktop(context)) {
      adjustedSize = baseSize * 1.3;
    }

    return adjustedSize * textScale;
  }

  // === TAMAÑOS DE FUENTE ESPECÍFICOS ===
  static double getTitleFontSize(BuildContext context, {double base = 24}) {
    return getFontSize(context, base);
  }

  static double getBodyFontSize(BuildContext context, {double base = 14}) {
    return getFontSize(context, base);
  }

  static double getButtonFontSize(BuildContext context, {double base = 16}) {
    return getFontSize(context, base);
  }

  static double getCaptionFontSize(BuildContext context, {double base = 12}) {
    return getFontSize(context, base);
  }

  // === PADDING Y SPACING ===
  static double getHorizontalPadding(BuildContext context) {
    if (isSmallMobile(context)) return 12.0;
    if (isTablet(context)) return 24.0;
    if (isDesktop(context)) return 32.0;
    if (isLargeDesktop(context)) return 48.0;
    return 16.0; // Mobile por defecto
  }

  static double getVerticalPadding(BuildContext context) {
    if (isSmallMobile(context)) return 12.0;
    if (isTablet(context)) return 20.0;
    if (isDesktop(context)) return 24.0;
    return 16.0;
  }

  static EdgeInsets getScreenPadding(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: getHorizontalPadding(context),
      vertical: getVerticalPadding(context),
    );
  }

  static double getSpacing(BuildContext context, {double base = 16}) {
    double multiplier = 1.0;

    if (isSmallMobile(context)) {
      multiplier = 0.8;
    } else if (isTablet(context)) {
      multiplier = 1.2;
    } else if (isDesktop(context)) {
      multiplier = 1.4;
    } else if (isLargeDesktop(context)) {
      multiplier = 1.6;
    }

    return base * multiplier;
  }

  // === SPACING ESPECÍFICOS ===
  static double getFormSpacing(BuildContext context) {
    return getSpacing(context, base: 24);
  }

  static double getFormFieldSpacing(BuildContext context) {
    return getSpacing(context, base: 16);
  }

  static double getSectionSpacing(BuildContext context) {
    return getSpacing(context, base: 32);
  }

  // === TAMAÑOS RESPONSIVOS ===
  static double getResponsiveSize(BuildContext context, double baseSize) {
    if (isSmallMobile(context)) return baseSize * 0.85;
    if (isTablet(context)) return baseSize * 1.1;
    if (isDesktop(context)) return baseSize * 1.2;
    if (isLargeDesktop(context)) return baseSize * 1.3;
    return baseSize;
  }

  // === DIMENSIONES RESPONSIVAS ===
  static double getResponsiveWidth(BuildContext context, double baseWidth) {
    return getResponsiveSize(context, baseWidth);
  }

  static double getResponsiveHeight(BuildContext context, double baseHeight) {
    return getResponsiveSize(context, baseHeight);
  }

  // === COMPONENTES ESPECÍFICOS ===
  static double getButtonHeight(BuildContext context) {
    return getResponsiveSize(context, 48.0);
  }

  static double getAppBarHeight(BuildContext context) {
    return getResponsiveSize(context, 56.0);
  }

  static double getSliverAppBarHeight(BuildContext context) {
    return getResponsiveSize(context, 120.0);
  }

  static double getIconSize(BuildContext context, {double base = 24}) {
    return getResponsiveSize(context, base);
  }

  static double getBorderRadius(BuildContext context, {double base = 8}) {
    return getResponsiveSize(context, base);
  }

  static BorderRadius getImageBorderRadius(BuildContext context) {
    return BorderRadius.circular(getBorderRadius(context, base: 12));
  }

  static double getElevation(BuildContext context, {double base = 2}) {
    return getResponsiveSize(context, base);
  }

  // === ANIMACIONES ===
  static Duration getAnimationDuration({bool slow = false}) {
    return Duration(milliseconds: slow ? 800 : 300);
  }

  static Curve getAnimationCurve({bool bounce = false}) {
    return bounce ? Curves.elasticOut : Curves.easeInOut;
  }

  // === GRID RESPONSIVO ===
  static int getGridColumns(BuildContext context, {
    int mobile = 2,
    int tablet = 3,
    int desktop = 4,
  }) {
    if (isMobile(context)) return mobile;
    if (isTablet(context)) return tablet;
    return desktop;
  }

  // === CONTENEDORES ===
  static double getMaxContentWidth(BuildContext context) {
    final width = getScreenWidth(context);
    if (width > 1200) return 1000;
    if (width > 900) return width * 0.85;
    if (width > 600) return width * 0.9;
    return width - (getHorizontalPadding(context) * 2);
  }

  // === LAYOUT HELPERS ===
  static bool shouldUseDrawer(BuildContext context) => isMobile(context);

  static bool shouldUseBottomNavigation(BuildContext context) =>
      isMobile(context);

  static bool shouldUseNavigationRail(BuildContext context) =>
      isTablet(context) || isDesktop(context);

  // === MODALES Y DIALOGS ===
  static double getDialogWidth(BuildContext context) {
    final screenWidth = getScreenWidth(context);
    if (isMobile(context)) return screenWidth * 0.9;
    if (isTablet(context)) return 500;
    return 600;
  }

  static double getDialogMaxHeight(BuildContext context) =>
      getScreenHeight(context) * 0.8;

  // === UTILIDADES AVANZADAS ===
  static T responsiveValue<T>(
      BuildContext context, {
        required T mobile,
        T? tablet,
        T? desktop,
      }) {
    if (isDesktop(context) && desktop != null) return desktop;
    if (isTablet(context) && tablet != null) return tablet;
    return mobile;
  }

  // === WRAPPERS ÚTILES ===
  static Widget centeredContent(
      BuildContext context,
      Widget child, {
        double? maxWidth,
      }) {
    final contentMaxWidth = maxWidth ?? getMaxContentWidth(context);

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: contentMaxWidth),
        child: Padding(
          padding: getScreenPadding(context),
          child: child,
        ),
      ),
    );
  }

  static Widget adaptiveContainer(
      BuildContext context,
      Widget child, {
        EdgeInsets? padding,
        double? maxWidth,
      }) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        maxWidth: maxWidth ?? getMaxContentWidth(context),
      ),
      padding: padding ?? getScreenPadding(context),
      child: child,
    );
  }

  // === COLUMNAS ADAPTATIVAS ===
  static List<Widget> adaptiveColumns(
      BuildContext context,
      List<Widget> children, {
        double spacing = 16,
      }) {
    final adaptiveSpacing = getSpacing(context, base: spacing);

    if (isMobile(context) || (isTablet(context) && isPortrait(context))) {
      // Stack verticalmente
      return children
          .expand((child) => [
        child,
        SizedBox(height: adaptiveSpacing),
      ])
          .take(children.length * 2 - 1)
          .toList();
    } else {
      // Stack horizontalmente
      return [
        Row(
          children: children
              .expand((child) => [
            Expanded(child: child),
            if (child != children.last)
              SizedBox(width: adaptiveSpacing),
          ])
              .take(children.length * 2 - 1)
              .toList(),
        ),
      ];
    }
  }
}