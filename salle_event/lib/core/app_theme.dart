import 'package:flutter/material.dart';
import '../core/colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: AppColors.primary,
      fontFamily: 'Roboto',
      scaffoldBackgroundColor: AppColors.primary,
    );
  }
}
