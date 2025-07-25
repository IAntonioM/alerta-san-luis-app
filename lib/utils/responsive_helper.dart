import 'package:flutter/material.dart';
import 'dart:io';

class ResponsiveHelper {
  // Dimensiones base para cálculos (iPhone 11 Pro como referencia)
  static const double _baseWidth = 375.0;
  static const double _baseHeight = 812.0;
  
  // Breakpoints más precisos
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 900.0;
  static const double desktopBreakpoint = 1200.0;
  static const double largeDesktopBreakpoint = 1440.0;

  // === GETTERS BÁSICOS ===
  static double getScreenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double getScreenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  static Size getScreenSize(BuildContext context) =>
      MediaQuery.of(context).size;

  static double getStatusBarHeight(BuildContext context) =>
      MediaQuery.of(context).padding.top;

  static double getBottomSafeArea(BuildContext context) =>
      MediaQuery.of(context).padding.bottom;

  static EdgeInsets getSafeArea(BuildContext context) =>
      MediaQuery.of(context).padding;

  static double getDevicePixelRatio(BuildContext context) =>
      MediaQuery.of(context).devicePixelRatio;

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

  static bool isLargeDesktop(BuildContext context) =>
      getScreenWidth(context) >= largeDesktopBreakpoint;

  static bool isSmallMobile(BuildContext context) =>
      getScreenWidth(context) < 360;

  static bool isLargeMobile(BuildContext context) {
    final width = getScreenWidth(context);
    return width >= 400 && width < mobileBreakpoint;
  }

  static bool isSmallTablet(BuildContext context) {
    final width = getScreenWidth(context);
    return width >= mobileBreakpoint && width < 768;
  }

  static bool isLargeTablet(BuildContext context) {
    final width = getScreenWidth(context);
    return width >= 768 && width < tabletBreakpoint;
  }

  // === ORIENTACIÓN ===
  static bool isPortrait(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.portrait;

  static bool isLandscape(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.landscape;

  // === PLATAFORMA ===
  static bool isAndroid() => Platform.isAndroid;
  static bool isIOS() => Platform.isIOS;
  static bool isWeb() => !Platform.isAndroid && !Platform.isIOS;

  // === TAMAÑOS ESPECÍFICOS ===
  static bool isSmallPhone(BuildContext context) =>
      getScreenWidth(context) < 360;

  static bool isLargePhone(BuildContext context) {
    final width = getScreenWidth(context);
    return width >= 400 && width < mobileBreakpoint;
  }

  static bool isShortDevice(BuildContext context) =>
      getScreenHeight(context) < 700;

  static bool isTallDevice(BuildContext context) =>
      getScreenHeight(context) > 900;

  static bool isVeryTallDevice(BuildContext context) =>
      getScreenHeight(context) > 1000;

  // === ESCALADO INTELIGENTE ===
  static double scaleWidth(BuildContext context, double size) {
    return (getScreenWidth(context) / _baseWidth) * size;
  }

  static double scaleHeight(BuildContext context, double size) {
    return (getScreenHeight(context) / _baseHeight) * size;
  }

  static double scaleSize(BuildContext context, double size) {
    final screenWidth = getScreenWidth(context);
    final screenHeight = getScreenHeight(context);
    final scaleX = screenWidth / _baseWidth;
    final scaleY = screenHeight / _baseHeight;
    return (scaleX + scaleY) / 2 * size;
  }

  // === TAMAÑOS DE FUENTE MEJORADOS ===
  static double getFontSize(BuildContext context, double baseSize) {
    final textScale = getTextScaleFactor(context);
    double adjustedSize = baseSize;
    
    // Ajuste por tipo de dispositivo
    if (isSmallPhone(context)) {
      adjustedSize = baseSize * 0.85;
    } else if (isSmallTablet(context)) {
      adjustedSize = baseSize * 1.05;
    } else if (isLargeTablet(context)) {
      adjustedSize = baseSize * 1.1;
    } else if (isDesktop(context)) {
      adjustedSize = baseSize * 1.15;
    } else if (isLargeDesktop(context)) {
      adjustedSize = baseSize * 1.25;
    }
    
    // Limitar el escalado automático del sistema
    if (textScale > 1.3) {
      return adjustedSize * 1.1; // Escalado limitado para accesibilidad
    }
    
    return adjustedSize * textScale.clamp(0.8, 1.3);
  }

  // Tamaños específicos por categoría
  static double getHeadlineFontSize(BuildContext context, {double base = 32}) =>
      getFontSize(context, base);

  static double getTitleFontSize(BuildContext context, {double base = 24}) =>
      getFontSize(context, base);

  static double getSubtitleFontSize(BuildContext context, {double base = 20}) =>
      getFontSize(context, base);

  static double getBodyFontSize(BuildContext context, {double base = 16}) =>
      getFontSize(context, base);

  static double getButtonFontSize(BuildContext context, {double base = 16}) =>
      getFontSize(context, base);

  // === PADDING Y SPACING INTELIGENTES ===
  static double getHorizontalPadding(BuildContext context) {
    final width = getScreenWidth(context);
    
    if (isSmallPhone(context)) return 12.0;
    if (isSmallTablet(context)) return 24.0;
    if (isLargeTablet(context)) return 32.0;
    if (isDesktop(context)) return width > 1200 ? 48.0 : 40.0;
    if (isLargeDesktop(context)) return 56.0;
    
    return 20.0; // Mobile por defecto
  }

  static double getVerticalPadding(BuildContext context) {
    if (isShortDevice(context)) return 12.0;
    if (isSmallPhone(context)) return 16.0;
    if (isTablet(context)) return 24.0;
    if (isDesktop(context)) return 32.0;
    if (isTallDevice(context)) return 40.0;
    
    return 20.0;
  }

  static EdgeInsets getScreenPadding(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: getHorizontalPadding(context),
      vertical: getVerticalPadding(context),
    );
  }

  static double getSpacing(BuildContext context, {double base = 16}) {
    double multiplier = 1.0;
    
    if (isSmallPhone(context)) multiplier = 0.75;
    else if (isSmallTablet(context)) multiplier = 1.1;
    else if (isLargeTablet(context)) multiplier = 1.2;
    else if (isDesktop(context)) multiplier = 1.3;
    else if (isLargeDesktop(context)) multiplier = 1.5;
    
    return base * multiplier;
  }

  // === ALTURAS RESPONSIVAS MEJORADAS ===
  static double getResponsiveHeight(BuildContext context, double baseHeight) {
    final height = getScreenHeight(context);
    double heightMultiplier = 1.0;
    
    // Ajuste por altura total
    if (height < 600) heightMultiplier = 0.8;
    else if (height < 700) heightMultiplier = 0.9;
    else if (height > 900) heightMultiplier = 1.1;
    else if (height > 1000) heightMultiplier = 1.2;
    
    // Ajuste por categoría
    if (isTablet(context)) heightMultiplier *= 1.05;
    if (isDesktop(context)) heightMultiplier *= 1.1;
    
    return baseHeight * heightMultiplier;
  }

  static double getResponsiveWidth(BuildContext context, double baseWidth) {
    if (isSmallPhone(context)) return baseWidth * 0.9;
    if (isSmallTablet(context)) return baseWidth * 1.05;
    if (isLargeTablet(context)) return baseWidth * 1.1;
    if (isDesktop(context)) return baseWidth * 1.15;
    if (isLargeDesktop(context)) return baseWidth * 1.2;
    
    return baseWidth;
  }

  // === TAMAÑOS DE ICONOS ===
  static double getIconSize(BuildContext context, {double base = 24}) {
    if (isSmallPhone(context)) return base * 0.9;
    if (isSmallTablet(context)) return base * 1.05;
    if (isLargeTablet(context)) return base * 1.15;
    if (isDesktop(context)) return base * 1.25;
    if (isLargeDesktop(context)) return base * 1.35;
    
    return base;
  }

  // === COMPONENTES ESPECÍFICOS ===
  static double getButtonHeight(BuildContext context) {
    if (isSmallPhone(context)) return 44.0;
    if (isTablet(context)) return 52.0;
    if (isDesktop(context)) return 56.0;
    return 48.0;
  }

  static double getTextFieldHeight(BuildContext context) {
    if (isSmallPhone(context)) return 48.0;
    if (isTablet(context)) return 60.0;
    if (isDesktop(context)) return 64.0;
    return 56.0;
  }

  static double getAppBarHeight(BuildContext context) {
    if (isSmallPhone(context)) return 52.0;
    if (isTablet(context)) return 60.0;
    if (isDesktop(context)) return 64.0;
    return 56.0;
  }

  static double getBottomNavHeight(BuildContext context) {
    if (isSmallPhone(context)) return 56.0;
    if (isTablet(context)) return 64.0;
    if (isDesktop(context)) return 72.0;
    return 60.0;
  }

  // === BORDER RADIUS ===
  static double getBorderRadius(BuildContext context, {double base = 8}) {
    if (isSmallPhone(context)) return base * 0.8;
    if (isTablet(context)) return base * 1.1;
    if (isDesktop(context)) return base * 1.3;
    return base;
  }

  // === ELEVACIÓN ===
  static double getElevation(BuildContext context, {double base = 4}) {
    if (isSmallPhone(context)) return base * 0.8;
    if (isTablet(context)) return base * 1.1;
    if (isDesktop(context)) return base * 1.2;
    return base;
  }

  // === GRID RESPONSIVO ===
  static int getGridColumns(BuildContext context, {
    int mobile = 2,
    int tablet = 3,
    int desktop = 4,
    int largeDesktop = 5,
  }) {
    if (isMobile(context)) return mobile;
    if (isSmallTablet(context)) return tablet;
    if (isLargeTablet(context)) return tablet + 1;
    if (isLargeDesktop(context)) return largeDesktop;
    return desktop;
  }

  static double getGridAspectRatio(BuildContext context, {double base = 1.0}) {
    if (isLandscape(context)) return base * 1.3;
    if (isSmallPhone(context)) return base * 0.9;
    return base;
  }

  // === CONTENEDORES Y CARDS ===
  static double getCardWidth(BuildContext context, {double? maxWidth}) {
    final screenWidth = getScreenWidth(context);
    final padding = getHorizontalPadding(context) * 2;
    
    if (maxWidth != null && screenWidth > maxWidth + padding) {
      return maxWidth;
    }
    
    return screenWidth - padding;
  }

  static double getMaxContentWidth(BuildContext context) {
    final width = getScreenWidth(context);
    if (width > 1400) return 1200;
    if (width > 1200) return 1000;
    if (width > 900) return width * 0.85;
    if (width > 600) return width * 0.9;
    return width - (getHorizontalPadding(context) * 2);
  }

  static double getCardMaxWidth(BuildContext context) {
    if (isDesktop(context)) return 400;
    if (isTablet(context)) return 350;
    return double.infinity;
  }

  // === LAYOUT HELPERS ===
  static bool shouldUseDrawer(BuildContext context) => isMobile(context);
  
  static bool shouldUseBottomNavigation(BuildContext context) => 
      isMobile(context) || isSmallTablet(context);

  static bool shouldUseNavigationRail(BuildContext context) => 
      isLargeTablet(context) || isDesktop(context);

  static bool shouldUseSideNavigation(BuildContext context) => 
      isLargeDesktop(context);

  static int getBottomNavItems(BuildContext context) {
    if (isSmallPhone(context)) return 4;
    if (isMobile(context)) return 5;
    return 6;
  }

  static bool shouldUseCompactMode(BuildContext context) =>
      isSmallPhone(context) || (isMobile(context) && isLandscape(context));

  // === MODALES Y DIALOGS ===
  static double getDialogWidth(BuildContext context) {
    final screenWidth = getScreenWidth(context);
    if (isSmallPhone(context)) return screenWidth * 0.95;
    if (isMobile(context)) return screenWidth * 0.9;
    if (isTablet(context)) return 500;
    if (isDesktop(context)) return 600;
    return 700;
  }

  static double getDialogMaxHeight(BuildContext context) =>
      getScreenHeight(context) * 0.85;

  static double getBottomSheetMaxHeight(BuildContext context) {
    if (isShortDevice(context)) return getScreenHeight(context) * 0.75;
    return getScreenHeight(context) * 0.8;
  }

  static EdgeInsets getDialogPadding(BuildContext context) {
    return EdgeInsets.all(getSpacing(context, base: 24));
  }

  // === SLIVER APP BAR ===
  static double getSliverAppBarHeight(BuildContext context) {
    final statusBarHeight = getStatusBarHeight(context);
    final appBarHeight = getAppBarHeight(context);
    return statusBarHeight + appBarHeight;
  }

  static double getExpandedHeight(BuildContext context, {double base = 200}) {
    return getResponsiveHeight(context, base);
  }

  // === ANIMACIONES ===
  static Duration getAnimationDuration({bool fast = false, bool slow = false}) {
    if (fast) return const Duration(milliseconds: 150);
    if (slow) return const Duration(milliseconds: 500);
    return const Duration(milliseconds: 300);
  }

  static Curve getAnimationCurve({bool bounce = false}) {
    if (bounce) return Curves.elasticOut;
    return Curves.easeInOutCubic;
  }

  // === UTILIDADES AVANZADAS ===
  static T responsiveValue<T>(
    BuildContext context, {
    required T mobile,
    T? smallTablet,
    T? largeTablet,
    T? desktop,
    T? largeDesktop,
  }) {
    if (isLargeDesktop(context) && largeDesktop != null) return largeDesktop;
    if (isDesktop(context) && desktop != null) return desktop;
    if (isLargeTablet(context) && largeTablet != null) return largeTablet;
    if (isSmallTablet(context) && smallTablet != null) return smallTablet;
    if (isTablet(context) && (largeTablet != null || smallTablet != null)) {
      return largeTablet ?? smallTablet ?? mobile;
    }
    return mobile;
  }

  static EdgeInsets responsivePadding(
    BuildContext context, {
    EdgeInsets? mobile,
    EdgeInsets? tablet,
    EdgeInsets? desktop,
  }) {
    return responsiveValue(
      context,
      mobile: mobile ?? getScreenPadding(context),
      smallTablet: tablet,
      desktop: desktop,
    );
  }

  static double responsiveSpacing(
    BuildContext context, {
    double mobile = 16,
    double? tablet,
    double? desktop,
  }) {
    return responsiveValue(
      context,
      mobile: getSpacing(context, base: mobile),
      smallTablet: tablet != null ? getSpacing(context, base: tablet) : null,
      desktop: desktop != null ? getSpacing(context, base: desktop) : null,
    );
  }

  // === BREAKPOINT ESPECÍFICOS ===
  static bool isAtBreakpoint(BuildContext context, double breakpoint) =>
      getScreenWidth(context) >= breakpoint;

  static bool isBetweenBreakpoints(
    BuildContext context,
    double min,
    double max,
  ) {
    final width = getScreenWidth(context);
    return width >= min && width < max;
  }

  // === HELPERS PARA LISTAS ===
  static double getListItemHeight(BuildContext context, {double base = 72}) {
    if (isSmallPhone(context)) return base * 0.85;
    if (isTablet(context)) return base * 1.1;
    if (isDesktop(context)) return base * 1.2;
    return base;
  }

  static EdgeInsets getListItemPadding(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: getHorizontalPadding(context),
      vertical: getSpacing(context, base: 8),
    );
  }

  // === HELPERS PARA IMÁGENES ===
  static double getImageSize(BuildContext context, {double base = 100}) {
    return getResponsiveWidth(context, base);
  }

  static BorderRadius getImageBorderRadius(BuildContext context) {
    return BorderRadius.circular(getBorderRadius(context, base: 12));
  }

  // === HELPERS PARA FORMULARIOS ===
  static EdgeInsets getFormPadding(BuildContext context) {
    return EdgeInsets.all(getSpacing(context, base: 20));
  }

  static double getFormSpacing(BuildContext context) {
    return getSpacing(context, base: 24);
  }

  static double getFormFieldSpacing(BuildContext context) {
    return getSpacing(context, base: 16);
  }

  // === UTILIDADES DE ORIENTACIÓN ===
  static bool shouldStackVertically(BuildContext context) {
    return isMobile(context) || (isTablet(context) && isPortrait(context));
  }

  static bool shouldStackHorizontally(BuildContext context) {
    return isDesktop(context) || (isTablet(context) && isLandscape(context));
  }

  static CrossAxisAlignment getMainAxisAlignment(BuildContext context) {
    if (shouldStackVertically(context)) return CrossAxisAlignment.stretch;
    return CrossAxisAlignment.start;
  }

  // === DEBUG UTILITIES ===
  static void logScreenInfo(BuildContext context) {
    print('=== RESPONSIVE DEBUG INFO ===');
    print('Screen Size: ${getScreenSize(context)}');
    print('Width: ${getScreenWidth(context)}');
    print('Height: ${getScreenHeight(context)}');
    print('Device Category: ${_getDeviceCategory(context)}');
    print('Orientation: ${isPortrait(context) ? 'Portrait' : 'Landscape'}');
    print('Platform: ${_getPlatform()}');
    print('Status Bar Height: ${getStatusBarHeight(context)}');
    print('Safe Area: ${getSafeArea(context)}');
    print('Text Scale Factor: ${getTextScaleFactor(context)}');
    print('Device Pixel Ratio: ${getDevicePixelRatio(context)}');
    print('Horizontal Padding: ${getHorizontalPadding(context)}');
    print('Vertical Padding: ${getVerticalPadding(context)}');
    print('Base Spacing: ${getSpacing(context)}');
    print('Button Height: ${getButtonHeight(context)}');
    print('Max Content Width: ${getMaxContentWidth(context)}');
    print('Should Use Drawer: ${shouldUseDrawer(context)}');
    print('Should Use Bottom Nav: ${shouldUseBottomNavigation(context)}');
    print('Should Use Navigation Rail: ${shouldUseNavigationRail(context)}');
    print('=============================');
  }

  static String _getDeviceCategory(BuildContext context) {
    if (isSmallPhone(context)) return 'Small Phone';
    if (isMobile(context)) return 'Mobile';
    if (isSmallTablet(context)) return 'Small Tablet';
    if (isLargeTablet(context)) return 'Large Tablet';
    if (isLargeDesktop(context)) return 'Large Desktop';
    if (isDesktop(context)) return 'Desktop';
    return 'Unknown';
  }

  static String _getPlatform() {
    if (isAndroid()) return 'Android';
    if (isIOS()) return 'iOS';
    if (isWeb()) return 'Web';
    return 'Unknown';
  }

  // === HELPERS PARA COLUMNAS ADAPTATIVAS ===
  static List<Widget> adaptiveColumns(
    BuildContext context,
    List<Widget> children, {
    double spacing = 16,
  }) {
    if (shouldStackVertically(context)) {
      return children
          .expand((child) => [
                child,
                SizedBox(height: getSpacing(context, base: spacing)),
              ])
          .take(children.length * 2 - 1)
          .toList();
    } else {
      return [
        Row(
          children: children
              .expand((child) => [
                    Expanded(child: child),
                    if (child != children.last)
                      SizedBox(width: getSpacing(context, base: spacing)),
                  ])
              .take(children.length * 2 - 1)
              .toList(),
        ),
      ];
    }
  }

  // === WRAPPER PARA CONTENIDO CENTRADO ===
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

  // === WRAPPER PARA CONTENIDO ADAPTATIVO ===
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
}