import 'package:flutter/material.dart';
import 'models/board_manager.dart';
import 'screens/gameplay_screen.dart';
import 'package:provider/provider.dart';
import 'providers/game_provider.dart';

void main() {
  // var boardManager = BoardManager(rows: 4, cols: 4);
  // var board = boardManager.generateBoard();
  // boardManager.printBoard(board);

  runApp(
    ChangeNotifierProvider(
      create: (context) => GameProvider(),
      child: const OnetGameApp(),
    ),
  );
}

class OnetGameApp extends StatelessWidget {
  const OnetGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Onet Puzzle',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false, // Tắt cái chữ debug góc phải
      home: const MainMenuScreen(),
    );
  }
}

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        // Tạo nền Gradient chéo cho cảm giác hiện đại và năng động
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF4AC29A),
              Color(0xFFBDFFF3),
            ], // Tone xanh mint/cyan mát mắt
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // --- PHẦN 1: HEADER (LOGO & TÊN GAME) ---
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.catching_pokemon, // Icon PokeBall tạm thời
                  size: 80,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'ONET PUZZLE',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 3,
                  shadows: [
                    Shadow(
                      color: Colors.black26,
                      offset: Offset(2, 3),
                      blurRadius: 5,
                    ),
                  ],
                ),
              ),
              const Text(
                'Phiên bản Thử thách',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                  letterSpacing: 1,
                ),
              ),

              const Spacer(),

              // --- PHẦN 2: BODY (CÁC NÚT CHỨC NĂNG) ---
              _buildMenuButton(
                icon: Icons.play_arrow_rounded,
                label: 'CHƠI NGAY',
                color: Colors.orangeAccent,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GameplayScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildMenuButton(
                icon: Icons.leaderboard_rounded,
                label: 'BẢNG XẾP HẠNG',
                color: Colors.blueAccent,
                onPressed: () {
                  // Giữ chỗ cho tính năng đua top thời gian
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tính năng đang được phát triển!'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildMenuButton(
                icon: Icons.settings_rounded,
                label: 'CÀI ĐẶT',
                color: Colors.green,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cài đặt âm thanh & hình ảnh'),
                    ),
                  );
                },
              ),

              const Spacer(),

              // --- PHẦN 3: FOOTER (CREDITS) ---
              const Padding(
                padding: EdgeInsets.only(bottom: 16.0),
                child: Text(
                  'Phát triển bởi Nguyễn Văn Thịnh',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Hàm helper để build UI cho nút bấm thống nhất
  Widget _buildMenuButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 250,
      height: 55,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 28),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 6,
          shadowColor: color.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30), // Bo tròn viền cực đại
          ),
        ),
      ),
    );
  }
}
