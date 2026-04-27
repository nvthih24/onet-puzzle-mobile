import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../widgets/line_painter.dart';

class GameplayScreen extends StatelessWidget {
  const GameplayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Lấy dữ liệu từ Provider
    var gameProvider = context.watch<GameProvider>();
    var board = gameProvider.board;

    int totalRows = gameProvider.rows + 2;
    int totalCols = gameProvider.cols + 2;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(title: const Text('Level 1'), centerTitle: true),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Stack(
            children: [
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: totalCols,
                  crossAxisSpacing: 6.0,
                  mainAxisSpacing: 6.0,
                ),
                itemCount: totalRows * totalCols,
                itemBuilder: (context, index) {
                  int y = index ~/ totalCols;
                  int x = index % totalCols;
                  int itemId = board[y][x];

                  if (itemId == 0) return const SizedBox.shrink();

                  // Kiểm tra xem ô này có đang được chọn không
                  bool isSelected =
                      gameProvider.firstSelected != null &&
                      gameProvider.firstSelected!.x == x &&
                      gameProvider.firstSelected!.y == y;

                  // Bọc GestureDetector để bắt sự kiện tap
                  return GestureDetector(
                    onTap: () => context.read<GameProvider>().handleTap(y, x),
                    child: Container(
                      decoration: BoxDecoration(
                        // Đổi màu nền nếu đang được chọn
                        color: isSelected ? Colors.blue[100] : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(2, 2),
                          ),
                        ],
                        // Viền đậm hơn nếu đang được chọn
                        border: Border.all(
                          color: isSelected
                              ? Colors.redAccent
                              : Colors.blueAccent,
                          width: isSelected ? 3 : 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '$itemId',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              if (gameProvider.currentPath != null)
                Positioned.fill(
                  child: CustomPaint(
                    painter: LinePainter(
                      path: gameProvider.currentPath,
                      rows: totalRows,
                      cols: totalCols,
                      spacing: 6.0,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
