import 'package:flutter/material.dart';
import 'bmi_screen.dart';
import 'bmi_storage.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Аватарка с зеленым контуром
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
                      Icons.flutter_dash, // Стандартная иконка Flutter
                      size: 50,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                  const SizedBox(height: 15),
                  // Имя Фамилия (жирный серый)
                  const Text(
                    'Имя Фамилия',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey, // Серый цвет
                    ),
                  ),
                  const SizedBox(height: 5),
                  // Email (можно оставить, если нужно, или убрать)
                  const Text(
                    'user@example.com',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
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

            // --- Список истории расчетов ---
            Expanded(
              child: BmiStorage.history.isEmpty
                  ? const Center(
                      child: Text(
                        'Нет данных о расчетах',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: BmiStorage.history.length,
                      itemBuilder: (context, index) {
                        final item = BmiStorage.history[index];
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
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item['date'],
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildInfoColumn('Рост', '${item['height']}'),
                                  _buildInfoColumn('Вес', '${item['weight']}'),
                                  _buildInfoColumn(
                                    'Индекс массы тела',
                                    '${item['bmi'].toStringAsFixed(2)}',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Рекомендация',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item['recommendation'],
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF757575),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      // --- Нижняя панель (Footer) ---
      bottomNavigationBar: Container(
        height: 60, // Фиксированная высота 60px
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),

              blurRadius: 10,
              offset: const Offset(0, -4), // Тень сверху
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
                style: TextStyle(
                  color: Colors.grey, // Неактивный цвет
                  fontSize: 14,
                ),
              ),
            ),
            // Кнопка Профиль
            TextButton(
              onPressed: () {
                // Остаемся на этой странице
              },
              child: const Text(
                'Профиль',
                style: TextStyle(
                  color: Colors.black, // Активный цвет
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
