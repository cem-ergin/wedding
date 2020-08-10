import 'dart:async';

import 'package:flutter/material.dart';

class CountTime extends StatefulWidget {
  CountTime({Key key}) : super(key: key);

  @override
  _CountTimeState createState() => _CountTimeState();
}

class _CountTimeState extends State<CountTime> {
  Timer _timer;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  int _startSecond = 0;

  void startTimer() {
    double _secondDifference =
        (DateTime(2020, 08, 14, 20, 30).millisecondsSinceEpoch -
                DateTime.now().millisecondsSinceEpoch) /
            1000;
    _startSecond = _secondDifference.toInt();
    print("start second: $_startSecond");
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) => setState(
        () {
          if (_startSecond < 1) {
            timer.cancel();
          } else {
            _startSecond = _startSecond - 1;
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Text(
        "${getRemainingTimeStringFromSecond(_startSecond)}",
        textAlign: TextAlign.center,
      ),
    );
  }

  static String getRemainingTimeStringFromSecond(int second) {
    if (second < 1) return "";
    double day = second / 60 / 60 / 24;
    double hours = second % (3600 * 24) / 3600;
    double minutes = second % 3600 / 60;
    double seconds = second % 60 / 1;

    if (minutes < 1) {
      return "${seconds.toInt()} saniye";
    }
    if (hours < 1) {
      return "${minutes.toInt()} dakika ${seconds.toInt()} saniye";
    }
    if (day < 1) {
      return "${hours.toInt()} saat  ${minutes.toInt()} dakika ${seconds.toInt()} saniye";
    }

    return "${day.toInt()} gün ${hours.toInt()} saat  ${minutes.toInt()} dakika ${seconds.toInt()} saniye";
  }
}
