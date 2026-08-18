import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/responsive_helper.dart';
import '../utils/api_service.dart';
import '../utils/app_config.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _rememberMe = false;
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSavedEmail();
  }

  Future<void> _loadSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('saved_email') ?? '';
    if (saved.isNotEmpty) {
      setState(() {
        _emailCtrl.text = saved;
        _rememberMe = true;
      });
    }
  }

  Future<void> _doLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final result = await ApiService.login(email: _emailCtrl.text.trim(), password: _passwordCtrl.text);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', result['token'] as String);
      await prefs.setString('user_name', result['user']['name']?.toString() ?? '');
      await prefs.setString('user_role', result['user']['role']?.toString() ?? '');
      if (_rememberMe) { await prefs.setString('saved_email', _emailCtrl.text.trim()); }
      else { await prefs.remove('saved_email'); }
      AppConfig.cashierName = result['user']['name']?.toString() ?? '';
      if (mounted) Navigator.pushReplacementNamed(context, '/dashboard');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: const Color(0xFFB71C1C),
          behavior: SnackBarBehavior.floating,
        ));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: r.space(320),
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFD32F2F), Color(0xFFB71C1C)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(80)),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)]),
                      child: Image.asset(AppConfig.storeLogo, height: r.space(80), width: r.space(80)),
                    ),
                    const SizedBox(height: 20),
                    Text(AppConfig.storeName, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900, fontFamily: 'Inter')),
                    const Text('Sistem POS Terpadu', style: TextStyle(color: Colors.white70, fontSize: 14, fontFamily: 'Inter')),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 40, 30, 30),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Login Akun', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, fontFamily: 'Inter')),
                    const SizedBox(height: 30),
                    TextFormField(
                      controller: _emailCtrl,
                      decoration: _inputStyle('Email', Icons.email_outlined),
                      validator: (v) => (v == null || !v.contains('@')) ? 'Email tidak valid' : null,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _passwordCtrl,
                      obscureText: _obscurePassword,
                      decoration: _inputStyle('Password', Icons.lock_outline_rounded).copyWith(
                        suffixIcon: IconButton(icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off), onPressed: () => setState(() => _obscurePassword = !_obscurePassword)),
                      ),
                      validator: (v) => (v == null || v.isEmpty) ? 'Password wajib diisi' : null,
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Checkbox(value: _rememberMe, activeColor: const Color(0xFFC62828), onChanged: (v) => setState(() => _rememberMe = v ?? false)),
                        const Text('Ingat Saya', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _doLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC62828),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 4,
                        ),
                        child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('LOGIN SEKARANG', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputStyle(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFFC62828)),
      filled: true,
      fillColor: const Color(0xFFF5F5F7),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFC62828), width: 1.5)),
    );
  }
}
