import 'package:cloud_otp/utils/constants.dart';
import 'package:flutter/material.dart';
import 'settings_page.dart';
import 'list_view_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});



  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {


  // final dynamic userData;

  int _selectedIndex = 0;

  late List<Widget> _widgetOptions;

  // _MainPageState({required this.userData});

  @override
  void initState() {
    super.initState();
    StatelessWidget settingsPage = const EmptySettingsPage();
    if(!isGuest){
      settingsPage = SettingsPage();
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
      appBar: AppBar(
        title: const Text('Cloud OTP'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              logout(context);
            },
          ),
        ],
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
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