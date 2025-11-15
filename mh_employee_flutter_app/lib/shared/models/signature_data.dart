import 'dart:convert';
import 'dart:ui';

class SignaturePoint {
  final double x;
  final double y;

  SignaturePoint(this.x, this.y);

  factory SignaturePoint.fromJson(Map<String, dynamic> json) {
    // Handle both uppercase and lowercase keys
    final x = json['x'] ?? json['X'] ?? 0.0;
    final y = json['y'] ?? json['Y'] ?? 0.0;

    return SignaturePoint(
      (x is num) ? x.toDouble() : 0.0,
      (y is num) ? y.toDouble() : 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'x': x,
    'y': y,
  };
}

class SignatureData {
  final List<Offset> points;
  final Size boundarySize;

  SignatureData({
    required this.points,
    required this.boundarySize,
  });

  factory SignatureData.fromJson(Map<String, dynamic> json) {
    List<dynamic> pointsData;

    // Check if points is a string (encoded JSON) or a List<dynamic>
    if (json['points'] is String) {
      try {
        pointsData = jsonDecode(json['points'] as String);
      } catch (e) {
        throw FormatException('Error decoding points data: $e');
      }
    } else {
      pointsData = json['points'] as List<dynamic>;
    }

    // Map points to Offset using SignaturePoint for consistent handling
    List<Offset> points = pointsData.map((point) {
      if (point is Map<String, dynamic>) {
        final signaturePoint = SignaturePoint.fromJson(point);
        return Offset(signaturePoint.x, signaturePoint.y);
      }
      throw FormatException('Invalid point format');
    }).toList();

    // Handle both camelCase and snake_case keys for boundary dimensions
    final width = json['boundaryWidth'] ?? json['boundary_width'] ?? 0.0;
    final height = json['boundaryHeight'] ?? json['boundary_height'] ?? 0.0;

    return SignatureData(
      points: points,
      boundarySize: Size(
        (width is num) ? width.toDouble() : 0.0,
        (height is num) ? height.toDouble() : 0.0,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'points': points.map((offset) => SignaturePoint(
      offset.dx,
      offset.dy,
    ).toJson()).toList(),
    'boundaryWidth': boundarySize.width,
    'boundaryHeight': boundarySize.height,
  };
}
