import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sensors/sensors.dart';

class Pulse extends StatefulWidget {
  @override
  _PulseState createState() => _PulseState();
}

class _PulseState extends State<Pulse> with TickerProviderStateMixin {
  AnimationController _animationController;
  Animation _animation;
  bool _play = false;
  List<double> _userAccelerometerValues;
  List<double> _gyroscopeValues;
  List<StreamSubscription<dynamic>> _streamSubscriptions =
      <StreamSubscription<dynamic>>[];

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );
    _animation = Tween(begin: 1.0, end: 25.0).animate(_animationController)
      ..addListener(() {
        setState(() {});
      });
    super.initState();
    _streamSubscriptions.add(gyroscopeEvents.listen((GyroscopeEvent event) {
      setState(() {
        _gyroscopeValues = <double>[event.x, event.y, event.z];
      });
    }));
    _streamSubscriptions
        .add(userAccelerometerEvents.listen((UserAccelerometerEvent event) {
      setState(() {
        _userAccelerometerValues = <double>[event.x, event.y, event.z];
      });
    }));
  }

  @override
  Widget build(BuildContext context) {
    if (_play) {}

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: InkWell(
            onTap: () {
              if (_play) {
                _play = !_play;
                _animationController.reset();
              } else {
                _play = !_play;
                _animationController.repeat(reverse: true);
              }
            },
            customBorder: CircleBorder(),
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.indigo,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.indigo,
                      blurRadius: _animation.value,
                      spreadRadius: _animation.value,
                    )
                  ]),
            ),
          ),
        ),
      ],
    );
  }
}
