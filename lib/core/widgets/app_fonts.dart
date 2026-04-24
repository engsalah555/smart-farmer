import 'package:flutter/material.dart';

/// AppFonts provides a structured way to manage text styles in the app.
/// It uses a BuildContext extension for easy access and chainable weights.
class AppFonts {
  static const double size32 = 32.0;
  static const double size24 = 24.0;
  static const double size20 = 20.0;
  static const double size18 = 18.0;
  static const double size16 = 16.0;
  static const double size14 = 14.0;
  static const double size12 = 12.0;
  static const double size10 = 10.0;
}

extension AppFontsExtension on BuildContext {
  TextStyle _text(double size) =>
      Theme.of(this).textTheme.bodyMedium!.copyWith(fontSize: size);

  TextStyle get font32 => _text(AppFonts.size32);
  TextStyle get font24 => _text(AppFonts.size24);
  TextStyle get font20 => _text(AppFonts.size20);
  TextStyle get font18 => _text(AppFonts.size18);
  TextStyle get font16 => _text(AppFonts.size16);
  TextStyle get font14 => _text(AppFonts.size14);
  TextStyle get font12 => _text(AppFonts.size12);
  TextStyle get font10 => _text(AppFonts.size10);

  TextStyle get heading => font24.bold;
  TextStyle get title => font18.semiBold;
  TextStyle get body => font16;
  TextStyle get subBody => font14;
  TextStyle get caption => font12;
  TextStyle get overline => font10;
}

extension TextStyleWeightExtension on TextStyle {
  TextStyle get bold => copyWith(fontWeight: FontWeight.bold);
  TextStyle get semiBold => copyWith(fontWeight: FontWeight.w600);
  TextStyle get medium => copyWith(fontWeight: FontWeight.w500);
  TextStyle get regular => copyWith(fontWeight: FontWeight.normal);
}
