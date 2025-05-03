import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _secureStorage = FlutterSecureStorage();
  
  List<String> _savedAccounts = [];
  bool _isLoading = false;
  bool _rememberMe = false;
  bool _showRegistration = false;
  final _registerFormKey = GlobalKey<FormState>();
  final _registerEmailController = TextEditingController();
  final _registerPasswordController = TextEditingController();
  final _registerConfirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavedAccounts();
    _checkAutoLogin();
  }

  Future<void> _checkAutoLogin() async {
    try {
      final lastEmail = await _secureStorage.read(key: 'last_email');
      if (lastEmail != null && mounted) {
        setState(() {
          _emailController.text = lastEmail;
          _rememberMe = true;
        });
      }
    } catch (e) {
      print('Помилка при перевірці автовходу: $e');
    }
  }

  Future<void> _loadSavedAccounts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (mounted) {
        setState(() => _savedAccounts = prefs.getStringList('saved_accounts') ?? []);
      }
    } catch (e) {
      print('Помилка завантаження акаунтів: $e');
    }
  }

  Future<void> _saveAccount(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!_savedAccounts.contains(email)) {
        _savedAccounts.add(email);
        await prefs.setStringList('saved_accounts', _savedAccounts);
      }
      
      if (_rememberMe) {
        await _secureStorage.write(key: 'last_email', value: email);
      } else {
        await _secureStorage.delete(key: 'last_email');
      }
    } catch (e) {
      print('Помилка збереження акаунта: $e');
    }
  }

  Future<void> _quickLogin(String email) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _emailController.text = email;
    });
    
    try {
      await _login();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) return;

    setState(() => _isLoading = true);
    
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      
      await _saveAccount(_emailController.text.trim());
      if (mounted) Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Помилка входу')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _register() async {
    if (!_registerFormKey.currentState!.validate()) return;
    if (_registerPasswordController.text != _registerConfirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Паролі не співпадають')),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      await _auth.createUserWithEmailAndPassword(
        email: _registerEmailController.text.trim(),
        password: _registerPasswordController.text.trim(),
      );
      
      await _saveAccount(_registerEmailController.text.trim());
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Помилка реєстрації')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _toggleRegistration() {
    setState(() => _showRegistration = !_showRegistration);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_showRegistration ? 'Реєстрація' : 'Вхід')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: _showRegistration ? _buildRegistrationForm() : _buildLoginForm(),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      children: [
        if (_savedAccounts.isNotEmpty) ...[
          Text('Останні акаунти', style: TextStyle(fontSize: 16)),
          SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: _savedAccounts.map((email) => GestureDetector(
              onTap: () => _quickLogin(email),
              child: Chip(
                label: Text(email),
                deleteIcon: Icon(Icons.close, size: 18),
                onDeleted: () async {
                  final prefs = await SharedPreferences.getInstance();
                  _savedAccounts.remove(email);
                  await prefs.setStringList('saved_accounts', _savedAccounts);
                  await _secureStorage.delete(key: 'last_email');
                  if (mounted) setState(() {});
                },
              ),
            )).toList(),
          ),
          Divider(height: 30),
        ],
        TextField(
          controller: _emailController,
          decoration: InputDecoration(labelText: 'Email'),
          keyboardType: TextInputType.emailAddress,
        ),
        SizedBox(height: 20),
        TextField(
          controller: _passwordController,
          decoration: InputDecoration(labelText: 'Пароль'),
          obscureText: true,
        ),
        CheckboxListTile(
          title: Text('Запам\'ятати мене'),
          value: _rememberMe,
          onChanged: (value) => setState(() => _rememberMe = value ?? false),
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
        ),
        SizedBox(height: 30),
        if (_isLoading)
          CircularProgressIndicator()
        else
          Column(
            children: [
              ElevatedButton(
                onPressed: _login,
                child: Text('Увійти'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
              TextButton(
                onPressed: _toggleRegistration,
                child: Text('Немає акаунта? Зареєструватись'),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildRegistrationForm() {
    return Form(
      key: _registerFormKey,
      child: Column(
        children: [
          // Поле для email
          TextFormField(
            controller: _registerEmailController,
            decoration: InputDecoration(
              labelText: 'Email',
              hintText: 'Введіть ваш email',
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) => value!.isEmpty ? 'Будь ласка, введіть email' : null,
          ),

          SizedBox(height: 20), // Роздільник між полями

          // Поле для пароля
          TextFormField(
            controller: _registerPasswordController,
            decoration: InputDecoration(
              labelText: 'Пароль',
              hintText: 'Введіть пароль (мінімум 6 символів)',
            ),
            obscureText: true,
            validator: (value) {
              if (value!.isEmpty) return 'Будь ласка, введіть пароль';
              if (value.length < 6) return 'Пароль має містити щонайменше 6 символів';
              return null;
            },
          ),

          SizedBox(height: 20), // Роздільник між полями

          // Поле для підтвердження пароля
          TextFormField(
            controller: _registerConfirmPasswordController,
            decoration: InputDecoration(
              labelText: 'Підтвердіть пароль',
              hintText: 'Введіть пароль ще раз',
            ),
            obscureText: true,
            validator: (value) {
              if (value!.isEmpty) return 'Будь ласка, підтвердіть пароль';
              if (value != _registerPasswordController.text) {
                return 'Паролі не співпадають';
              }
              return null;
            },
          ),

          SizedBox(height: 30), // Відступ перед кнопкою

          // Кнопка реєстрації
          ElevatedButton(
            onPressed: _register,
            child: Text('Зареєструватися'),
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, 50),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    _registerConfirmPasswordController.dispose();
    super.dispose();
  }
}