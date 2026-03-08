import 'package:flutter/material.dart';
import '../widgets/animated_balloon.dart';
import '../widgets/cloud_widget.dart';
import '../widgets/bird_widget.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Balloon Animation'),
      ),
      body: Stack(
        children: [

          // Sky gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF87CEEB),
                  Color(0xFFE0F7FA),
                ],
              ),
            ),
          ),

          // Clouds
          CloudWidget(speed: 18, top: 60,  size: 120),
          CloudWidget(speed: 12, top: 150, size: 80),
          CloudWidget(speed: 8,  top: 80,  size: 60),
          CloudWidget(speed: 20, top: 220, size: 100),

          // Birds
          BirdWidget(speed: 6,  top: 100, size: 50),
          BirdWidget(speed: 9,  top: 180, size: 40),
          BirdWidget(speed: 7,  top: 250, size: 45, reverse: true),
          BirdWidget(speed: 11, top: 130, size: 35, reverse: true),

          // ✅ Feature 10: 5 balloons — different colors, sizes,
          // speeds, delays and float directions
          // ✅ Feature 8: Only first balloon plays sound (playSound: true)

          // Balloon 1 — Red, main balloon, sound enabled
          AnimatedBalloonWidget(
            color: Colors.red,
            sizeMultiplier: 0.55,
            speedMultiplier: 1.0,
            delaySeconds: 0,
            horizontalOffset: -120,
            floatDirection: 1.0,
            playSound: true,
          ),

          // Balloon 2 — Blue, floats left
          AnimatedBalloonWidget(
            color: Colors.blue,
            sizeMultiplier: 0.45,
            speedMultiplier: 1.3,
            delaySeconds: 2,
            horizontalOffset: -50,
            floatDirection: -1.0,
            playSound: false,
          ),

          // Balloon 3 — Green, floats right
          AnimatedBalloonWidget(
            color: Colors.green,
            sizeMultiplier: 0.5,
            speedMultiplier: 0.8,
            delaySeconds: 4,
            horizontalOffset: 20,
            floatDirection: 1.0,
            playSound: false,
          ),

          // Balloon 4 — Yellow, smaller and fast, floats left
          AnimatedBalloonWidget(
            color: Colors.yellow,
            sizeMultiplier: 0.4,
            speedMultiplier: 1.5,
            delaySeconds: 1,
            horizontalOffset: 90,
            floatDirection: -1.0,
            playSound: false,
          ),

          // Balloon 5 — Purple, floats right
          AnimatedBalloonWidget(
            color: Colors.purple,
            sizeMultiplier: 0.48,
            speedMultiplier: 1.1,
            delaySeconds: 3,
            horizontalOffset: 150,
            floatDirection: 1.0,
            playSound: false,
          ),

        ],
      ),
    );
  }
}