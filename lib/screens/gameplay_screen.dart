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
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Level ${gameProvider.currentLevel}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: gameProvider.timeLeft <= 10
                    ? Colors.redAccent.withOpacity(0.3)
                    : Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.timer,
                    size: 18,
                    color: gameProvider.timeLeft <= 10
                        ? Colors.red
                        : Colors.black87,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${gameProvider.timeLeft}s',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: gameProvider.timeLeft <= 10
                          ? Colors.red
                          : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Hiển thị điểm số ở góc phải
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.amberAccent.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Điểm: ${gameProvider.score}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange,
                ),
              ),
            ),
          ],
        ),
        centerTitle: false, // Tắt centerTitle để Row tràn đều 2 bên
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: gameProvider.hintCount > 0
                    ? () => gameProvider.useHint()
                    : null,
                icon: const Icon(Icons.lightbulb),
                label: Text('Gợi ý (${gameProvider.hintCount})'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                ),
              ),
              ElevatedButton.icon(
                onPressed: gameProvider.shuffleCount > 0
                    ? () => gameProvider.manualShuffle()
                    : null,
                icon: const Icon(Icons.shuffle),
                label: Text('Đảo hình (${gameProvider.shuffleCount})'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            LinearProgressIndicator(
              value: gameProvider.timeLeft / gameProvider.maxTime,
              minHeight: 6,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                gameProvider.timeLeft <= 10 ? Colors.red : Colors.green,
              ),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: totalCols,
                          crossAxisSpacing: 2.0,
                          mainAxisSpacing: 2.0,
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

                          bool isHinted =
                              gameProvider.hintPoints != null &&
                              gameProvider.hintPoints!.any(
                                (p) => p.x == x && p.y == y,
                              );

                          // Bọc GestureDetector để bắt sự kiện tap
                          return GestureDetector(
                            onTap: () =>
                                context.read<GameProvider>().handleTap(y, x),
                            child: Container(
                              decoration: BoxDecoration(
                                // Đổi màu nền nếu đang được chọn
                                color: isSelected
                                    ? Colors.blue[100]
                                    : (isHinted
                                          ? Colors.yellow[100]
                                          : Colors.white),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 2,
                                    offset: const Offset(1, 1),
                                  ),
                                ],
                                // Viền đậm hơn nếu đang được chọn
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.redAccent
                                      : (isHinted
                                            ? Colors.orange
                                            : Colors.blueAccent),
                                  width: isSelected || isHinted ? 3 : 2,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  '$itemId',
                                  style: const TextStyle(
                                    fontSize: 20,
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
                              spacing: 2.0,
                            ),
                          ),
                        ),
                      if (gameProvider.isWon)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(
                                0.85,
                              ), // Làm mờ nền phía sau
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons
                                      .emoji_events_rounded, // Biểu tượng cúp vàng
                                  size: 100,
                                  color: Colors.amber,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'XUẤT SẮC!',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueAccent,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Bạn đã dọn sạch bàn cờ.',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 32),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    // Gọi hàm reset game
                                    context.read<GameProvider>().nextLevel();
                                  },
                                  icon: const Icon(Icons.arrow_forward_rounded),
                                  label: const Text(
                                    'Màn tiếp theo',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                    backgroundColor: Colors
                                        .green, // Đổi màu xanh lá cho khí thế
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (gameProvider.isGameOver)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(
                                0.7,
                              ), // Nền tối cho cảm giác tiếc nuối
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.timer_off,
                                  size: 100,
                                  color: Colors.redAccent,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'HẾT GIỜ!',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Điểm của bạn: ${gameProvider.score}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    color: Colors.amberAccent,
                                  ),
                                ),
                                const SizedBox(height: 32),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    context.read<GameProvider>().startNewGame();
                                  },
                                  icon: const Icon(Icons.refresh),
                                  label: const Text(
                                    'Thử lại ngay',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                    backgroundColor: Colors.redAccent,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
