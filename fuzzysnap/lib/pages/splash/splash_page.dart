import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fuzzysnap/auth/auth_page.dart';
import 'package:fuzzysnap/pages/splash/welcome_page.dart';
import 'package:fuzzysnap/provider/provider.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../app/dimensions.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    // _loadResource();
    controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..forward();

    animation = CurvedAnimation(parent: controller, curve: Curves.linear);
    Timer(const Duration(seconds: 3),
        () => Navigator.pushReplacementNamed(context, '/auth_page'));
  }

  // animation logo
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body:
          Consumer<UiProvider>(builder: (context, UiProvider notifier, child) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: animation,
              child: Center(
                  child: Image.asset(notifier.isDark ?
                "assets/images/logo_white.png" : "assets/images/logo.png",
                width: 180,
              )),
            ),
            Center(
                child: Image.asset(
              "assets/images/logo2.png",
              width: 180,
            )),
          ],
        );
      }),
    );
  }
}
