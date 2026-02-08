import 'package:flutter/material.dart';
import '../helpers/database_helper.dart';
import '../models/password_entry.dart';

class PasswordFormScreen extends StatefulWidget {
  final PasswordEntry? entry;

  const PasswordFormScreen({super.key, this.entry});

  @override
  State<PasswordFormScreen> createState() => _PasswordFormScreenState();
}

class _PasswordFormScreenState extends State<PasswordFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _appNameController = TextEditingController();
  final _appLinkController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isSaving = false;

  bool get _isEditing => widget.entry != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _appNameController.text = widget.entry!.appName;
      _appLinkController.text = widget.entry!.appLink;
      _usernameController.text = widget.entry!.username;
      _passwordController.text = widget.entry!.password;
    }
  }

  @override
  void dispose() {
    _appNameController.dispose();
    _appLinkController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _savePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final entry = PasswordEntry(
        id: widget.entry?.id,
        appName: _appNameController.text.trim(),
        appLink: _appLinkController.text.trim(),
        username: _usernameController.text.trim(),
        password: _passwordController.text,
        createdAt: widget.entry?.createdAt,
        updatedAt: DateTime.now(),
      );

      if (_isEditing) {
        await DatabaseHelper.instance.updatePassword(entry);
      } else {
        await DatabaseHelper.instance.insertPassword(entry);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? 'Password berhasil diupdate'
                  : 'Password berhasil disimpan',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Password' : 'Tambah Password'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(
                controller: _appNameController,
                label: 'Nama Aplikasi',
                hint: 'Contoh: Gmail, Instagram, Facebook',
                icon: Icons.apps,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama aplikasi harus diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _appLinkController,
                label: 'Link Aplikasi',
                hint: 'Contoh: https://mail.google.com',
                icon: Icons.link,
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _usernameController,
                label: 'Username / Email',
                hint: 'Masukkan username atau email',
                icon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Username harus diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _passwordController,
                label: 'Password',
                hint: 'Masukkan password',
                icon: Icons.lock_outline,
                obscureText: !_isPasswordVisible,
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password harus diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _isSaving ? null : _savePassword,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        _isEditing ? 'Update Password' : 'Simpan Password',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }
}
