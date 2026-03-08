import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class AnimatedBalloonWidget extends StatefulWidget {
  final Color color;
  final double speedMultiplier;
  final double sizeMultiplier;
  final int delaySeconds;
  final double horizontalOffset;
  final double floatDirection;
  final bool playSound;

  const AnimatedBalloonWidget({
    Key? key,
    this.color = Colors.red,
    this.speedMultiplier = 1.0,
    this.sizeMultiplier = 1.0,
    this.delaySeconds = 0,
    this.horizontalOffset = 0.0,
    this.floatDirection = 1.0,
    this.playSound = false,
  }) : super(key: key);

  @override
  _AnimatedBalloonWidgetState createState() => _AnimatedBalloonWidgetState();
}

class _AnimatedBalloonWidgetState extends State<AnimatedBalloonWidget>
    with TickerProviderStateMixin {

  late AnimationController _controllerFloatUp;
  late AnimationController _controllerGrowSize;
  late AnimationController _controllerRotation;
  late AnimationController _controllerPulse;
  late AnimationController _controllerFloatAway;

  late Animation<double> _animationFloatUp;
  late Animation<double> _animationGrowSize;
  late Animation<double> _animationRotation;
  late Animation<double> _animationPulse;
  late Animation<double> _animationFloatAwayX;
  late Animation<double> _animationFadeOut;

  bool _isInitialized = false;
  double _balloonHeight = 0;
  double _balloonWidth = 0;

  Offset _position = Offset.zero;
  double _scale = 1.0;
  bool _isBig = false;
  bool _isDragging = false;

  final AudioPlayer _inflatePlayer = AudioPlayer();
  final AudioPlayer _deflatePlayer = AudioPlayer();
  final AudioPlayer _windPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _controllerFloatUp = AnimationController(
      duration: Duration(seconds: (8 / widget.speedMultiplier).round()),
      vsync: this,
    );
    _controllerGrowSize = AnimationController(
      duration: Duration(seconds: (4 / widget.speedMultiplier).round()),
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
    _controllerFloatAway = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isInitialized) {
      _balloonHeight = MediaQuery.of(context).size.height / 2 * widget.sizeMultiplier;
      _balloonWidth = MediaQuery.of(context).size.height / 3 * widget.sizeMultiplier;
      double screenWidth = MediaQuery.of(context).size.width;
      double balloonBottomLocation =
          MediaQuery.of(context).size.height - _balloonHeight;

      _position = Offset(widget.horizontalOffset, 0);

      _animationFloatUp = Tween(
        begin: balloonBottomLocation,
        end: 0.0,
      ).animate(CurvedAnimation(
        parent: _controllerFloatUp,
        curve: Curves.easeInOutCubic,
      ));

      _animationGrowSize = Tween(
        begin: 0.1,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _controllerGrowSize,
        curve: Curves.easeInOut,
      ));

      _animationRotation = Tween(
        begin: -0.05,
        end: 0.05,
      ).animate(CurvedAnimation(
        parent: _controllerRotation,
        curve: Curves.easeInOut,
      ));

      _animationPulse = Tween(
        begin: 1.0,
        end: 1.08,
      ).animate(CurvedAnimation(
        parent: _controllerPulse,
        curve: Curves.easeInOut,
      ));

      _animationFloatAwayX = Tween(
        begin: 0.0,
        end: screenWidth * widget.floatDirection,
      ).animate(CurvedAnimation(
        parent: _controllerFloatAway,
        curve: Curves.easeInOut,
      ));

      _animationFadeOut = Tween(
        begin: 1.0,
        end: 0.0,
      ).animate(CurvedAnimation(
        parent: _controllerFloatAway,
        curve: Curves.easeIn,
      ));

      _controllerFloatUp.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          Future.delayed(Duration(milliseconds: 800), () {
            if (mounted) {
              _controllerFloatAway.forward();
            }
          });
        }
      });

      _controllerFloatAway.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          Future.delayed(Duration(seconds: 1), () {
            if (mounted) {
              setState(() {
                _position = Offset(widget.horizontalOffset, 0);
                _scale = 1.0;
                _isBig = false;
              });
              _controllerFloatAway.reset();
              _controllerFloatUp.reset();
              _controllerGrowSize.reset();
              Future.delayed(Duration(seconds: widget.delaySeconds), () {
                if (mounted) {
                  _controllerFloatUp.forward();
                  _controllerGrowSize.forward();
                }
              });
            }
          });
        }
      });

      _controllerRotation.repeat(reverse: true);
      _controllerPulse.repeat(reverse: true);

      Future.delayed(Duration(seconds: widget.delaySeconds), () {
        if (mounted) {
          _controllerFloatUp.forward();
          _controllerGrowSize.forward();
          if (widget.playSound) _playInflate();
        }
      });

      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _controllerFloatUp.dispose();
    _controllerGrowSize.dispose();
    _controllerRotation.dispose();
    _controllerPulse.dispose();
    _controllerFloatAway.dispose();
    _inflatePlayer.dispose();
    _deflatePlayer.dispose();
    _windPlayer.dispose();
    super.dispose();
  }

  Future<void> _playInflate() async {
    await _inflatePlayer.play(AssetSource('sounds/inflate.mp3'));
  }

  Future<void> _playDeflate() async {
    await _deflatePlayer.play(AssetSource('sounds/deflate.wav'));
  }

  Future<void> _playWind() async {
    await _windPlayer.play(AssetSource('sounds/wind.wav'));
  }

  void _handleTap() {
    _controllerFloatAway.reset();
    if (_controllerFloatUp.isCompleted) {
      if (widget.playSound) _playDeflate();
      _controllerFloatUp.reverse();
      _controllerGrowSize.reverse();
    } else {
      if (widget.playSound) _playInflate();
      _controllerFloatUp.forward();
      _controllerGrowSize.forward();
    }
  }

  void _handleDoubleTap() {
    setState(() {
      _isBig = !_isBig;
      if (_isBig) {
        if (widget.playSound) _playInflate();
        _scale = 1.8;
      } else {
        if (widget.playSound) _playDeflate();
        _scale = 1.0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _animationFloatUp,
        _animationGrowSize,
        _animationRotation,
        _animationPulse,
        _animationFloatAwayX,
        _animationFadeOut,
      ]),
      builder: (context, child) {
        return Opacity(
          opacity: _animationFadeOut.value,
          child: Container(
            margin: EdgeInsets.only(
              top: _animationFloatUp.value,
            ),
            child: ScaleTransition(
              scale: _animationPulse,
              child: RotationTransition(
                turns: _animationRotation,
                child: Transform.scale(
                  scale: _animationGrowSize.value,
                  child: Transform.translate(
                    offset: Offset(
                      _position.dx + _animationFloatAwayX.value,
                      _position.dy,
                    ),
                    child: Transform.scale(
                      scale: _scale,
                      child: GestureDetector(
                        onTap: _handleTap,
                        onDoubleTap: _handleDoubleTap,
                        onPanStart: (details) {
                          if (!_isDragging) {
                            _isDragging = true;
                            if (widget.playSound) _playWind();
                          }
                        },
                        onPanUpdate: (details) {
                          setState(() {
                            _position += details.delta;
                          });
                        },
                        onPanEnd: (details) {
                          _isDragging = false;
                        },
                        child: Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.center,
                          children: [


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


                            Stack(
                              alignment: Alignment.center,
                              children: [


                                ColorFiltered(
                                  colorFilter: ColorFilter.mode(
                                    widget.color.withValues(alpha: 0.7),
                                    BlendMode.srcATop,
                                  ),
                                  child: Image.asset(
                                    'assets/images/BeginningGoogleFlutter-Balloon.png',
                                    height: _balloonHeight,
                                    width: _balloonWidth,
                                  ),
                                ),

                                // Feature 6: Large shiny highlight
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

                                // Feature 6: Small secondary highlight
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

                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}