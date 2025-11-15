import 'package:flutter/material.dart';
import '../models/signature_data.dart';

class SignatureFrame extends StatefulWidget {
  final Function(SignatureData) onSign;
  final SignatureData? initialData;
  final double width;
  final double height;

  const SignatureFrame({
    Key? key,
    required this.onSign,
    this.initialData,
    required this.width,
    required this.height,
  }) : super(key: key);

  @override
  _SignatureFrameState createState() => _SignatureFrameState();
}

class _SignatureFrameState extends State<SignatureFrame> {
  List<Offset> points = [];
  bool isDragging = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      points = List.from(widget.initialData!.points);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Modern Signature Canvas
        Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            border: Border.all(
              color: isDark ? Color(0xFF475569) : Color(0xFFE2E8F0),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(16),
            color: isDark ? Color(0xFF1E293B) : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Stack(
              children: [
                // Watermark Text
                if (points.isEmpty)
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.gesture_rounded,
                          size: 48,
                          color: (isDark ? Color(0xFF64748B) : Color(0xFF94A3B8)).withOpacity(0.3),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Sign Here',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: (isDark ? Color(0xFF64748B) : Color(0xFF94A3B8)).withOpacity(0.3),
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                // Signature Drawing Area
                GestureDetector(
                  onPanStart: (details) {
                    setState(() {
                      isDragging = true;
                      final box = context.findRenderObject() as RenderBox;
                      final point = box.globalToLocal(details.globalPosition);
                      // Ensure the point is within bounds
                      if (point.dx >= 0 && point.dx <= widget.width &&
                          point.dy >= 0 && point.dy <= widget.height) {
                        points = [point];
                      }
                    });
                  },
                  onPanUpdate: (details) {
                    if (isDragging) {
                      final box = context.findRenderObject() as RenderBox;
                      final point = box.globalToLocal(details.globalPosition);
                      // Ensure the point is within bounds
                      if (point.dx >= 0 && point.dx <= widget.width &&
                          point.dy >= 0 && point.dy <= widget.height) {
                        setState(() {
                          points.add(point);
                        });
                      }
                    }
                  },
                  onPanEnd: (details) {
                    setState(() {
                      isDragging = false;
                    });
                  },
                  child: CustomPaint(
                    painter: SignaturePainter(
                      points: points,
                      boundarySize: Size(widget.width, widget.height),
                      isDark: isDark,
                    ),
                    size: Size(widget.width, widget.height),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Modern Action Buttons
        Row(
          children: [
            // Clear Button
            Expanded(
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? Color(0xFF475569) : Color(0xFFE2E8F0),
                    width: 1.5,
                  ),
                ),
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      points.clear();
                    });
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: isDark ? Color(0xFFF1F5F9) : Color(0xFF0F172A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.clear_rounded, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Clear',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Confirm Button
            Expanded(
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF667EEA).withOpacity(0.4),
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: points.isEmpty ? null : () {
                    widget.onSign(SignatureData(
                      points: points,
                      boundarySize: Size(widget.width, widget.height),
                    ));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_rounded, size: 20, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Confirm',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class SignaturePainter extends CustomPainter {
  final List<Offset> points;
  final Size boundarySize;
  final bool scale;
  final Size? targetSize;
  final bool isDark;

  SignaturePainter({
    required this.points,
    required this.boundarySize,
    this.scale = false,
    this.targetSize,
    this.isDark = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDark ? Color(0xFFF1F5F9) : Color(0xFF0F172A)
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    if (points.isEmpty) return;

    if (scale && targetSize != null) {
      final scaleX = targetSize!.width / boundarySize.width;
      final scaleY = targetSize!.height / boundarySize.height;

      final scaledPoints = points.map((point) {
        return Offset(point.dx * scaleX, point.dy * scaleY);
      }).toList();

      for (int i = 0; i < scaledPoints.length - 1; i++) {
        canvas.drawLine(scaledPoints[i], scaledPoints[i + 1], paint);
      }
    } else {
      for (int i = 0; i < points.length - 1; i++) {
        canvas.drawLine(points[i], points[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(SignaturePainter oldDelegate) => true;
}

