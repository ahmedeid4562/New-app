import 'package:flutter/material.dart';

class AppTheme {
static const Color primaryColor = Color(0xff1976D2);

static const Color backgroundColor = Color(0xff181818);
static const Color cardColor = Color(0xff242424);

static ThemeData get darkTheme {
return ThemeData(
brightness: Brightness.dark,
primaryColor: primaryColor,
scaffoldBackgroundColor: backgroundColor,
cardColor: cardColor,
colorScheme: const ColorScheme.dark(
primary: primaryColor,
surface: backgroundColor,
),
appBarTheme: const AppBarTheme(
backgroundColor: backgroundColor,
foregroundColor: Colors.white,
elevation: 0,
),
switchTheme: SwitchThemeData(
thumbColor: WidgetStateProperty.resolveWith((states) {
if (states.contains(WidgetState.selected)) {
return primaryColor;
}
return Colors.grey;
}),
),
);
}

static ThemeData get lightTheme {
return ThemeData(
brightness: Brightness.light,
primaryColor: primaryColor,
scaffoldBackgroundColor: const Color(0xffF5F7FB),
cardColor: Colors.white,
colorScheme: const ColorScheme.light(
primary: primaryColor,
surface: Color(0xffF5F7FB),
),
appBarTheme: const AppBarTheme(
backgroundColor: Color(0xffF5F7FB),
foregroundColor: Colors.black87,
elevation: 0,
),
switchTheme: SwitchThemeData(
thumbColor: WidgetStateProperty.resolveWith((states) {
if (states.contains(WidgetState.selected)) {
return primaryColor;
}
return Colors.grey;
}),
),
);
}
}
