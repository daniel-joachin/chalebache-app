import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:core';

import 'package:http/http.dart' as http;
import 'package:sensors/sensors.dart';
import 'package:location/location.dart';

class Pulse extends StatefulWidget {
  @override
  _PulseState createState() => _PulseState();
}

class _PulseState extends State<Pulse> with TickerProviderStateMixin {
  AnimationController _animationController;
  Animation _animation;
  bool _play = false;
  List<double> _userAccelerometerValues;
  List<StreamSubscription<dynamic>> _streamSubscriptions =
      <StreamSubscription<dynamic>>[];

  List accelerometer = [];
  double _latValues;
  double _longValues;
  Stopwatch timer = Stopwatch();
  Location location = new Location();
  bool _serviceEnabled;
  PermissionStatus _permissionGranted;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );
    _animation = Tween(begin: 1.0, end: 25.0).animate(_animationController)
      ..addListener(() {
        setState(() {});
      });
    _streamSubscriptions
        .add(userAccelerometerEvents.listen((UserAccelerometerEvent event) {
      setState(() {
        _userAccelerometerValues = <double>[event.x, event.y, event.z];
      });
    }));
    location.onLocationChanged.listen((LocationData currentLocation) {
      setState(() {
        _latValues = currentLocation.latitude;
        _longValues = currentLocation.longitude;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_play) {
      accelerometer.add({
        'time': timer.elapsedMilliseconds / 1000,
        'data': _userAccelerometerValues,
        'location': {'lat': _latValues, 'long': _longValues}
      });
      if (((timer.elapsedMilliseconds ~/ 1000) + 1) % 7 == 0) {
        sendData();
        this.accelerometer.clear();
        timer.reset();
      }
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: InkWell(
            onTap: () async {
              bool service = await checkService();
              bool permission = await checkPermissions();
              if (!permission && !service) {
                return;
              }
              _play = !_play;
              if (_play) {
                _animationController.repeat(reverse: true);
              } else {
                _animationController.reset();
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
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<http.Response> sendData() async {
    return http.post(
      Uri.http('192.168.0.124:1440', '/api/pothole/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(
        <String, List<dynamic>>{'accelerometer': accelerometer},
      ),
    );
  }

  Future<bool> checkService() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return false;
      }
      return true;
    }
    return true;
  }

  Future<bool> checkPermissions() async {
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return false;
      }
      return true;
    }
    return true;
  }
}
