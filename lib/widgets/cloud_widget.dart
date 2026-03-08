import 'package:flutter/material.dart';

class CloudWidget extends StatefulWidget {
  final double speed;    // how fast the cloud moves
  final double top;      // vertical position
  final double size;     // size of the cloud

  const CloudWidget({
    Key? key,
    required this.speed,
    required this.top,
    required this.size,
  }) : super(key: key);

  @override
  _CloudWidgetState createState() => _CloudWidgetState();
}

class _CloudWidgetState extends State<CloudWidget>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: widget.speed.toInt()),
      vsync: this,
    );

    _animation = Tween(
      begin: -200.0, // start off screen left
      end: 500.0,    // end off screen right
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.linear, // constant speed — like real clouds
      ),
    );

    // Repeat forever
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Positioned(
          top: widget.top,
          left: _animation.value, // moves horizontally
          child: Opacity(
            opacity: 0.7, // slightly transparent
            child: _buildCloud(),
          ),
        );
      },
    );
  }

  // Builds a cloud shape using overlapping circles
  Widget _buildCloud() {
    return SizedBox(
      width: widget.size,
      height: widget.size * 0.6,
      child: Stack(
        children: [
          // Main cloud body
          Positioned(
            bottom: 0,
            left: widget.size * 0.1,
            child: Container(
              width: widget.size * 0.8,
              height: widget.size * 0.4,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(widget.size * 0.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.2),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),
          // Left puff
          Positioned(
            bottom: widget.size * 0.2,
            left: widget.size * 0.1,
            child: Container(
              width: widget.size * 0.35,
              height: widget.size * 0.35,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Middle puff (biggest)
          Positioned(
            bottom: widget.size * 0.2,
            left: widget.size * 0.3,
            child: Container(
              width: widget.size * 0.45,
              height: widget.size * 0.45,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Right puff
          Positioned(
            bottom: widget.size * 0.2,
            left: widget.size * 0.55,
            child: Container(
              width: widget.size * 0.3,
              height: widget.size * 0.3,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}