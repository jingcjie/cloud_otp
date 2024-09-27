import 'package:cloud_otp/utils/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'settings_page.dart';
import 'list_view_page.dart';
import 'package:cloud_otp/models/snackbar.dart';

class MainPage extends StatefulWidget {
  final VoidCallback onLogoutCallback;

  const MainPage({super.key, required this.onLogoutCallback});


  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {

  int _selectedIndex = 0;
  late List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    StatelessWidget settingsPage = EmptySettingsPage(onLogoutCallback: widget.onLogoutCallback);
    if(!isGuest){
      settingsPage = SettingsPage(onLogoutCallback: widget.onLogoutCallback);
    }

    _widgetOptions = <Widget>[
      ListViewPage(),
      settingsPage,
    ];
  }
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'List',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

}
