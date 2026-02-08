import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../helpers/database_helper.dart';
import '../models/password_entry.dart';
import 'password_form_screen.dart';

class PasswordListScreen extends StatefulWidget {
  const PasswordListScreen({super.key});

  @override
  State<PasswordListScreen> createState() => _PasswordListScreenState();
}

class _PasswordListScreenState extends State<PasswordListScreen> {
  List<PasswordEntry> _passwords = [];
  bool _isLoading = true;
  final Map<int, bool> _visiblePasswords = {};

  @override
  void initState() {
    super.initState();
    _loadPasswords();
  }

  Future<void> _loadPasswords() async {
    setState(() => _isLoading = true);
    final passwords = await DatabaseHelper.instance.getAllPasswords();
    setState(() {
      _passwords = passwords;
      _isLoading = false;
    });
  }

  void _togglePasswordVisibility(int id) {
    setState(() {
      _visiblePasswords[id] = !(_visiblePasswords[id] ?? false);
    });
  }

  Future<void> _deletePassword(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Password'),
        content: const Text('Apakah Anda yakin ingin menghapus password ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DatabaseHelper.instance.deletePassword(id);
      _loadPasswords();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label disalin ke clipboard'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Password Manager'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 2,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _passwords.isEmpty
              ? _buildEmptyState()
              : _buildPasswordList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) => const PasswordFormScreen(),
            ),
          );
          if (result == true) {
            _loadPasswords();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lock_outline,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada password tersimpan',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap tombol + untuk menambah password baru',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordList() {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: _passwords.length,
      itemBuilder: (context, index) {
        final entry = _passwords[index];
        final isVisible = _visiblePasswords[entry.id] ?? false;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 2,
          child: InkWell(
            onTap: () async {
              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (context) => PasswordFormScreen(entry: entry),
                ),
              );
              if (result == true) {
                _loadPasswords();
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.apps,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.appName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (entry.appLink.isNotEmpty)
                              Text(
                                entry.appLink,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => _deletePassword(entry.id!),
                        icon: const Icon(Icons.delete_outline),
                        color: Colors.red[400],
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  _buildInfoRow(
                    'Username',
                    entry.username,
                    Icons.person_outline,
                    onCopy: () => _copyToClipboard(entry.username, 'Username'),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    'Password',
                    isVisible ? entry.password : '••••••••',
                    Icons.lock_outline,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            isVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                            size: 20,
                          ),
                          onPressed: () => _togglePasswordVisibility(entry.id!),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.copy, size: 20),
                          onPressed: () =>
                              _copyToClipboard(entry.password, 'Password'),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    IconData icon, {
    VoidCallback? onCopy,
    Widget? trailing,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        const Spacer(),
        if (trailing != null)
          trailing
        else if (onCopy != null)
          IconButton(
            icon: const Icon(Icons.copy, size: 20),
            onPressed: onCopy,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
      ],
    );
  }
}
