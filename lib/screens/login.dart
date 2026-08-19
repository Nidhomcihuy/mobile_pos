import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
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
      final result = await ApiService.login(email: _emailCtrl.text.trim(), password: _passwordCtrl.text.trim());
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
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: r.space(32)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: r.space(80)),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white, 
                    borderRadius: BorderRadius.circular(32), 
                    boxShadow: [
                      BoxShadow(color: const Color(0xFFC62828).withOpacity(0.1), blurRadius: 30, offset: const Offset(0, 10))
                    ]
                  ),
                  child: Image.asset(AppConfig.storeLogo, height: r.space(70), width: r.space(70)),
                ),
              ),
              SizedBox(height: r.space(40)),
              Center(
                child: Column(
                  children: [
                    Text(AppConfig.storeName, style: TextStyle(color: const Color(0xFF0F172A), fontSize: r.font(28), fontWeight: FontWeight.w900, fontFamily: 'Inter')),
                    const SizedBox(height: 8),
                    Text('Sistem POS Terpadu', style: TextStyle(color: const Color(0xFF64748B), fontSize: r.font(14), fontWeight: FontWeight.w500, fontFamily: 'Inter')),
                  ],
                ),
              ),
              SizedBox(height: r.space(50)),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Login Akun', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, fontFamily: 'Inter', color: Color(0xFF1E293B))),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _emailCtrl,
                      style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                      decoration: _inputStyle('Email', CupertinoIcons.mail),
                      validator: (v) => (v == null || !v.contains('@')) ? 'Email tidak valid' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordCtrl,
                      obscureText: _obscurePassword,
                      style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                      decoration: _inputStyle('Password', CupertinoIcons.lock).copyWith(
                        suffixIcon: IconButton(icon: Icon(_obscurePassword ? CupertinoIcons.eye : CupertinoIcons.eye_slash, color: const Color(0xFF94A3B8)), onPressed: () => setState(() => _obscurePassword = !_obscurePassword)),
                      ),
                      validator: (v) => (v == null || v.isEmpty) ? 'Password wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        SizedBox(
                          height: 24,
                          width: 24,
                          child: Checkbox(
                            value: _rememberMe, 
                            activeColor: const Color(0xFFC62828), 
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
                            onChanged: (v) => setState(() => _rememberMe = v ?? false)
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text('Ingat Saya', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600, fontFamily: 'Inter')),
                      ],
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _doLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC62828),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: _isLoading 
                          ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)) 
                          : const Text('LOGIN SEKARANG', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, fontFamily: 'Inter', letterSpacing: 1)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputStyle(String label, IconData icon) {
    return InputDecoration(
      hintText: label,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w500),
      prefixIcon: Icon(icon, color: const Color(0xFFC62828)),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFF1F5F9), width: 2)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFC62828), width: 2)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
    );
  }
}
