import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../home_screen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final username = _usernameController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      // Створення користувача
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Збереження додаткових даних у Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'username': username,
        'email': email,
        'uid': userCredential.user!.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Відправлення листа для підтвердження
      await userCredential.user!.sendEmailVerification();

      // Показати діалог успішної реєстрації
      _showSuccessDialog(context);
      
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
    } on FirebaseException catch (e) {
      _handleFirestoreError(e);
    } catch (e) {
      _handleGenericError(e);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _handleAuthError(FirebaseAuthException e) {
    setState(() {
      _errorMessage = _getAuthError(e.code);
    });
    _showErrorDialog(context, _errorMessage!);
  }

  void _handleFirestoreError(FirebaseException e) {
    setState(() {
      _errorMessage = 'Помилка збереження даних: ${e.message}';
    });
    _showErrorDialog(context, _errorMessage!);
  }

  void _handleGenericError(dynamic e) {
    setState(() {
      _errorMessage = 'Сталася невідома помилка';
    });
    debugPrint('Error: ${e.toString()}');
    _showErrorDialog(context, _errorMessage!);
  }

  String _getAuthError(String code) {
    switch (code) {
      case 'invalid-email': return 'Невірний формат email';
      case 'user-disabled': return 'Користувач заблокований';
      case 'user-not-found': return 'Користувача не знайдено';
      case 'wrong-password': return 'Невірний пароль';
      case 'email-already-in-use': return 'Цей email вже зареєстрований';
      case 'weak-password': return 'Пароль має містити щонайменше 6 символів';
      case 'operation-not-allowed': return 'Ця операція заборонена';
      default: return 'Помилка автентифікації: $code';
    }
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text("Реєстрація успішна"),
        content: Text(
          "Будь ласка, перевірте вашу електронну пошту для підтвердження реєстрації.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
            },
            child: Text("ОК"),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Помилка реєстрації"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Закрити"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Зареєструватися")),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Ім\'я користувача',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value!.isEmpty ? 'Введіть ім\'я користувача' : null,
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Електронна пошта',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => value!.isEmpty 
                      ? 'Введіть email' 
                      : !value.contains('@') 
                          ? 'Невірний формат email' 
                          : null,
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Пароль',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) => value!.length < 6 
                      ? 'Пароль має містити щонайменше 6 символів' 
                      : null,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  child: _isLoading
                      ? CircularProgressIndicator()
                      : Text('Зареєструватися'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50)),
                ),
                if (_errorMessage != null) ...[
                  SizedBox(height: 20),
                  Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}