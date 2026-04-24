import 'package:flutter/material.dart';

class Responsive {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static late double blockSizeHorizontal;
  static late double blockSizeVertical;
  static late double _safeAreaHorizontal;
  static late double _safeAreaVertical;
  static late double safeBlockHorizontal;
  static late double safeBlockVertical;

  static void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;

    _safeAreaHorizontal =
        _mediaQueryData.padding.left + _mediaQueryData.padding.right;
    _safeAreaVertical =
        _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;
    safeBlockHorizontal = (screenWidth - _safeAreaHorizontal) / 100;
    safeBlockVertical = (screenHeight - _safeAreaVertical) / 100;
  }

  // Returns a value based on a percentage of the screen width
  static double width(double percent) {
    return blockSizeHorizontal * percent;
  }

  // Returns a value based on a percentage of the screen height
  static double height(double percent) {
    return blockSizeVertical * percent;
  }

  // Returns a value based on a percentage of the safe screen width
  static double safeWidth(double percent) {
    return safeBlockHorizontal * percent;
  }

  // Returns a value based on a percentage of the safe screen height
  static double safeHeight(double percent) {
    return safeBlockVertical * percent;
  }

  // Returns font size based on screen width percentage
  static double fontSize(double percent) {
    return blockSizeHorizontal * percent;
  }

  // Check if screen is small (mobile)
  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  // Check if screen is medium (tablet)
  static bool isMediumScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= 600 &&
        MediaQuery.of(context).size.width < 1200;
  }

  // Check if screen is large (desktop)
  static bool isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1200;
  }
}

// Extension for easier access
extension ResponsiveExtension on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;

  // Percentage of screen width
  double wp(double percent) => screenWidth * (percent / 100);

  // Percentage of screen height
  double hp(double percent) => screenHeight * (percent / 100);

  // Scaled font size based on screen size with a safety cap
  double sp(double size) {
    double scale = screenWidth / 375; // Standard design width
    return (size * scale).clamp(size * 0.8, size * 1.4);
  }

  bool get isMobile => screenWidth < 600;
  bool get isTablet => screenWidth >= 600 && screenWidth < 1024;
  bool get isDesktop => screenWidth >= 1024;

  // Orientation helpers
  bool get isLandscape =>
      MediaQuery.of(this).orientation == Orientation.landscape;
}
