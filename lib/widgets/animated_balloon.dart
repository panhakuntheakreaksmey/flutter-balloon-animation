import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class AnimatedBalloonWidget extends StatefulWidget {
  final Color color;
  final double speedMultiplier;
  final double sizeMultiplier;
  final int delaySeconds;
  final double floatDirection;
  final bool playSound;

  const AnimatedBalloonWidget({
    Key? key,
    this.color = Colors.red,
    this.speedMultiplier = 1.0,
    this.sizeMultiplier = 1.0,
    this.delaySeconds = 0,
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
  late AnimationController _controllerPop;

  late Animation<double> _animationFloatUp;
  late Animation<double> _animationGrowSize;
  late Animation<double> _animationRotation;
  late Animation<double> _animationPulse;
  late Animation<double> _animationFloatAwayX;
  late Animation<double> _animationFadeOut;
  late Animation<double> _animationDeflateScaleX;
  late Animation<double> _animationDeflateScaleY;
  late Animation<double> _animationDeflateWobble;
  late Animation<double> _animationDeflateFall;
  late Animation<double> _animationDeflateFade;

  bool _isInitialized = false;
  double _balloonHeight = 0;
  double _balloonWidth = 0;
  double _screenHeight = 0;
  bool _isFloatingAway = false;
  bool _isPopped = false;

  // Gesture variables
  Offset _position = Offset.zero;
  double _scale = 1.0;
  bool _isBig = false;
  bool _isDragging = false;
  bool _didDrag = false;
  DateTime? _fingerDownTime;
  DateTime? _lastTapTime;

  final AudioPlayer _inflatePlayer = AudioPlayer();
  final AudioPlayer _deflatePlayer = AudioPlayer();
  final AudioPlayer _windPlayer = AudioPlayer();

  final Random _random = Random();

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
      duration: Duration(seconds: 6),
      vsync: this,
    );
    _controllerPop = AnimationController(
      duration: Duration(milliseconds: 3000),
      vsync: this,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isInitialized) {
      _balloonHeight =
          MediaQuery.of(context).size.height / 2 * widget.sizeMultiplier;
      _balloonWidth =
          MediaQuery.of(context).size.height / 3 * widget.sizeMultiplier;
      _screenHeight = MediaQuery.of(context).size.height;
      double screenWidth = MediaQuery.of(context).size.width;
      double balloonBottomLocation = _screenHeight - _balloonHeight;

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

      _animationDeflateScaleX = TweenSequence([
        TweenSequenceItem(
            tween: Tween(begin: 1.0, end: 0.6), weight: 50),
        TweenSequenceItem(
            tween: Tween(begin: 0.6, end: 0.15), weight: 50),
      ]).animate(CurvedAnimation(
        parent: _controllerPop,
        curve: Interval(0.0, 0.6, curve: Curves.easeInOut),
      ));

      _animationDeflateScaleY = TweenSequence([
        TweenSequenceItem(
            tween: Tween(begin: 1.0, end: 1.3), weight: 20),
        TweenSequenceItem(
            tween: Tween(begin: 1.3, end: 0.15), weight: 80),
      ]).animate(CurvedAnimation(
        parent: _controllerPop,
        curve: Interval(0.0, 0.6, curve: Curves.easeIn),
      ));

      _animationDeflateWobble = TweenSequence([
        TweenSequenceItem(
            tween: Tween(begin: 0.0, end: 0.04), weight: 20),
        TweenSequenceItem(
            tween: Tween(begin: 0.04, end: -0.04), weight: 20),
        TweenSequenceItem(
            tween: Tween(begin: -0.04, end: 0.03), weight: 20),
        TweenSequenceItem(
            tween: Tween(begin: 0.03, end: -0.02), weight: 20),
        TweenSequenceItem(
            tween: Tween(begin: -0.02, end: 0.0), weight: 20),
      ]).animate(CurvedAnimation(
        parent: _controllerPop,
        curve: Interval(0.0, 0.6, curve: Curves.easeInOut),
      ));

      // ✅ Falls ALL the way off screen bottom — full screen height + balloon height
      _animationDeflateFall = Tween(
        begin: 0.0,
        end: _screenHeight + _balloonHeight,
      ).animate(CurvedAnimation(
        parent: _controllerPop,
        // ✅ Fall starts at 40% so deflate finishes first, then it falls
        curve: Interval(0.4, 1.0, curve: Curves.easeIn),
      ));

      // ✅ Fade out only at the very end when fully off screen
      _animationDeflateFade = Tween(
        begin: 1.0,
        end: 0.0,
      ).animate(CurvedAnimation(
        parent: _controllerPop,
        curve: Interval(0.85, 1.0, curve: Curves.easeIn),
      ));

      // ✅ When pop finishes — wait random 3-6 seconds then respawn
      _controllerPop.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          // random delay between 3 and 6 seconds
          final respawnDelay = 3 + _random.nextInt(4);
          Future.delayed(Duration(seconds: respawnDelay), () {
            if (mounted) {
              setState(() {
                _isPopped = false;
                _position = Offset.zero;
                _scale = 1.0;
                _isBig = false;
                _isFloatingAway = false;
              });
              _controllerPop.reset();
              _controllerFloatUp.reset();
              _controllerGrowSize.reset();
              // ✅ Grow from size 0 at bottom — looks like new balloon
              _controllerFloatUp.forward();
              _controllerGrowSize.forward();
            }
          });
        }
      });

      // Float away after reaching top
      _controllerFloatUp.addStatusListener((status) {
        if (status == AnimationStatus.completed &&
            !_isFloatingAway &&
            !_isPopped) {
          Future.delayed(Duration(seconds: 2), () {
            if (mounted && !_isFloatingAway && !_isPopped) {
              setState(() => _isFloatingAway = true);
              _controllerFloatAway.forward();
            }
          });
        }
      });

      // Reset and loop after floating away
      _controllerFloatAway.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          Future.delayed(Duration(seconds: 1), () {
            if (mounted && !_isPopped) {
              setState(() {
                _position = Offset.zero;
                _scale = 1.0;
                _isBig = false;
                _isFloatingAway = false;
              });
              _controllerFloatAway.reset();
              _controllerFloatUp.reset();
              _controllerGrowSize.reset();
              Future.delayed(Duration(seconds: widget.delaySeconds), () {
                if (mounted && !_isPopped) {
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
    _controllerPop.dispose();
    _inflatePlayer.dispose();
    _deflatePlayer.dispose();
    _windPlayer.dispose();
    super.dispose();
  }

  Future<void> _playInflate() async {
    try {
      await _inflatePlayer.play(AssetSource('sounds/inflate.mp3'));
    } catch (_) {}
  }

  Future<void> _playDeflate() async {
    try {
      await _deflatePlayer.play(AssetSource('sounds/deflate.wav'));
    } catch (_) {}
  }

  Future<void> _playWind() async {
    try {
      await _windPlayer.play(AssetSource('sounds/wind.wav'));
    } catch (_) {}
  }

  void _handleTap() {
    if (_isPopped || _controllerPop.isAnimating) return;
    if (_isFloatingAway) {
      _controllerFloatAway.reset();
      setState(() => _isFloatingAway = false);
    }
    // ✅ Mark as popped immediately so it stops responding to gestures
    setState(() => _isPopped = true);
    _playDeflate();
    _controllerPop.forward();
  }

  void _handleDoubleTap() {
    if (_isPopped || _controllerPop.isAnimating) return;
    setState(() {
      _isBig = !_isBig;
      if (_isBig) {
        _playInflate();
        _scale = 1.8;
      } else {
        _playDeflate();
        _scale = 1.0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Hide only when truly gone (between fall off screen and respawn)
    if (_isPopped && !_controllerPop.isAnimating) return SizedBox.shrink();

    return AnimatedBuilder(
      animation: Listenable.merge([
        _animationFloatUp,
        _animationGrowSize,
        _animationRotation,
        _animationPulse,
        _animationFloatAwayX,
        _animationFadeOut,
        _controllerPop,
      ]),
      builder: (context, child) {
        return Opacity(
          opacity: _controllerPop.isAnimating
              ? _animationDeflateFade.value
              : _animationFadeOut.value,
          child: Container(
            margin: EdgeInsets.only(top: _animationFloatUp.value),
            child: ScaleTransition(
              scale: _animationPulse,
              child: RotationTransition(
                turns: _animationRotation,
                child: Transform.scale(
                  scale: _animationGrowSize.value,
                  child: Transform.translate(
                    offset: Offset(
                      _position.dx + _animationFloatAwayX.value,
                      _position.dy + _animationDeflateFall.value,
                    ),
                    child: Transform.scale(
                      scale: _scale,
                      child: GestureDetector(
                        onScaleStart: (details) {
                          _fingerDownTime = DateTime.now();
                          _isDragging = false;
                          _didDrag = false;
                        },
                        onScaleUpdate: (details) {
                          if (_isPopped) return;
                          if (details.focalPointDelta.distance > 5) {
                            _didDrag = true;
                            setState(() {
                              _position += details.focalPointDelta;
                            });
                            if (!_isDragging) {
                              _isDragging = true;
                              _playWind();
                            }
                          }
                        },
                        onScaleEnd: (details) {
                          _isDragging = false;

                          if (!_didDrag && _fingerDownTime != null) {
                            final now = DateTime.now();
                            final heldMs = now
                                .difference(_fingerDownTime!)
                                .inMilliseconds;

                            if (heldMs < 400) {
                              if (_lastTapTime != null &&
                                  now
                                      .difference(_lastTapTime!)
                                      .inMilliseconds < 350) {
                                // double tap — resize
                                _lastTapTime = null;
                                _handleDoubleTap();
                              } else {
                                // first tap — wait for possible second
                                _lastTapTime = now;
                                Future.delayed(
                                  Duration(milliseconds: 350),
                                      () {
                                    if (mounted &&
                                        _lastTapTime != null &&
                                        DateTime.now()
                                            .difference(_lastTapTime!)
                                            .inMilliseconds >= 350) {
                                      _lastTapTime = null;
                                      _handleTap();
                                    }
                                  },
                                );
                              }
                            }
                          }

                          _didDrag = false;
                          _fingerDownTime = null;
                        },
                        child: Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.center,
                          children: [

                            // Shadow and balloon in ONE Transform
                            Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()
                                ..scale(
                                  _controllerPop.isAnimating
                                      ? _animationDeflateScaleX.value
                                      : 1.0,
                                  _controllerPop.isAnimating
                                      ? _animationDeflateScaleY.value
                                      : 1.0,
                                ),
                              child: Stack(
                                alignment: Alignment.center,
                                clipBehavior: Clip.none,
                                children: [

                                  // Shadow
                                  Transform.translate(
                                    offset: Offset(10, 10),
                                    child: ImageFiltered(
                                      imageFilter: ImageFilter.blur(
                                        sigmaX: 6,
                                        sigmaY: 6,
                                      ),
                                      child: ColorFiltered(
                                        colorFilter: ColorFilter.mode(
                                          widget.color.withValues(alpha: 0.4),
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

                                  // Balloon with wobble
                                  RotationTransition(
                                    turns: _controllerPop.isAnimating
                                        ? _animationDeflateWobble
                                        : AlwaysStoppedAnimation(0.0),
                                    child: Stack(
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

                                        // Large shiny highlight
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
                                                  Colors.white.withValues(
                                                      alpha: 0.85),
                                                  Colors.white.withValues(
                                                      alpha: 0.3),
                                                  Colors.transparent,
                                                ],
                                                stops: [0.0, 0.5, 1.0],
                                              ),
                                            ),
                                          ),
                                        ),

                                        // Small secondary highlight
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
                                                  Colors.white.withValues(
                                                      alpha: 0.6),
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

                                ],
                              ),
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
