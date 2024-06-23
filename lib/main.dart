import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DrawingProvider(),
      child: MaterialApp(
        home: DrawingScreen(),
      ),
    );
  }
}

class DrawingProvider extends ChangeNotifier {
  List<Offset> points = [];
  List<Offset> correctPath = [
    Offset(65, 55),
    Offset(100, 50),
    Offset(130, 55),
    Offset(160, 60),
    Offset(160, 75),
    Offset(130, 88),
    Offset(85, 120),
    Offset(80, 140),
    Offset(80, 175),
    Offset(120, 200),
    Offset(140, 145),
    Offset(185, 190),
  ];

  void addPoint(Offset point) {
    points.add(point);
    notifyListeners();
  }

  double calculateAccuracy() {
    int matchedPoints = 0;

    for (int i = 0; i < correctPath.length; i++) {
      for (int j = 0; j < points.length; j++) {
        if ((points[j] - correctPath[i]).distance < 20) {
          matchedPoints++;
          break;
        }
      }
    }

    return (matchedPoints / correctPath.length) * 100;
  }

  void clearPoints() {
    points.clear();
    notifyListeners();
  }
}

class DrawingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text('test draw ')),
      body: Center(
        child: Container(
          width: 250, // Fixed width
          height: 250, // Fixed height
          color: Colors.white,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(
                "assets/jim.png",
              ),
              Image.asset(
                "assets/jim_line.png",
              ),
              Consumer<DrawingProvider>(
                builder: (context, provider, child) {
                  return GestureDetector(
                    onPanUpdate: (details) {
                      RenderBox renderBox =
                          context.findRenderObject() as RenderBox;
                      Offset localPosition =
                          renderBox.globalToLocal(details.globalPosition);
                      // Ensure points are within the drawing area
                      if (localPosition.dx >= 0 &&
                          localPosition.dx <= 250 &&
                          localPosition.dy >= 0 &&
                          localPosition.dy <= 250) {
                        provider.addPoint(localPosition);
                      }
                    },
                    child: CustomPaint(
                      size: Size(250, 250), // Fixed size
                      painter:
                          DrawingPainter(provider.points, provider.correctPath),
                    ),
                  );
                },
              ),
              Positioned(
                top: 40,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(Icons.baby_changing_station),
                    Icon(Icons.abc)
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          double accuracy = context.read<DrawingProvider>().calculateAccuracy();
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Accuracy'),
              content: Text('Your accuracy is ${accuracy.toStringAsFixed(2)}%'),
              actions: [
                TextButton(
                  onPressed: () {
                    context.read<DrawingProvider>().clearPoints();
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            ),
          );
        },
        child: Icon(Icons.check),
      ),
    );
  }
}

class DrawingPainter extends CustomPainter {
  final List<Offset> points;
  final List<Offset> correctPath;

  DrawingPainter(this.points, this.correctPath);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Color(0xFF369DD8)
      ..strokeCap = StrokeCap.butt
      ..strokeWidth = 25.0;

    // Draw connections
    for (int i = 0; i < points.length; i++) {
      canvas.drawPoints(PointMode.points, [points[i]], paint);
    }

    Paint startPaint = Paint()
      ..color =
          isPointCovered(correctPath.first) ? Colors.transparent : Colors.green
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 15.0;

    Paint endPaint = Paint()
      ..color =
          isPointCovered(correctPath.last) ? Colors.transparent : Colors.red
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 15.0;

    // Draw start and end points of the correct path
    if (correctPath.isNotEmpty) {
      canvas.drawCircle(correctPath.first, 10.0, startPaint);
      canvas.drawCircle(correctPath.last, 10.0, endPaint);
    }

    Paint dotPaint = Paint()
      ..color = Colors.transparent
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0;

    // Draw dots for all points in the correct path
    for (var dot in correctPath) {
      canvas.drawCircle(dot, 4.0, dotPaint);
    }
  }

  bool isPointCovered(Offset point) {
    for (var p in points) {
      if ((p - point).distance < 20) {
        return true;
      }
    }
    return false;
  }

  void drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    double dashWidth = 10, dashSpace = 5, distance = (end - start).distance;
    Offset direction = (end - start) / distance;
    for (double i = 0; i < distance; i += dashWidth + dashSpace) {
      canvas.drawLine(
          start + direction * i, start + direction * (i + dashWidth), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
