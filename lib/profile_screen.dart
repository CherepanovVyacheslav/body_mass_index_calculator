import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'bmi_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Состояние загрузки
  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _history = [];

  // Данные пользователя
  String _userName = '';
  String _userEmail = '';

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadHistory();
  }

  // --- Данные пользователя из Supabase Auth ---
  void _loadUserInfo() {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    final email = user.email ?? '';
    final metadata = user.userMetadata ?? {};

    // 1. Пробуем display_name (стандартное поле Display Name в Supabase Auth)
    String displayName = (metadata['display_name'] ?? '').toString().trim();

    // 2. Если пусто — собираем из name + surname (как вы передавали при регистрации)
    if (displayName.isEmpty) {
      final name = (metadata['name'] ?? '').toString().trim();
      final surname = (metadata['surname'] ?? '').toString().trim();
      displayName = [surname, name].where((s) => s.isNotEmpty).join(' ').trim();
      // ↑ surname первый — формат "Фамилия Имя" (Иванов Иван)
    }

    // 3. Если всё ещё пусто — берём часть email до @
    if (displayName.isEmpty && email.isNotEmpty) {
      displayName = email.split('@').first;
    }

    setState(() {
      _userEmail = email;
      _userName = displayName;
    });
  }

  // --- Асинхронная загрузка истории из Supabase ---
  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('Пользователь не авторизован');
      }

      final data = await _supabase
          .from('body_mass_index_calculations')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      if (!mounted) return;

      setState(() {
        _history = List<Map<String, dynamic>>.from(data as List);
        _isLoading = false;
      });
    } on PostgrestException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Не удалось загрузить: ${e.message}';
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Ошибка загрузки: $e';
        _isLoading = false;
      });
    }
  }

  // --- Форматирование даты из ISO-строки created_at ---
  String _formatDate(String isoString) {
    try {
      final dt = DateTime.parse(isoString).toLocal();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final itemDay = DateTime(dt.year, dt.month, dt.day);
      final yesterday = today.subtract(const Duration(days: 1));

      String dayLabel;
      if (itemDay == today) {
        dayLabel = 'Сегодня';
      } else if (itemDay == yesterday) {
        dayLabel = 'Вчера';
      } else {
        dayLabel =
            '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
      }

      final time =
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      return '$dayLabel, $time';
    } catch (_) {
      return isoString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // --- Карточка пользователя (верхняя) ---
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 10.0,
              ),
              padding: const EdgeInsets.symmetric(vertical: 25.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Аватарка с зелёным контуром
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF4CAF50),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.flutter_dash,
                      size: 50,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                  const SizedBox(height: 15),
                  // Фамилия Имя (Display Name из Auth)
                  Text(
                    _userName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 5),
                  // Email
                  Text(
                    _userEmail,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),

            // --- Карточка "Активность" ---
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              padding: const EdgeInsets.symmetric(
                vertical: 12.0,
                horizontal: 16.0,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Активность',
                  style: TextStyle(
                    color: Color(0xFF4CAF50),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // --- Список карточек из таблицы ---
            Expanded(child: _buildHistoryList()),
          ],
        ),
      ),
      // --- Нижняя панель (Footer) ---
      bottomNavigationBar: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Кнопка Калькулятор
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const BmiScreen()),
                );
              },
              child: const Text(
                'Калькулятор',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ),
            // Кнопка Профиль
            TextButton(
              onPressed: () {
                // Остаёмся на этой странице
              },
              child: const Text(
                'Профиль',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Построение списка карточек ---
  Widget _buildHistoryList() {
    // 1. Загрузка
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF4CAF50)),
      );
    }

    // 2. Ошибка
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontSize: 13),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _loadHistory,
                child: const Text(
                  'Повторить',
                  style: TextStyle(
                    color: Color(0xFF4CAF50),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 3. Нет ни одной записи у текущего пользователя — никаких карточек
    if (_history.isEmpty) {
      return const SizedBox.shrink();
    }

    // 4. Карточек ровно столько, сколько записей в таблице
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: _history.length,
      itemBuilder: (context, index) {
        final item = _history[index];

        // Безопасное извлечение числовых значений
        final double bmiValue = (item['body_mass_index'] is num)
            ? (item['body_mass_index'] as num).toDouble()
            : 0.0;

        return Container(
          margin: const EdgeInsets.only(bottom: 15.0),
          padding: const EdgeInsets.all(15.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Время расчёта',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Text(
                _formatDate(item['created_at'].toString()),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoColumn('Рост', '${item['height'] ?? 0}'),
                  _buildInfoColumn('Вес', '${item['weight'] ?? 0}'),
                  _buildInfoColumn(
                    'Индекс массы тела',
                    bmiValue.toStringAsFixed(2),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'Рекомендация',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Text(
                (item['recommendation'] ?? '').toString(),
                style: const TextStyle(fontSize: 12, color: Colors.black),
              ),
            ],
          ),
        );
      },
    );
  }

  // Вспомогательный метод для отображения данных в строку
  Widget _buildInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
