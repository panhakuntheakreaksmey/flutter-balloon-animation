import 'dart:ui';
import 'package:flutter/material.dart';

class AnimatedBalloonWidget extends StatefulWidget {
    @override
    _AnimatedBalloonWidgetState createState() => _AnimatedBalloonWidgetState();
}

class _AnimatedBalloonWidgetState extends State<AnimatedBalloonWidget>
    with TickerProviderStateMixin {

    late AnimationController _controllerFloatUp;
    late AnimationController _controllerGrowSize;
    late AnimationController _controllerRotation;
    late AnimationController _controllerPulse;
    late Animation<double> _animationFloatUp;
    late Animation<double> _animationGrowSize;
    late Animation<double> _animationRotation;
    late Animation<double> _animationPulse;
    bool _isInitialized = false;
    double _balloonHeight = 0;
    double _balloonWidth = 0;

    // ✅ Feature 7: Drag and pinch variables
    Offset _position = Offset(0, 0);
    double _scale = 1.0;
    double _previousScale = 1.0;

    @override
    void initState() {
        super.initState();
        _controllerFloatUp = AnimationController(
                duration: Duration(seconds: 8),
        vsync: this,
    );
        _controllerGrowSize = AnimationController(
                duration: Duration(seconds: 4),
        vsync: this,
    );
        _controllerRotation = AnimationController(
                duration: Duration(seconds: 2),
        vsync: this,
    );
        _controllerPulse = AnimationController(
                duration: Duration(milliseconds: 800),
        vsync: this,
    );
    }

    @override
    void didChangeDependencies() {
        super.didChangeDependencies();

        if (!_isInitialized) {
            _balloonHeight = MediaQuery.of(context).size.height / 2;
            _balloonWidth = MediaQuery.of(context).size.height / 3;
            double balloonBottomLocation =
                    MediaQuery.of(context).size.height - _balloonHeight;

            // ✅ Feature 1: Float animation
            _animationFloatUp = Tween(
                    begin: balloonBottomLocation,
                    end: 0.0,
      ).animate(
                    CurvedAnimation(
                            parent: _controllerFloatUp,
                    curve: Curves.easeInOutCubic,
        ),
      );

            // ✅ Feature 1: Grow animation
            _animationGrowSize = Tween(
                    begin: 0.1,
                    end: 1.0,
      ).animate(
                    CurvedAnimation(
                            parent: _controllerGrowSize,
                    curve: Curves.easeInOut,
        ),
      );

            // ✅ Feature 3: Rotation animation
            _animationRotation = Tween(
                    begin: -0.05,
                    end: 0.05,
      ).animate(
                    CurvedAnimation(
                            parent: _controllerRotation,
                    curve: Curves.easeInOut,
        ),
      );

            // ✅ Feature 4: Pulse animation
            _animationPulse = Tween(
                    begin: 1.0,
                    end: 1.08,
      ).animate(
                    CurvedAnimation(
                            parent: _controllerPulse,
                    curve: Curves.easeInOut,
        ),
      );

            _controllerFloatUp.forward();
            _controllerGrowSize.forward();
            _controllerRotation.repeat(reverse: true);
            _controllerPulse.repeat(reverse: true);
            _isInitialized = true;
        }
    }

    @override
    void dispose() {
        _controllerFloatUp.dispose();
        _controllerGrowSize.dispose();
        _controllerRotation.dispose();
        _controllerPulse.dispose();
        super.dispose();
    }

    @override
    Widget build(BuildContext context) {

        return AnimatedBuilder(
                animation: Listenable.merge([
                _animationFloatUp,
                _animationGrowSize,
                _animationRotation,
                _animationPulse,
      ]),
        builder: (context, child) {
            return Container(
                    margin: EdgeInsets.only(
                    top: _animationFloatUp.value,
          ),
            // ✅ Feature 4: Pulse
            child: ScaleTransition(
                    scale: _animationPulse,
                    // ✅ Feature 3: Rotation
                    child: RotationTransition(
                    turns: _animationRotation,
                    // ✅ Feature 1: Grow scale
                    child: Transform.scale(
                    scale: _animationGrowSize.value,
                    child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [

            // ✅ Feature 2: Balloon shaped shadow
            Positioned(
                    top: 10,
                    left: 10,
                    child: ImageFiltered(
                    imageFilter: ImageFilter.blur(
                    sigmaX: 6,
                    sigmaY: 6,
                        ),
            child: ColorFiltered(
                    colorFilter: ColorFilter.mode(
                    Colors.black.withValues(alpha: 0.35),
            BlendMode.srcATop,
                          ),
            child: Image.asset(
                    'assets/images/BeginningGoogleFlutter-Balloon.png',
                    height: _balloonHeight,
                    width: _balloonWidth,
                          ),
                        ),
                      ),
                    ),

            // ✅ Feature 7: Drag and Pinch Interaction (FIXED)
            // Using onScaleStart/Update only — scale is a superset of pan.
            // focalPointDelta handles drag; details.scale handles pinch.
            GestureDetector(
                    // Tap to float up and down
                    onTap: () {
                if (_controllerFloatUp.isCompleted) {
                    _controllerFloatUp.reverse();
                    _controllerGrowSize.reverse();
                } else {
                    _controllerFloatUp.forward();
                    _controllerGrowSize.forward();
                }
            },
            // ✅ FIX: Removed onPanUpdate — use onScaleStart/Update only.
            // onPanUpdate + onScaleUpdate in same GestureDetector causes:
            // "Having both a pan gesture recognizer and a scale gesture
            //  recognizer is redundant; scale is a superset of pan."
            onScaleStart: (details) {
                    _previousScale = _scale;
                      },
            onScaleUpdate: (details) {
                    setState(() {
                    // Drag: focalPointDelta tracks finger movement
                    _position += details.focalPointDelta;
            // Pinch: scale up or down, clamped between 0.5x and 3x
            _scale = (_previousScale * details.scale)
                    .clamp(0.5, 3.0);
                        });
                      },
            child: Transform.translate(
                    offset: _position, // applies drag
                    child: Transform.scale(
                    scale: _scale,   // applies pinch
                    child: Stack(
                    alignment: Alignment.center,
                    children: [

            // Base balloon image
            Image.asset(
                    'assets/images/BeginningGoogleFlutter-Balloon.png',
                    height: _balloonHeight,
                    width: _balloonWidth,
                              ),

            // ✅ Feature 6: Large shiny highlight
            Positioned(
                    top: _balloonHeight * 0.08,
                    left: _balloonWidth * 0.15,
                    child: Container(
                    width: _balloonWidth * 0.25,
                    height: _balloonHeight * 0.15,
                    decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                    colors: [
            Colors.white.withValues(alpha: 0.85),
            Colors.white.withValues(alpha: 0.3),
            Colors.transparent,
                                      ],
            stops: [0.0, 0.5, 1.0],
                                    ),
                                  ),
                                ),
                              ),

            // ✅ Feature 6: Small secondary highlight
            Positioned(
                    top: _balloonHeight * 0.18,
                    left: _balloonWidth * 0.2,
                    child: Container(
                    width: _balloonWidth * 0.1,
                    height: _balloonHeight * 0.06,
                    decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                    colors: [
            Colors.white.withValues(alpha: 0.6),
            Colors.transparent,
                                      ],
            stops: [0.0, 1.0],
                                    ),
                                  ),
                                ),
                              ),

                            ],
                          ),
                        ),
                      ),
                    ),

                  ],
                ),
              ),
            ),
          ),
        );
        },
    );
    }
}