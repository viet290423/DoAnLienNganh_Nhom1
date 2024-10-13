import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UiProvider extends ChangeNotifier{

  bool _isDark = false;
  bool get isDark => _isDark;

  late SharedPreferences storage;

  //Custom dark theme
  final darkTheme = ThemeData(
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        // surface: Colors.black,
          primary:  Colors.grey[900]!,
          secondary: Colors.grey[850]!,
          onSecondary: Colors.white
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: Color(0xFF6D9886), // Màu cho CircularProgressIndicator
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.white),
      ),

  );

  //Custom light theme
  final lightTheme = ThemeData(
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        surface: Colors.white,
        primary:  Colors.white,
        secondary: Colors.grey[600]!,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
      )
  );

  //Now we want to save the last changed theme value


  //Dark mode toggle action
  changeTheme(){
    _isDark = !isDark;

    //Save the value to secure storage
    storage.setBool("isDark", _isDark);
    notifyListeners();
  }

  //Init method of provider
  init()async{
    //After we re run the app
    storage = await SharedPreferences.getInstance();
    _isDark = storage.getBool("isDark")??false;
    notifyListeners();
  }
}