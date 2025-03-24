import 'package:flutter/material.dart';

/// AppDimensions provides standardized sizing constants
/// to maintain consistency throughout the app.
class AppDimensions {
  // Private constructor to prevent instantiation
  AppDimensions._();

  // Screen padding
  static const double screenPaddingHorizontal = 16.0;
  static const double screenPaddingVertical = 24.0;
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: screenPaddingHorizontal,
    vertical: screenPaddingVertical,
  );

  // Margins and spacing
  static const double spaceXSmall = 4.0;
  static const double spaceSmall = 8.0;
  static const double spaceMedium = 16.0;
  static const double spaceLarge = 24.0;
  static const double spaceXLarge = 32.0;
  static const double spaceXXLarge = 48.0;

  // Border properties
  static const double borderWidth = 1.0;
  static const double borderWidthFocused = 2.0;
  static const double borderRadius = 8.0;
  static const double cardBorderRadius = 12.0;
  static const double buttonBorderRadius = 8.0;
  static const double dialogBorderRadius = 16.0;

  // Button dimensions
  static const double buttonHeight = 48.0;
  static const double buttonHeightSmall = 36.0;
  static const double buttonHeightLarge = 56.0;
  static const double buttonPaddingHorizontal = 24.0;
  static const double buttonPaddingVertical = 12.0;
  static const double iconButtonSize = 40.0;

  // Input fields
  static const double inputFieldHeight = 56.0;
  static const double inputFieldPaddingHorizontal = 16.0;
  static const double inputFieldPaddingVertical = 16.0;

  // Card and container
  static const double cardElevation = 2.0;
  static const double cardPadding = 16.0;
  static const double containerPadding = 16.0;

  // Icons
  static const double iconSizeSmall = 16.0;
  static const double iconSizeDefault = 24.0;
  static const double iconSizeLarge = 32.0;
  static const double iconSizeXLarge = 48.0;

  // Avatar and profile images
  static const double avatarSizeSmall = 32.0;
  static const double avatarSizeMedium = 48.0;
  static const double avatarSizeLarge = 64.0;
  static const double avatarSizeXLarge = 96.0;

  // Badge and indicators
  static const double badgeSize = 20.0;
  static const double badgeBorderRadius = 10.0;
  static const double indicatorSize = 8.0;
  static const double dotIndicatorSize = 6.0;

  // Bottom navigation
  static const double bottomNavHeight = 56.0;
  static const double bottomNavIconSize = 24.0;

  // App bar
  static const double appBarHeight = 56.0;

  // Drawer
  static const double drawerWidth = 280.0;

  // Divider
  static const double dividerThickness = 1.0;
  static const double dividerThicknessBold = 2.0;
  static const double dividerIndent = 16.0;

  // Map related
  static const double mapControlButtonSize = 40.0;
  static const double mapMarkerSize = 32.0;
  static const double mapInfoWindowWidth = 240.0;

  // Dashboard widgets
  static const double dashboardCardHeight = 120.0;
  static const double weatherWidgetHeight = 180.0;
  static const double fishingStatusCardHeight = 100.0;

  // Loading indicators
  static const double loadingIndicatorSizeSmall = 24.0;
  static const double loadingIndicatorSizeMedium = 36.0;
  static const double loadingIndicatorSizeLarge = 48.0;

  // Device specific constants
  static double screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;
  static double screenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  // Screen size breakpoints
  static const double breakpointPhone = 600.0;
  static const double breakpointTablet = 900.0;
  static const double breakpointDesktop = 1200.0;

  // Safe area
  static EdgeInsets safeAreaPadding(BuildContext context) =>
      MediaQuery.of(context).padding;

  // Responsive padding calculations
  static EdgeInsets responsivePadding(BuildContext context) {
    final width = screenWidth(context);
    if (width > breakpointTablet) {
      return const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0);
    } else if (width > breakpointPhone) {
      return const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0);
    } else {
      return const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0);
    }
  }
}
