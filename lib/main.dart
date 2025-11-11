import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'models/password.dart';

void main() {
  runApp(PasswordManagerApp());
}

class PasswordManagerApp extends StatelessWidget {
  const PasswordManagerApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Password Manager', home: PasswordListScreen());
  }
}

class PasswordListScreen extends StatefulWidget {
  const PasswordListScreen({super.key});
  @override
  State<PasswordListScreen> createState() => _PasswordListScreenState();
}

class _PasswordListScreenState extends State<PasswordListScreen> {
  final dbHelper = DatabaseHelper();
  List<Password> passwords = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Password List')),
      body: Center(child: Text('Total Passwords; ${passwords.length}')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrUpdatePassword(),
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _refreshPasswordList();
  }

  void _refreshPasswordList() async {
    final data = await dbHelper.getPasswords();
    setState(() {
      passwords = data;
    });
  }

  void _addOrUpdatePassword({Password? passwords}) {
    final titleController = TextEditingController(text: passwords?.title);
    final usernameController = TextEditingController(text: passwords?.username);
    final passwordController = TextEditingController(text: passwords?.password);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(passwords == null ? 'Tambah Password' : 'Edit Password'),
        // Perbaikan di sini: Tambahkan SingleChildScrollView dan Padding
        content: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: usernameController,
                  decoration: InputDecoration(labelText: 'Username'),
                ),
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(labelText: 'Password'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              // Baris yang diawali dengan 'onPressed: () async {'
              final newPassword = Password(
                id: passwords?.id,
                title: titleController.text,
                username: usernameController.text,
                password: passwordController.text,
              );
              if (passwords == null) {
                await dbHelper.insertPassword(newPassword);
              } else {
                await dbHelper.updatePassword(newPassword);
              }
              _refreshPasswordList();
              // >>> Perbaikan di sini <<<
              if (mounted) {
                Navigator.of(context).pop();
              }
            },
            child: Text(passwords == null ? 'Tambah' : 'Simpan'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Batal'),
          ),
        ],
      ),
    );
  }
}
