import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // Tambahan untuk cek web
import 'package:sqflite/sqflite.dart'; // Digunakan untuk databaseFactory
// Pastikan Anda sudah menambahkan sqflite_common_ffi_web ke pubspec.yaml jika target web.
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'database_helper.dart';
import 'models/password.dart';

void main() {
  // Wajib dipanggil untuk memastikan binding widget siap
  WidgetsFlutterBinding.ensureInitialized();

  // FIX UNTUK WEB: Mengatasi masalah inisialisasi sqflite di Flutter Web.
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }

  runApp(const PasswordManagerApp()); // Mengubah ke const
}

class PasswordManagerApp extends StatelessWidget {
  const PasswordManagerApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Password Manager',
      home: PasswordListScreen(),
    ); // Mengubah ke const
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

  // Fungsi untuk menghapus password
  void _deletePassword(int id) async {
    await dbHelper.deletePassword(id);
    _refreshPasswordList();
  }

  // Dialog Tambah/Edit Password (Dibuat terpisah agar lebih bersih)
  void _addOrUpdatePassword({Password? passwordToEdit}) {
    final titleController = TextEditingController(text: passwordToEdit?.title);
    final usernameController = TextEditingController(
      text: passwordToEdit?.username,
    );
    final passwordController = TextEditingController(
      text: passwordToEdit?.password,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Gunakan BuildContext dari builder
        return AlertDialog(
          title: Text(
            passwordToEdit == null ? 'Tambah Password' : 'Edit Password',
          ),
          content: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                  ),
                  TextField(
                    controller: usernameController,
                    decoration: const InputDecoration(labelText: 'Username'),
                  ),
                  TextField(
                    controller: passwordController,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true, // Opsional: Sembunyikan password
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              // Mengganti ElevatedButton pertama dengan TextButton agar konsisten dengan dialog modern
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              // lib/main.dart (Hanya perubahan pada fungsi _addOrUpdatePassword di onPressed)
              onPressed: () async {
                final newPassword = Password(
                  id: passwordToEdit?.id,
                  title: titleController.text,
                  username: usernameController.text,
                  password: passwordController.text,
                );

                if (passwordToEdit == null) {
                  await dbHelper.insertPassword(newPassword);
                } else {
                  await dbHelper.updatePassword(newPassword);
                }

                // Setelah operasi async selesai, periksa apakah widget ini masih terpasang.
                if (!mounted) return; // FIX DITAMBAHKAN DI SINI

                _refreshPasswordList();
              },
              child: Text(passwordToEdit == null ? 'Tambah' : 'Simpan'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Password Manager'),
        backgroundColor: Theme.of(
          context,
        ).colorScheme.inversePrimary, // Memastikan AppBar memiliki warna
      ),
      // MENGGANTI BAGIAN BODY DENGAN TAMPILAN DAFTAR
      body: ListView.builder(
        itemCount: passwords.length,
        itemBuilder: (context, index) {
          final password = passwords[index];
          return ListTile(
            // Tampilan utama
            title: Text(password.title),
            subtitle: Text(password.username),

            // Tombol edit dan hapus di sisi kanan (sesuai lampiran)
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Tombol Edit (Ikon Pensil)
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: () =>
                      _addOrUpdatePassword(passwordToEdit: password),
                ),
                // Tombol Hapus (Ikon Sampah)
                IconButton(
                  icon: const Icon(Icons.delete, size: 20),
                  onPressed: () => _deletePassword(password.id!),
                ),
              ],
            ),
            // Opsional: Jika diklik, buka dialog edit juga
            onTap: () => _addOrUpdatePassword(passwordToEdit: password),
          );
        },
      ),
      // Floating Action Button
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            _addOrUpdatePassword(), // Membuka dialog untuk menambah
        child: const Icon(Icons.add),
      ),
    );
  }
}
