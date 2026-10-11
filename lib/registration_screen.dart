import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  // Контроллеры с предустановленными значениями (оставлены как в оригинале)
  final TextEditingController _nameController = TextEditingController(
    text: 'Игорь',
  );
  final TextEditingController _surnameController = TextEditingController(
    text: 'Спирин',
  );
  final TextEditingController _emailController = TextEditingController(
    text: 'i_g_o_r_spirin@mail.ru',
  );
  final TextEditingController _passwordController = TextEditingController(
    text: '456321',
  );

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  // --- Регистрация пользователя в Supabase ---
  Future<void> _register() async {
    // Сброс сообщений
    setState(() {
      _errorMessage = null;
      _successMessage = null;
    });

    final name = _nameController.text.trim();
    final surname = _surnameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // Валидация
    if (name.isEmpty || surname.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Заполните все поля';
      });
      return;
    }
    if (password.length < 6) {
      setState(() {
        _errorMessage = 'Пароль должен содержать минимум 6 символов';
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final supabase = Supabase.instance.client;

      // Регистрация через Supabase Authentication
      final AuthResponse response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {'name': name, 'surname': surname},
      );

      if (response.user == null) {
        throw Exception('Не удалось создать пользователя');
      }

      setState(() {
        _successMessage = 'Аккаунт создан! Проверьте почту для подтверждения.';
      });

      // Небольшая задержка и возврат на экран входа
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) Navigator.pop(context);
    } on AuthException catch (e) {
      setState(() {
        _errorMessage = _translateAuthError(e.message);
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Ошибка регистрации: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Перевод частых ошибок Supabase на русский
  String _translateAuthError(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('already registered') ||
        lower.contains('user already exists')) {
      return 'Пользователь с таким email уже зарегистрирован';
    }
    if (lower.contains('invalid email')) {
      return 'Некорректный email';
    }
    if (lower.contains('password')) {
      return 'Пароль слишком простой или короткий';
    }
    return 'Ошибка: $message';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Заголовок "Регистрация"
                const Text(
                  'Регистрация',
                  style: TextStyle(
                    color: Color(0xFF4CAF50),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),

                // Карточка с полями
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Поле Имя
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Имя',
                          hintText: 'Введите ваше имя',
                          labelStyle: TextStyle(color: Colors.grey),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF4CAF50)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Поле Фамилия
                      TextField(
                        controller: _surnameController,
                        decoration: const InputDecoration(
                          labelText: 'Фамилия',
                          hintText: 'Введите вашу фамилию',
                          labelStyle: TextStyle(color: Colors.grey),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF4CAF50)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Поле Email
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          hintText: 'example@gmail.com',
                          labelStyle: TextStyle(color: Colors.grey),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF4CAF50)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Поле Пароль
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Пароль',
                          hintText: 'Введите пароль',
                          labelStyle: TextStyle(color: Colors.grey),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF4CAF50)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Кнопка "Вернуться к странице входа"
                      TextButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                Navigator.pop(context);
                              },
                        child: const Text(
                          'Вернуться к странице входа',
                          style: TextStyle(
                            color: Color(0xFF4CAF50),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Кнопка "СОЗДАТЬ АККАУНТ"
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(
                        0xFF4CAF50,
                      ).withValues(alpha: 0.6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text(
                            'СОЗДАТЬ АККАУНТ',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                // Сообщение об ошибке
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontSize: 13),
                    ),
                  ),

                // Сообщение об успехе
                if (_successMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      _successMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF4CAF50),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
