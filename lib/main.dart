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
      appBar: AppBar(
        title: const Text('Onet Puzzle: Bắt đầu'),
        centerTitle: true,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const GameplayScreen()),
            );
          },
          child: const Text('Chơi Ngay'),
        ),
      ),
    );
  }
}
