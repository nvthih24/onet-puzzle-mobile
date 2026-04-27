import 'package:flutter/material.dart';
import '../models/board_manager.dart';
import '../utils/path_finder.dart';
import 'dart:async';

// Tạo một class nhỏ để lưu tọa độ cho gọn
class Point {
  final int x, y;
  Point(this.x, this.y);
}

class GameProvider extends ChangeNotifier {
  late List<List<int>> board;
  Point? firstSelected; // Lưu lại tọa độ ô đầu tiên được chọn
  List<Point>? currentPath; // Lưu đường nối hiện tại (nếu có)
  int rows = 4;
  int cols = 4;
  late PathFinder pathFinder;
  bool isWon = false;
  bool isGameOver = false;
  int score = 0;
  int timeLeft = 60; // Cho 60 giây để test, sau này ông có thể chỉnh theo Level
  Timer? _timer;
  int currentLevel = 1;
  int maxTime = 60; // Biến lưu tổng thời gian để tính % cho thanh Progress
  int shuffleCount = 1; // Số lượt đảo hình
  int hintCount = 1; // Số lượt gợi ý
  List<Point>? hintPoints; // Lưu tọa độ 2 ô được gợi ý để làm sáng lên

  GameProvider() {
    startNewGame();
  }

  // Hàm tính toán kích thước và thời gian theo lộ trình ông vạch ra
  void _updateLevelConfig() {
    if (currentLevel <= 3) {
      cols = 4;
      rows = 4;
      timeLeft = 60;
    } else if (currentLevel <= 6) {
      cols = 4;
      rows = 6;
      timeLeft = 90;
    } else if (currentLevel <= 9) {
      cols = 6;
      rows = 6;
      timeLeft = 120;
    } else if (currentLevel <= 12) {
      cols = 6;
      rows = 8;
      timeLeft = 150;
    } else {
      cols = 6;
      rows = 10;
      // Sinh tồn cực hạn: Bắt đầu từ Level 13, cứ qua 1 màn là trừ đi 5 giây
      int timeReduction = (currentLevel - 13) * 5;
      timeLeft = 180 - timeReduction;
      if (timeLeft < 30)
        timeLeft = 30; // Mức khó nhất không bao giờ dưới 30 giây
    }
    maxTime = timeLeft;
  }

  // Hàm setup bàn cờ (dùng chung cho cả lúc New Game và lúc Next Level)
  void _initBoard() {
    _updateLevelConfig();
    var boardManager = BoardManager(rows: rows, cols: cols);
    board = boardManager.generateBoard();

    // RẤT QUAN TRỌNG: Phải cập nhật lại kích thước mới cho bộ não tìm đường
    pathFinder = PathFinder(rows, cols);

    firstSelected = null;
    isWon = false;
    isGameOver = false;
    _startTimer();
    notifyListeners();
  }

  void startNewGame() {
    currentLevel = 1;
    score = 0;
    shuffleCount = 1;
    hintCount = 1;
    _initBoard();
    notifyListeners(); // Báo cho UI vẽ lại màn hình
  }

  // Qua màn tiếp theo (Giữ nguyên điểm, Tăng Level)
  void nextLevel() {
    currentLevel++;
    shuffleCount++; // Thưởng thêm 1 lượt đảo hình khi qua màn
    hintCount++;
    _initBoard();
  }

  void handleTap(int y, int x) {
    if (board[y][x] == 0 || isWon || isGameOver)
      return; // Nếu chạm vào ô trống thì bỏ qua

    if (firstSelected == null) {
      // Trường hợp 1: Chưa chọn ô nào -> Ghi nhớ ô này làm ô đầu tiên
      firstSelected = Point(x, y);
      notifyListeners();
    } else {
      // Trường hợp 2: Bấm lại chính ô vừa chọn -> Bỏ chọn
      if (firstSelected!.x == x && firstSelected!.y == y) {
        firstSelected = null;

        notifyListeners();
        return;
      }

      // Trường hợp 3: Bấm ô thứ 2 -> Kiểm tra xem có ăn được không
      Point p1 = firstSelected!;
      Point p2 = Point(x, y);

      List<Point>? validPath = pathFinder.findPath(p1, p2, board);
      if (board[p1.y][p1.x] == board[p2.y][p2.x] && validPath != null) {
        print("🟢 Nối thành công!");
        // Tạm thời vẽ 1 đường thẳng nối trực tiếp 2 điểm
        currentPath = validPath;
        score += 100;
        notifyListeners(); // Báo cho UI vẽ đường nối

        // Đợi 0.5 giây để người chơi nhìn thấy đường nối, sau đó mới xóa hình
        Future.delayed(const Duration(milliseconds: 500), () {
          board[p1.y][p1.x] = 0;
          board[p2.y][p2.x] = 0;
          currentPath = null; // Xóa đường vẽ

          bool hasRemaining = true;
          for (int y = 1; y <= rows; y++) {
            for (int x = 1; x <= cols; x++) {
              if (board[y][x] != 0) {
                hasRemaining = false;
                break;
              }
            }
          }
          if (hasRemaining) {
            print("🎉 Bạn đã chiến thắng!");
            isWon = true;
          } else if (!hasValidMove()) {
            print("💀 Hết nước đi! Vui lòng xáo trộn lại bàn cờ.");
            shuffleBoard();
          }
          notifyListeners(); // Báo cho UI ẩn ô và xóa đường
        });
      } else {
        print("🔴 Không thể nối (Sai ID hoặc bị cản đường)");
      }

      // Ăn xong hoặc sai thì đều phải reset lại ô đã chọn
      firstSelected = null;
      notifyListeners();
    }
  }

  // Thêm hàm này vào trong class GameProvider
  bool hasValidMove() {
    List<Point> activePoints = [];

    // 1. Lấy danh sách tọa độ các ô chưa bị ăn (khác 0)
    for (int y = 1; y <= rows; y++) {
      for (int x = 1; x <= cols; x++) {
        if (board[y][x] != 0) {
          activePoints.add(Point(x, y));
        }
      }
    }

    // 2. Duyệt qua từng cặp điểm để kiểm tra
    for (int i = 0; i < activePoints.length - 1; i++) {
      for (int j = i + 1; j < activePoints.length; j++) {
        Point p1 = activePoints[i];
        Point p2 = activePoints[j];

        // Nếu 2 ô cùng ID và có đường nối -> Vẫn còn nước đi
        if (board[p1.y][p1.x] == board[p2.y][p2.x]) {
          if (pathFinder.findPath(p1, p2, board) != null) {
            return true;
          }
        }
      }
    }
    return false; // Quét hết mà không có cặp nào -> Hết đường (Deadlock)
  }

  // Thêm hàm này vào trong class GameProvider
  void shuffleBoard() {
    List<int> activeItems = [];

    // 1. Rút toàn bộ ID hình ảnh còn lại ra một mảng 1 chiều
    for (int y = 1; y <= rows; y++) {
      for (int x = 1; x <= cols; x++) {
        if (board[y][x] != 0) {
          activeItems.add(board[y][x]);
        }
      }
    }

    // 2. Xáo trộn ngẫu nhiên
    activeItems.shuffle();

    // 3. Đổ ngược mảng đã xáo trộn vào lại các vị trí cũ trên bàn cờ
    int index = 0;
    for (int y = 1; y <= rows; y++) {
      for (int x = 1; x <= cols; x++) {
        if (board[y][x] != 0) {
          board[y][x] = activeItems[index];
          index++;
        }
      }
    }
  }

  void _startTimer() {
    // Hủy timer cũ nếu có để tránh bị chạy chồng chéo
    _timer?.cancel();

    // Tạo 1 bộ đếm, cứ 1 giây (1 seconds) là chạy code bên trong 1 lần
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeLeft > 0 && !isWon && !isGameOver) {
        timeLeft--;
        notifyListeners(); // Cập nhật số giây lên màn hình
      } else {
        timer.cancel(); // Dừng đồng hồ
        if (timeLeft == 0 && !isWon) {
          isGameOver = true; // Hết giờ -> Thua
          notifyListeners(); // Báo UI hiện màn hình Game Over
        }
      }
    });
  }

  void manualShuffle() {
    if (shuffleCount > 0) {
      shuffleCount--;
      shuffleBoard();
      notifyListeners();
    }
  }

  void useHint() {
    if (hintCount > 0 && hintPoints == null) {
      // Quét bàn cờ tìm 1 cặp giống hàm hasValidMove()
      List<Point> activePoints = [];
      for (int y = 1; y <= rows; y++) {
        for (int x = 1; x <= cols; x++) {
          if (board[y][x] != 0) activePoints.add(Point(x, y));
        }
      }

      for (int i = 0; i < activePoints.length - 1; i++) {
        for (int j = i + 1; j < activePoints.length; j++) {
          Point p1 = activePoints[i];
          Point p2 = activePoints[j];

          if (board[p1.y][p1.x] == board[p2.y][p2.x]) {
            if (pathFinder.findPath(p1, p2, board) != null) {
              hintCount--;
              hintPoints = [p1, p2]; // Lưu lại 2 điểm để vẽ màu vàng trên UI
              notifyListeners();

              // Tắt màu vàng gợi ý sau 1.5 giây
              Future.delayed(const Duration(milliseconds: 1500), () {
                hintPoints = null;
                notifyListeners();
              });
              return; // Tìm được 1 cặp là thoát hàm luôn
            }
          }
        }
      }
    }
  }
}
