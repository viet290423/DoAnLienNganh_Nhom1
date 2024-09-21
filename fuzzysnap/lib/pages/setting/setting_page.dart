import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fuzzysnap/pages/setting/change_password_page.dart';
import 'package:fuzzysnap/provider/provider.dart';
import 'package:fuzzysnap/widget/setting_widget.dart';
import 'package:provider/provider.dart';

class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  // bool isDarkMode = false;
  bool isNotification = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        forceMaterialTransparency: true,
        // backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'SETTING',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Consumer<UiProvider>(
            builder: (context, UiProvider notifier, child) {
          return Column(
            children: [
              buildSettingSection(
                color: Theme.of(context).colorScheme.onPrimary,
                title: 'Account',
                children: [
                  buildSettingItem('Information', onTap: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(builder: (context) => InformationPage()),
                    // );
                  }),
                  buildSettingItem('Change Password', onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ChangePasswordPage()),
                    );
                  }),
                ],
              ),
              const SizedBox(height: 20),
              buildSettingSection(
                color: Theme.of(context).colorScheme.onPrimary,
                title: 'General',
                children: [
                  buildSettingItem(
                    'Language',
                    trailing: const Text('English'),
                    onTap: () {},
                  ),
                  buildSettingItem(
                    'Dark Mode',
                    trailing: Switch(
                        activeColor: Colors.deepPurple,
                        value: notifier.isDark,
                        onChanged: (value) => notifier.changeTheme()),
                    onTap: () {},
                  ),
                  buildSettingItem(
                    'Notification',
                    trailing: Switch(
                      activeColor: Colors.deepPurple,
                      value: isNotification,
                      onChanged: (bool value) {
                        setState(() {
                          isNotification = value;
                        });
                      },
                    ),
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 20),
              buildSettingSection(
                color: Theme.of(context).colorScheme.onPrimary,
                title: 'About us',
                children: [
                  buildSettingItem('Website', onTap: () {}),
                  buildSettingItem('Help', onTap: () {}),
                ],
              ),
              const SizedBox(height: 20),
              buildSettingSection(
                color: Theme.of(context).colorScheme.onPrimary,
                title: 'Red Zone',
                children: [
                  buildSettingItem(
                    'Log out',
                    trailing: const Icon(Icons.logout),
                    onTap: () {
                      Navigator.pop(context);

                      FirebaseAuth.instance.signOut();
                    },
                  ),
                  buildSettingItem(
                    'Delete account',
                    textColor: Colors.red,
                    onTap: () {
                      showDeleteAccountDialog(context);
                    },
                  ),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }

  void showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: Colors.white, // Đặt nền màu trắng
          title: const Center(
            child: Text(
              'Do you really want to delete your account?',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
              textAlign: TextAlign.center,
            ),
          ),
          actions: <Widget>[
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'No',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      FirebaseAuth.instance.signOut();
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Yes',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
