
A Flutter slider that makes a wave effect when dragged. Does a little bounce when dropped.

## Demo

<img height="240px" src="https://media.giphy.com/media/ifecPIFcXHu5AJmpfl/giphy.gif">


## Getting Started

To use this plugin, add `wave_slider` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).

The color can be set with the `color` property. The slider size is dependent on the size of its parent. The height of the wave slider can be set with the `sliderHeigth` property - which is constrained with a minimum of 50 and a maximum of 600.

An option `displayTrackball` property can be set to **true** to show a trackball along with the slider. The default is **false**

Values are retrieved by passing in an `onChanged` callback, which returns a value between 0 and 1 to indicate the current drag completion percentage.

The `onChangeStart` and `onChangeEnd` callbacks can be used to retrieve the start and end drag percentages respectively.

### Example

```dart
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
              style: TextStyle(fontSize: 16),
            ),
          )
        ],
      ),
    );
  }
}
```

### Interested in how the package was made?
Check out this [playlist](https://www.youtube.com/playlist?list=PLjr4ufdmNA4J2-KwMutexAjjf_VmjL1eH) on the [Fun with Flutter](https://www.youtube.com/funwithflutter) YouTube channel!