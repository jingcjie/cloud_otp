import 'package:cloud_otp/utils/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:cloud_otp/models/theme_provider.dart';

class EmptySettingsPage extends StatelessWidget {

  final VoidCallback onLogoutCallback;
  const EmptySettingsPage({super.key, required this.onLogoutCallback});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: isGuest
                  ? kIsWeb?
                const Text(
                  'Data is stored locally, log in to enable cloud backup. \nFor web client, don\'t flush browser cache for this site, otherwise, you may loose data stored locally.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ):const Text(
                  'Data is stored locally, log in to enable cloud backup. ',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                )
                  : const Text('Settings content for logged-in users'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  onLogoutCallback();
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  elevation: 3,
                ),
                child: const Text(
                  'Log In',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final VoidCallback onLogoutCallback;
  SettingsPage({super.key, required this.onLogoutCallback});


  Future<void> _changePassword(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'New Password'),
            ),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Confirm New Password'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try{
                if (_newPasswordController.text != _confirmPasswordController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Passwords do not match')),
                  );
                  return;
                }
                await supabase.auth.updateUser(UserAttributes(
                    password: _newPasswordController.text
                ));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password changed successfully')),
                );
              }catch(e){
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Unexpected error: ${e.toString()}')),
                );
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  Future<void> _pullData(BuildContext context) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Pull Data'),
          content: const Text('This will overwrite the data in local storage. Are you sure you want to proceed?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('Proceed'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      // Perform the pull data operation
      try {
        var response = await supabase
            .from('user_data')
            .select()
            .maybeSingle();

        if (response['user_data'] != null) {
          var userData = response['user_data'];
          // Use the userData as needed
          otpUris = List.from(userData);
          await prefs.setStringList("otpUris", otpUris);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data pulled successfully')),
          );
        }
      }catch (e){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pull data, maybe there is no data in cloud. Error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _backupData(BuildContext context) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Backup Data'),
          content: const Text('This will overwrite the data in web storage. Are you sure you want to proceed?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('Proceed'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      // Perform the backup data operation
      var userData = List.from(otpUris); // Populate this with the user data to be backed up
      try {
        String id = supabase.auth.currentUser!.id;
        await supabase
            .from('user_data')
            .update({ 'user_data': userData })
            .eq('user_id', id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data backed up successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to backup data')),
        );
      }
    }
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete All Data in Cloud'),
        content: const Text('Are you sure you want to delete all data in cloud?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        String id = supabase.auth.currentUser!.id;
        await supabase
            .from('user_data')
            .update({ 'user_data': [] })
            .eq('user_id', id);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting data: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _logout(BuildContext context) async {
    final confirmed = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log out'),
        content: const Text('Do you want to delete all local data as well? Otherwise, you can still reach it using local mode!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(-1),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(0),
            child: const Text('Keep local data'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(1),
            child: const Text('Delete local data', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed !=-1) {
      try {
        await prefs.remove("loginUsername");
        await prefs.remove("loginPassword");
        supabase.auth.signOut();
        if (confirmed == 1){
          otpUris = [];
          await prefs.remove("otpUris");
          await prefs.setBool("isGuest", false);
        }

        onLogoutCallback();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return ListView(
          children: [
            _buildTopBanner(context),
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('Change Password'),
              onTap: () => _changePassword(context),
            ),
            ListTile(
              leading: const Icon(Icons.cloud_download),
              title: const Text('Pull Data'),
              onTap: () => _pullData(context),
            ),
            ListTile(
              leading: const Icon(Icons.backup),
              title: const Text('Backup Data'),
              onTap: () => _backupData(context),
            ),
            ListTile(
              leading: const Icon(Icons.brightness_medium),
              title: const Text('Theme Mode'),
              trailing: DropdownButton<ThemeMode>(
                value: themeProvider.themeMode,
                onChanged: (ThemeMode? newValue) {
                  if (newValue != null) {
                    themeProvider.setThemeMode(newValue);
                  }
                },
                items: const [
                  DropdownMenuItem(
                    value: ThemeMode.system,
                    child: Text('System'),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.light,
                    child: Text('Light'),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.dark,
                    child: Text('Dark'),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text('Delete All Cloud data', style: TextStyle(color: Colors.red)),
              onTap: () => _deleteAccount(context),
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () => _logout(context),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTopBanner(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).primaryColorLight,
            Theme.of(context).primaryColorDark.withOpacity(0.6),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 20,
            left: 20,
            child: Icon(
              Icons.account_circle,
              size: 80,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome,',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 16,
                  ),
                ),
                Text(
                  loginUsername, // Replace with actual username
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}