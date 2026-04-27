import 'dart:math';

class BoardManager {
  int rows;
  int cols;
  int numberOfPairs;

  BoardManager({required this.rows, required this.cols})
    : numberOfPairs = (rows * cols) ~/ 2 {
    // Đảm bảo tổng số ô phải là số chẵn để có thể bắt cặp
    assert((rows * cols) % 2 == 0, 'Tổng số ô (rows * cols) phải là số chẵn!');
  }

  List<List<int>> generateBoard() {
    // Bước 1: Tạo một mảng 1 chiều chứa các cặp ID (ví dụ: 1,1, 2,2, 3,3...)
    List<int> flatList = [];
    int currentId = 1;

    for (int i = 0; i < numberOfPairs; i++) {
      flatList.add(currentId);
      flatList.add(currentId);

      currentId++;
      // Giả sử ông có 10 loại hình (từ 1 đến 10), nếu vượt quá thì quay lại 1
      if (currentId > 10) currentId = 1;
    }

    // Bước 2: Xáo trộn mảng 1 chiều (Shuffle)
    flatList.shuffle(Random());

    // Bước 3: Khởi tạo ma trận 2 chiều với kích thước (rows + 2) x (cols + 2)
    // Mặc định tất cả các ô đều là 0 (ô trống)
    List<List<int>> board = List.generate(
      rows + 2,
      (_) => List.generate(cols + 2, (_) => 0),
    );

    // Bước 4: Đổ dữ liệu từ mảng 1 chiều đã xáo trộn vào phần "lõi" của ma trận
    int listIndex = 0;
    for (int i = 1; i <= rows; i++) {
      for (int j = 1; j <= cols; j++) {
        board[i][j] = flatList[listIndex];
        listIndex++;
      }
    }

    return board;
  }

  // Hàm in ma trận ra console để debug (rất quan trọng)
  void printBoard(List<List<int>> board) {
    for (var row in board) {
      print(row.map((e) => e.toString().padLeft(2, '0')).join(' '));
    }
  }
}
