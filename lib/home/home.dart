import 'package:flutter/material.dart';
import './widgets/pulse.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: Text(
          'ChaleBache',
        )),
      ),
      body: Pulse(),
    );
  }
}
