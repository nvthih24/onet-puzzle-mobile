import 'package:flutter/material.dart';
import '../models/board_manager.dart';
import '../utils/path_finder.dart';

// Tạo một class nhỏ để lưu tọa độ cho gọn
class Point {
  final int x, y;
  Point(this.x, this.y);
}

class GameProvider extends ChangeNotifier {
  late List<List<int>> board;
  Point? firstSelected; // Lưu lại tọa độ ô đầu tiên được chọn
  List<Point>? currentPath; // Lưu đường nối hiện tại (nếu có)
  final int rows = 4;
  final int cols = 4;
  late PathFinder pathFinder;
  bool isWon = false;
  int score = 0;

  GameProvider() {
    pathFinder = PathFinder(rows, cols);
    startNewGame();
  }

  void startNewGame() {
    var boardManager = BoardManager(rows: rows, cols: cols);
    board = boardManager.generateBoard();
    // board = [
    //   [0, 0, 0, 0, 0, 0], // Viền trên
    //   [0, 1, 1, 2, 3, 0], // Cặp 1-1 là "mồi nhử"
    //   [0, 4, 5, 6, 7, 0],
    //   [0, 3, 2, 8, 4, 0],
    //   [0, 7, 6, 5, 8, 0],
    //   [0, 0, 0, 0, 0, 0], // Viền dưới
    // ];
    firstSelected = null;
    isWon = false;
    score = 0;
    notifyListeners(); // Báo cho UI vẽ lại màn hình
  }

  void handleTap(int y, int x) {
    if (board[y][x] == 0 || isWon) return; // Nếu chạm vào ô trống thì bỏ qua

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
}
