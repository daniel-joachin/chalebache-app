import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sensors/sensors.dart';
import 'dart:core';

import 'package:http/http.dart' as http;

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
  List accelerometer = [];
  List gyro = [];
  Stopwatch timer = Stopwatch();
  bool isPothole = true;

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
    if (_play) {
      gyro.add({
        'time': timer.elapsedMilliseconds / 1000,
        'data': _gyroscopeValues,
        'pothole': isPothole
      });
      accelerometer.add({
        'time': timer.elapsedMilliseconds / 1000,
        'data': _userAccelerometerValues,
        'pothole': isPothole
      });
    }
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

              if (timer.isRunning) {
                timer.stop();
                timer.reset();
              } else {
                timer.start();
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
        Padding(padding: EdgeInsets.only(top: 50)),
        Text('¿Es Bache?'),
        Switch(
          value: isPothole,
          onChanged: (value) {
            setState(() {
              isPothole = value;
            });
          },
          activeColor: Colors.green,
          activeTrackColor: Colors.grey,
        ),
        ElevatedButton(
            onPressed: () async {
              await sendData();
            },
            child: Text('Send Data'))
      ],
    );
  }

  Future<http.Response> sendData() {
    return http.post(
      Uri.https('chalebache.herokuapp.com', '/api/potholes/batch'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, List<dynamic>>{
        'gyroscope': gyro,
        'accelerometer': accelerometer
      }),
    );
  }
}
