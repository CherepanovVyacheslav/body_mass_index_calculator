import 'package:flutter/material.dart';
import 'profile_screen.dart';
import 'bmi_storage.dart'; // Импортируем хранилище

class BmiScreen extends StatefulWidget {
  const BmiScreen({super.key});

  @override
  State<BmiScreen> createState() => _BmiScreenState();
}

class _BmiScreenState extends State<BmiScreen> {
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  double? _bmiResult;
  String _recommendation = '';
  bool _showError = false;

  void _calculateBmi() {
    double? height = double.tryParse(_heightController.text);
    double? weight = double.tryParse(_weightController.text);

    if (height == null || weight == null || height <= 0 || weight <= 0) {
      setState(() {
        _showError = true;
        _bmiResult = null;
      });
      return;
    }

    setState(() {
      _showError = false;
      double heightInMeters = height / 100;
      _bmiResult = weight / (heightInMeters * heightInMeters);

      // Логика рекомендаций
      if (_bmiResult! <= 16) {
        _recommendation =
            'Выраженный дефицит массы тела. Советуем набрать вес для здоровья.';
      } else if (_bmiResult! > 16 && _bmiResult! < 18.5) {
        _recommendation =
            'Недостаточная масса тела. Рекомендуется увеличить массу тела.';
      } else if (_bmiResult! >= 18.5 && _bmiResult! <= 24.99) {
        _recommendation =
            'Норма. Ваш вес в здоровом диапазоне — поддерживайте его!';
      } else if (_bmiResult! >= 25 && _bmiResult! < 30) {
        _recommendation =
            'Избыточная масса тела или предожирение. Желательно снизить вес для улучшения самочувствия.';
      } else if (_bmiResult! >= 30 && _bmiResult! < 35) {
        _recommendation =
            'Ожирение. Рекомендуется уменьшить вес под контролем специалиста.';
      } else if (_bmiResult! >= 35 && _bmiResult! < 40) {
        _recommendation =
            'Ожирение резкое. Необходимо снижение веса с медицинской поддержкой.';
      } else {
        _recommendation =
            'Очень резкое ожирение. Требуется срочная коррекция веса под наблюдением врача.';
      }

      // Сохраняем в историю через BmiStorage
      DateTime now = DateTime.now();
      String formattedDate =
          "${now.day}.${now.month}.${now.year}, ${now.hour}:${now.minute.toString().padLeft(2, '0')}";

      BmiStorage.history.insert(0, {
        'date': formattedDate,
        'height': height,
        'weight': weight,
        'bmi': _bmiResult,
        'recommendation': _recommendation,
      });
    });
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
                const Text(
                  'Индекс массы тела',
                  style: TextStyle(
                    color: Color(0xFF4CAF50),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),

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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Персональные данные',
                        style: TextStyle(
                          color: Color(0xFF4CAF50),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _heightController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Рост (см)',
                          hintText: '185',
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF4CAF50)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: _weightController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Вес (кг)',
                          hintText: '77',
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF4CAF50)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _calculateBmi,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: const Text(
                      'РАССЧИТАТЬ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                if (_showError)
                  const Padding(
                    padding: EdgeInsets.only(top: 16.0),
                    child: Text(
                      'Заполните все поля',
                      style: TextStyle(color: Colors.red, fontSize: 14),
                    ),
                  ),

                const SizedBox(height: 20),

                if (_bmiResult != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ваш индекс массы тела:',
                          style: TextStyle(
                            color: Color(0xFF4CAF50),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Center(
                          child: Text(
                            _bmiResult!.toStringAsFixed(1),
                            style: const TextStyle(
                              color: Color(0xFF4CAF50),
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          _recommendation,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF757575),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),

              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TextButton(
              onPressed: () {
                // Остаемся на этой странице
              },
              child: const Text(
                'Калькулятор',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
              child: const Text(
                'Профиль',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
