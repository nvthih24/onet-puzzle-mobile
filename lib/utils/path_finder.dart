import '../providers/game_provider.dart';

class PathFinder {
  int rows;
  int cols;

  PathFinder(this.rows, this.cols);

  bool checkLineX(int y, int x1, int x2, List<List<int>> board) {
    int minX = x1 < x2 ? x1 : x2;
    int maxX = x1 > x2 ? x1 : x2;
    for (int x = minX + 1; x < maxX; x++) {
      if (board[y][x] != 0) return false;
    }
    return true;
  }

  bool checkLineY(int x, int y1, int y2, List<List<int>> board) {
    int minY = y1 < y2 ? y1 : y2;
    int maxY = y1 > y2 ? y1 : y2;
    for (int y = minY + 1; y < maxY; y++) {
      if (board[y][x] != 0) return false;
    }
    return true;
  }

  // NÂNG CẤP: Trả về danh sách điểm tạo thành chữ L (nếu có)
  List<Point>? getLShapePath(Point p1, Point p2, List<List<int>> board) {
    Point corner1 = Point(p1.x, p2.y);
    if (board[corner1.y][corner1.x] == 0) {
      if (checkLineY(p1.x, p1.y, corner1.y, board) &&
          checkLineX(corner1.y, p1.x, p2.x, board)) {
        return [p1, corner1, p2]; // Trả về 3 điểm: Bắt đầu -> Góc -> Kết thúc
      }
    }
    Point corner2 = Point(p2.x, p1.y);
    if (board[corner2.y][corner2.x] == 0) {
      if (checkLineX(p1.y, p1.x, corner2.x, board) &&
          checkLineY(corner2.x, p1.y, p2.y, board)) {
        return [p1, corner2, p2];
      }
    }
    return null;
  }

  // NÂNG CẤP: Đổi tên thành findPath và trả về List<Point>
  List<Point>? findPath(Point p1, Point p2, List<List<int>> board) {
    // 1. Check thẳng ngang
    if (p1.y == p2.y && checkLineX(p1.y, p1.x, p2.x, board)) return [p1, p2];
    // 2. Check thẳng dọc
    if (p1.x == p2.x && checkLineY(p1.x, p1.y, p2.y, board)) return [p1, p2];

    // 3. Check chữ L
    var lPath = getLShapePath(p1, p2, board);
    if (lPath != null) return lPath;

    // 4. Check chữ U, Z (Quét ngang)
    for (int i = -1; i <= 1; i += 2) {
      int x = p1.x + i;
      while (x >= 0 && x < cols + 2) {
        if (board[p1.y][x] != 0) break;
        Point corner1 = Point(x, p1.y);
        var lPathFromCorner = getLShapePath(corner1, p2, board);
        if (lPathFromCorner != null) {
          // Trả về: Điểm 1 -> Điểm góc quét -> [Điểm góc L -> Điểm 2]
          return [p1, ...lPathFromCorner];
        }
        if (x == p2.x && checkLineY(x, p1.y, p2.y, board)) {
          return [p1, corner1, p2];
        }
        x += i;
      }
    }

    // 5. Check chữ U, Z (Quét dọc)
    for (int i = -1; i <= 1; i += 2) {
      int y = p1.y + i;
      while (y >= 0 && y < rows + 2) {
        if (board[y][p1.x] != 0) break;
        Point corner1 = Point(p1.x, y);
        var lPathFromCorner = getLShapePath(corner1, p2, board);
        if (lPathFromCorner != null) {
          return [p1, ...lPathFromCorner];
        }
        if (y == p2.y && checkLineX(y, p1.x, p2.x, board)) {
          return [p1, corner1, p2];
        }
        y += i;
      }
    }

    return null; // Trả về null nếu bí đường
  }
}
