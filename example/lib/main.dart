import 'package:flutter/material.dart';
import 'package:wave_slider/wave_slider.dart';

void main() => runApp(MaterialApp(
      home: App(),
    ));

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  double _dragPercentage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          WaveSlider(
            displayTrackball: false,
            onChanged: (double dragUpdate) {
              setState(() {
                _dragPercentage = dragUpdate *
                    100; // dragUpdate is a fractional value between 0 and 1
              });
            },
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Drag percentage',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '$_dragPercentage',
              style: const TextStyle(fontSize: 16),
            ),
          )
        ],
      ),
    );
  }
}
