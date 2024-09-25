import 'package:cloud_otp/utils/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'settings_page.dart';
import 'list_view_page.dart';

class MainPage extends StatefulWidget {
  final VoidCallback onLogoutCallback;

  const MainPage({super.key, required this.onLogoutCallback});


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
        // child: Column(
        //   children: [
        //     if (!kIsWeb)
        //       Align(
        //         alignment: Alignment.topRight,
        //         child: IconButton(
        //           icon: const Icon(Icons.exit_to_app_rounded),
        //           onPressed: () {
        //             if (kIsWIN || kIsAnd || kIsLIN) {
        //               exit(0);
        //             } else {
        //               ScaffoldMessenger.of(context).showSnackBar(
        //                 const SnackBar(content: Text('Close App option is only supported for Windows, Android and Linux platforms.')),
        //               );
        //             }
        //           },
        //         ),
        //       ),
        //     Expanded(
        //       child: Center(
        //         child: _widgetOptions.elementAt(_selectedIndex),
        //       ),
        //     ),
        //   ],
        // ),
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

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: const Text('Cloud OTP'),
  //       actions: [
  //         IconButton(
  //           icon: const Icon(Icons.exit_to_app_rounded),
  //           onPressed: () {
  //             if(!kIsWeb){
  //               exit(0);
  //             }else{
  //               ScaffoldMessenger.of(context).showSnackBar(
  //                 const SnackBar(content: Text('Close App option is only supported for Windows, Android and Linux platform. Web users can just close the page.')),
  //               );
  //             }
  //           },
  //         ),
  //       ],
  //     ),
  //     body: Center(
  //       child: _widgetOptions.elementAt(_selectedIndex),
  //     ),
  //     bottomNavigationBar: BottomNavigationBar(
  //       items: const <BottomNavigationBarItem>[
  //         BottomNavigationBarItem(
  //           icon: Icon(Icons.list),
  //           label: 'List',
  //         ),
  //         BottomNavigationBarItem(
  //           icon: Icon(Icons.settings),
  //           label: 'Settings',
  //         ),
  //       ],
  //       currentIndex: _selectedIndex,
  //       onTap: _onItemTapped,
  //     ),
  //   );
  // }

}
