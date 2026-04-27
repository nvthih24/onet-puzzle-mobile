import 'package:flutter/material.dart';
import '../providers/game_provider.dart';

class LinePainter extends CustomPainter {
  final List<Point>? path;
  final int rows;
  final int cols;
  final double spacing;

  LinePainter({
    required this.path,
    required this.rows,
    required this.cols,
    this.spacing = 6.0, // Phải khớp với crossAxisSpacing trong GridView
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (path == null || path!.length < 2) return;

    // Cấu hình nét vẽ: màu đỏ cam, dày 4 pixel, bo tròn 2 đầu
    final paint = Paint()
      ..color = Colors.deepOrangeAccent
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Tính toán kích thước của 1 ô vuông trên màn hình
    // (Lấy tổng chiều rộng trừ đi các khoảng hở spacing, rồi chia cho số cột)
    final cellWidth = (size.width - (cols - 1) * spacing) / cols;
    // Vì ô hình vuông nên chiều cao bằng chiều rộng
    final cellHeight = cellWidth;

    // Hàm phụ trợ: Chuyển tọa độ lưới (Point) thành tọa độ Pixel (Offset)
    Offset getPixelOffset(Point p) {
      double dx = (p.x * cellWidth) + (p.x * spacing) + (cellWidth / 2);
      double dy = (p.y * cellHeight) + (p.y * spacing) + (cellHeight / 2);
      return Offset(dx, dy);
    }

    // Tiến hành vẽ đường nối đi qua các điểm
    final pathToDraw = Path();
    pathToDraw.moveTo(
      getPixelOffset(path!.first).dx,
      getPixelOffset(path!.first).dy,
    );

    for (int i = 1; i < path!.length; i++) {
      var offset = getPixelOffset(path![i]);
      pathToDraw.lineTo(offset.dx, offset.dy);
    }

    canvas.drawPath(pathToDraw, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
